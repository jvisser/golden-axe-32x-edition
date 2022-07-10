package org.goldenaxe.compression;

import java.util.ArrayList;
import java.util.List;


public class CompressionBuffer
{
    private final List<Byte> compressedResult = new ArrayList<>();
    private final List<Byte> tokenBuffer = new ArrayList<>();

    private final Endianess endianess;
    private final int maxTokens;

    private BitPacker tokenCompressionMarkers;

    public CompressionBuffer(Endianess endianess, int maxTokens)
    {
        this.endianess = endianess;
        this.maxTokens = maxTokens;
        tokenCompressionMarkers = new BitPacker(maxTokens);
    }

    public void writeToken(CompressionToken token)
    {
        token.write(tokenBuffer);

        tokenCompressionMarkers = tokenCompressionMarkers.insert(token.isCompressed());
        if (tokenCompressionMarkers.isFull())
        {
            writeTokenBatch();

            tokenBuffer.clear();
            tokenCompressionMarkers = new BitPacker(maxTokens);
        }
    }

    public List<Byte> complete()
    {
        if (!tokenCompressionMarkers.isEmpty())
        {
            tokenCompressionMarkers = tokenCompressionMarkers.padStart(maxTokens - tokenCompressionMarkers.getSize());

            writeTokenBatch();
        }

        return compressedResult;
    }

    private void writeTokenBatch()
    {
        compressedResult.addAll(endianess.toBytes(tokenCompressionMarkers.numberValue()));
        compressedResult.addAll(tokenBuffer);
    }
}
