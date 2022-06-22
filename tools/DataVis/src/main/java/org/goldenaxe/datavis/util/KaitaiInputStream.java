package org.goldenaxe.datavis.util;

import io.kaitai.struct.KaitaiStream;
import java.io.IOException;
import java.io.InputStream;


public class KaitaiInputStream extends InputStream
{
    private final KaitaiStream kaitaiStream;

    public KaitaiInputStream(KaitaiStream kaitaiStream)
    {
        this.kaitaiStream = kaitaiStream;
    }

    @Override
    public int read() throws IOException
    {
        return kaitaiStream.readU1();
    }
}
