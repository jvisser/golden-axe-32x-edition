package org.goldenaxe.datavis.render;

import com.google.common.collect.ArrayListMultimap;
import io.kaitai.struct.KaitaiStream;
import java.awt.image.BufferedImage;
import java.util.List;
import org.goldenaxe.datavis.DataVisConfiguration;


public class PreLoadAnimationsRenderer implements AnimationsRenderer
{
    public PreLoadAnimationsRenderer(KaitaiStream source, DataVisConfiguration.Animation animationConfiguration,
                                     int spriteMargin)
    {

    }

    @Override
    public List<ArrayListMultimap<String, BufferedImage>> renderAnimations()
    {
        return List.of(ArrayListMultimap.create());
    }
}
