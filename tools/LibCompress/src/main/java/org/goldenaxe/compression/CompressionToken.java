package org.goldenaxe.compression;

import java.util.List;


public interface CompressionToken
{
    void write(List<Byte> buffer);

    boolean isCompressed();
}
