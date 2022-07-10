package org.goldenaxe.compression.comper;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.ShortBuffer;
import org.goldenaxe.compression.CompressionBuffer;
import org.goldenaxe.compression.CompressionResult;
import org.goldenaxe.compression.Endianess;


/**
 * Java port of Comper compression by vladikcomper (<a href="https://github.com/vladikcomper">...</a>)
 */
public class ComperCompressor
{
    private static final int MAX_SEARCH_DISTANCE = 0x100;
    private static final int MAX_TOKENS = 16;

    public CompressionResult compress(byte[] input)
    {
        ComperToken[] tokens = buildLZSSGraph(input);

        CompressionBuffer compressionBuffer = new CompressionBuffer(Endianess.BIG, MAX_TOKENS);

        ComperToken currentToken = tokens[0];
        while(currentToken.hasNext())
        {
            compressionBuffer.writeToken(currentToken);

            currentToken = currentToken.getNext();
        }

        compressionBuffer.writeToken(ComperToken.terminal());

        return new CompressionResult(compressionBuffer.complete(), (tokens.length - 1) * 2);
    }

    private ComperToken[] buildLZSSGraph(byte[] input)
    {
        ComperToken[] tokens = createTokens(input);

        int size = tokens.length - 1;
        for (int currentPosition = 0; currentPosition < size; ++currentPosition)
        {
            int maxReadAhead = Math.min(MAX_SEARCH_DISTANCE, size - currentPosition);
            int maxReadBehind = Math.max(0, currentPosition - MAX_SEARCH_DISTANCE);

            ComperToken currentToken = tokens[currentPosition];
            for (int readBehindPosition = currentPosition; readBehindPosition-- > maxReadBehind;)
            {
                for (int readAheadOffset = 0; readAheadOffset < maxReadAhead; ++readAheadOffset)
                {
                    if (tokens[currentPosition + readAheadOffset].equals(tokens[readBehindPosition + readAheadOffset]))
                    {
                        ComperToken token = tokens[currentPosition + readAheadOffset + 1];
                        if (token.compareTo(currentToken) > 0)
                        {
                            token.link(currentToken, readBehindPosition);
                        }
                    }
                    else
                    {
                        break;
                    }
                }
            }

            ComperToken nextToken = tokens[currentPosition + 1];
            if (nextToken.compareTo(currentToken) >= 0)
            {
                nextToken.linkUncompressed(currentToken);
            }
        }

        completeBiDirectionalLinks(tokens);

        return tokens;
    }

    private void completeBiDirectionalLinks(ComperToken[] tokens)
    {
        tokens[0].terminatePrevious();
        tokens[tokens.length - 1].terminateNext();

        ComperToken currentToken = tokens[tokens.length - 1];
        while (currentToken.hasPrevious())
        {
            currentToken.linkNext();

            currentToken = currentToken.getPrevious();
        }
    }

    private ComperToken[] createTokens(byte[] input)
    {
        ByteBuffer byteBuffer = ByteBuffer.allocate((input.length + 1) & ~1);
        byteBuffer.put(input);
        byteBuffer.position(0);
        byteBuffer.order(ByteOrder.BIG_ENDIAN);
        ShortBuffer buffer = byteBuffer.asShortBuffer();

        ComperToken[] tokens = new ComperToken[buffer.capacity() + 1];

        tokens[0] = new ComperToken(0, 0, buffer.get(0));
        for (int i = 1; i < tokens.length; ++i)
        {
            tokens[i] = new ComperToken(Integer.MAX_VALUE, i, buffer.get(Math.min(i, buffer.capacity() - 1)));
        }
        return tokens;
    }
}
