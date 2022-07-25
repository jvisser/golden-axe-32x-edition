package org.goldenaxe.compression;

import java.io.IOException;
import java.io.OutputStream;
import java.util.List;


public class CompressionResult
{
    private final List<Byte> bytes;
    private final int uncompressedSize;

    public CompressionResult(List<Byte> bytes, int uncompressedSize)
    {
        this.bytes = bytes;
        this.uncompressedSize = uncompressedSize;
    }

    public List<Byte> getBytes()
    {
        return bytes;
    }

    public void write(OutputStream outputStream) throws IOException
    {
        for (Byte b : bytes)
        {
            outputStream.write(b);
        }
    }

    public int getCompressedSize()
    {
        return bytes.size();
    }

    public int getUncompressedSize()
    {
        return uncompressedSize;
    }

    public double getCompressionRatio()
    {
        return (double) getCompressedSize() / uncompressedSize;
    }
}
