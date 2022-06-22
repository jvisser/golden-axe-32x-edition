package org.goldenaxe.datavis.compression;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Objects;


// Ported from https://github.com/sonicretro/KENSSharp
public class NemesisCompression
{
    private NemesisCompression()
    {
    }

    public static byte[] decompress(InputStream inputStream)
    {
        ByteArrayOutputStream output = new ByteArrayOutputStream();

        try
        {
            DecodingCodeTreeNode codeTree = new DecodingCodeTreeNode();
            int numberOfTiles = inputStream.read() << 8;
            numberOfTiles |= inputStream.read();
            boolean xorOutput = (numberOfTiles & 0x8000) != 0;
            numberOfTiles &= 0x7fff;
            decodeHeader(inputStream, codeTree);
            decodeInternal(inputStream, output, codeTree, numberOfTiles, xorOutput);
        }
        catch (IOException e)
        {
            throw new DecompressionException(e);
        }

        return output.toByteArray();
    }

    private static void decodeHeader(InputStream input, DecodingCodeTreeNode codeTree) throws IOException
    {
        int outputValue = 0;
        int inputValue;

        // Loop until a byte with value 0xFF is encountered
        while ((inputValue = input.read()) != 0xFF)
        {
            if ((inputValue & 0x80) != 0)
            {
                outputValue = inputValue & 0xF;
                inputValue = input.read();
            }

            codeTree.setCode(
                    input.read(),
                    inputValue & 0xF,
                    new NibbleRun(outputValue, (((inputValue & 0x70) >>> 4) + 1)));
        }

        // Store a special nibble run for inline RLE sequences (code = 0b111111, length = 6)
        // Length = 0xFF in the nibble run is just a marker value that will be handled specially in DecodeInternal
        codeTree.setCode(0x3F, 6, new NibbleRun(0, 0xFF));
    }

    private static void decodeInternal(InputStream input, ByteArrayOutputStream output, DecodingCodeTreeNode codeTree,
                                       int numberOfTiles, boolean xorOutput) throws IOException
    {
        OutputBitStream outputBits;
        InputBitStream inputBits = new InputBitStream(input);
        XorOutputStream xorStream;
        if (xorOutput)
        {
            xorStream = new XorOutputStream(output);
            outputBits = new OutputBitStream(xorStream);
        }
        else
        {
            outputBits = new OutputBitStream(output);
        }

        // The output is: number of tiles * 0x20 (1 << 5) bytes per tile * 8 (1 << 3) bits per byte
        int outputSize = numberOfTiles << 8; // in bits
        int bitsWritten = 0;

        DecodingCodeTreeNode currentNode = codeTree;
        while (bitsWritten < outputSize)
        {
            NibbleRun nibbleRun = currentNode.getNibbleRun();
            if (nibbleRun.count == 0xFF)
            {
                // Bit pattern 0b111111; inline RLE.
                // First 3 bits are repetition count, followed by the inlined nibble.
                int count = (inputBits.read(3) & 0x7) + 1;
                int nibble = (inputBits.read(4)) & 0xf;
                bitsWritten += decodeNibbleRun(outputBits, count, nibble);
                currentNode = codeTree;
            }
            else if (nibbleRun.count != 0)
            {
                // Output the encoded nibble run
                bitsWritten += decodeNibbleRun(outputBits, nibbleRun.count, nibbleRun.nibble);
                currentNode = codeTree;
            }
            else
            {
                // Read the next bit and go down one level in the tree
                currentNode = currentNode.getSubTree(inputBits.get());
            }
        }

        outputBits.flush(false);
    }

    private static int decodeNibbleRun(OutputBitStream outputBits, int count, int nibble) throws IOException
    {
        int bitsWritten = count * 4;

        // Write single nibble, if needed
        if ((count & 1) != 0)
        {
            outputBits.write(nibble, 4);
        }

        // Write pairs of nibbles
        count >>>= 1;
        nibble |= (nibble << 4);
        while (count != 0)
        {
            outputBits.write(nibble, 8);
            count--;
        }

        return bitsWritten;
    }

    private static class NibbleRun implements Comparable<NibbleRun>
    {
        public final Integer nibble;
        public final Integer count;

        public NibbleRun()
        {
            this.nibble = 0;
            this.count = 0;
        }

        public NibbleRun(int nibble, int count)
        {
            this.nibble = nibble;
            this.count = count;
        }

        @Override
        public boolean equals(Object o)
        {
            if (this == o)
            {
                return true;
            }
            if (o == null || getClass() != o.getClass())
            {
                return false;
            }
            final NibbleRun nibbleRun = (NibbleRun) o;
            return nibble.equals(nibbleRun.nibble) && count.equals(nibbleRun.count);
        }

        @Override
        public int hashCode()
        {
            return Objects.hash(nibble, count);
        }

        public int compareTo(NibbleRun other)
        {
            int comp = this.nibble.compareTo(other.nibble);
            if (comp == 0)
            {
                comp = this.count.compareTo(other.count);
            }

            return comp;
        }
    }

    private static class DecodingCodeTreeNode
    {
        private DecodingCodeTreeNode clear;
        private DecodingCodeTreeNode set;
        private NibbleRun nibbleRun = new NibbleRun();

        public void setCode(int code, int length, NibbleRun nibbleRun)
        {
            if (length == 0)
            {
                this.nibbleRun = nibbleRun;
            }
            else
            {
                --length;
                if ((code & (1 << length)) == 0)
                {
                    if (this.clear == null)
                    {
                        this.clear = new DecodingCodeTreeNode();
                    }

                    this.clear.setCode(code, length, nibbleRun);
                }
                else
                {
                    if (this.set == null)
                    {
                        this.set = new DecodingCodeTreeNode();
                    }

                    this.set.setCode((code & ((1 << length) - 1)), length, nibbleRun);
                }
            }
        }


        public DecodingCodeTreeNode getSubTree(boolean side)
        {
            return side ? this.set : this.clear;
        }

        public NibbleRun getNibbleRun()
        {
            return this.nibbleRun;
        }
    }

    public static class OutputBitStream
    {
        private final OutputStream outputStream;
        private int waitingBits = 0;
        private int byteBuffer = 0;

        public OutputBitStream(OutputStream outputStream)
        {
            this.outputStream = outputStream;
        }

        public void flush(boolean unchanged) throws IOException
        {
            if (this.waitingBits != 0)
            {
                if (!unchanged)
                {
                    this.byteBuffer <<= 8 - this.waitingBits;
                }

                outputStream.write(this.byteBuffer);
                this.waitingBits = 0;
            }
        }

        public void write(int data, int size) throws IOException
        {
            if (this.waitingBits + size >= 8)
            {
                int delta = 8 - this.waitingBits;
                this.waitingBits = (this.waitingBits + size) & 0x7;
                int bits = (this.byteBuffer << delta) | (data >>> this.waitingBits);
                outputStream.write(bits);
                this.byteBuffer = data;
                return;
            }

            this.byteBuffer <<= size;
            this.byteBuffer |= data;
            this.waitingBits += size;
        }
    }

    private static class XorOutputStream extends OutputStream
    {
        private final int[] values = new int[4];
        private final OutputStream outputStream;
        private int subPosition = 0;

        private XorOutputStream(OutputStream outputStream)
        {
            this.outputStream = outputStream;
        }

        @Override
        public void write(int b) throws IOException
        {
            values[this.subPosition] ^= b;
            int xor = values[this.subPosition];
            ++this.subPosition;
            this.subPosition &= 3;

            outputStream.write(xor);
        }
    }

    public static class InputBitStream
    {
        private final InputStream stream;
        private int remainingBits;
        private int byteBuffer;

        public InputBitStream(InputStream input) throws IOException
        {
            this.stream = input;

            this.remainingBits = 8;
            this.byteBuffer = stream.read();
        }

        public boolean get() throws IOException
        {
            this.checkBuffer();
            --this.remainingBits;
            int bit = (this.byteBuffer & (1 << this.remainingBits));
            this.byteBuffer ^= bit; // clear the bit
            return bit != 0;
        }

        public int read(int count) throws IOException
        {
            this.checkBuffer();
            if (this.remainingBits < count)
            {
                int delta = count - this.remainingBits;
                int lowBits = (this.byteBuffer << delta);
                this.byteBuffer = stream.read();
                this.remainingBits = 8 - delta;
                int highBits = (this.byteBuffer >>> this.remainingBits);
                this.byteBuffer ^= (highBits << this.remainingBits);
                return (lowBits | highBits);
            }

            this.remainingBits -= count;
            int bits = (this.byteBuffer >>> this.remainingBits);
            this.byteBuffer ^= bits << this.remainingBits;
            return bits;
        }

        private void checkBuffer() throws IOException
        {
            if (this.remainingBits == 0)
            {
                this.byteBuffer = stream.read();
                this.remainingBits = 8;
            }
        }
    }
}