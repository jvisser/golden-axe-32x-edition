package org.goldenaxe.datavis.compression;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;


public class GATilemapCompression
{
    private GATilemapCompression()
    {
    }

    public static List<Integer> decompress(InputStream inputStream)
    {
        List<Integer> output = new ArrayList<>();

        try
        {
            int value;
            while ((value = inputStream.read()) != -1)
            {
                if (value == 0)
                {
                    break;
                }

                // Fill
                if ((value & 0x80) == 0)
                {
                    value &= 0x7f;

                    int fill = inputStream.read();
                    for (int i = 0; i < value; i++)
                    {
                        output.add(fill);
                    }
                }
                // Repeat token
                else if ((value & 0xc0) == 0x80)
                {
                    int repeatToken = inputStream.read();
                    int tokenValue = inputStream.read();

                    InputStream in = new ByteArrayInputStream(new byte[]{(byte)repeatToken, (byte)tokenValue});
                    List<Integer> decompressedToken = decompress(in);

                    value &= 0x3f;
                    for (int i = 0; i<value; i++)
                    {
                        output.addAll(decompressedToken);
                    }
                }
                // Uncompressed
                else if ((value & 0xe0) == 0xc0)
                {
                    value &= 0x1f;
                    for (int i = 0; i<value; i++)
                    {
                        output.add(inputStream.read());
                    }
                }
                // Increment
                else
                {
                    value &= 0x1f;

                    int increment = inputStream.read();
                    for (int i = 0; i<value; i++)
                    {
                        output.add(increment++);
                    }
                }
            }
            return output;
        }
        catch (IOException e)
        {
            throw new DecompressionException(e);
        }
    }
}
