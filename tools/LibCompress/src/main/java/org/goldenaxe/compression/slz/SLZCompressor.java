package org.goldenaxe.compression.slz;

import java.util.ArrayList;
import java.util.List;
import org.goldenaxe.compression.CompressionBuffer;
import org.goldenaxe.compression.CompressionResult;
import org.goldenaxe.compression.Endianess;


/**
 * Java port of SLZ compression by Javier Degirolmo (<a href="https://github.com/sikthehedgehog">...</a>)
 */
public class SLZCompressor
{
    private static final int MAX_TOKENS = 8;

    public CompressionResult compress(byte[] input)
    {
        return new CompressionResult(
                compressBytes(input),
                input.length);
    }

    private List<Byte> compressBytes(byte[] inputBytes)
    {
        CompressionBuffer compressionBuffer = new CompressionBuffer(Endianess.BIG, MAX_TOKENS);
        SLZToken token = SLZToken.init(inputBytes);

        while (!token.isTerminal())
        {
            compressionBuffer.writeToken(token);

            token = token.next(inputBytes);
        }

        List<Byte> compressedBytes = new ArrayList<>();
        compressedBytes.addAll(createHeader(inputBytes.length));
        compressedBytes.addAll(compressionBuffer.complete());

        return compressedBytes;
    }

    private List<Byte> createHeader(int uncompressedSize)
    {
        return Endianess.BIG.toBytes((short) uncompressedSize);
    }
}
