package org.goldenaxe.datavis.render;

import java.util.HashMap;
import java.util.Map;
import org.goldenaxe.datavis.parser.Palette;


public class PaletteRGB24
{
    private static final HashMap<Integer, Integer> componentColorRamp = new HashMap<>(
            Map.of(0, 0,
                   1, 52,
                   2, 87,
                   3, 116,
                   4, 144,
                   5, 172,
                   6, 206,
                   7, 255));

    private final Integer[] colors;

    public PaletteRGB24(Palette palette)
    {
        colors = palette.colors().stream()
                .map(bgr3bit -> 0xff000000 |
                                componentColorRamp.get((bgr3bit >> 9) & 0x07) |
                                componentColorRamp.get((bgr3bit >> 5) & 0x07) << 8 |
                                componentColorRamp.get((bgr3bit >> 1) & 0x07) << 16)
                .toArray(Integer[]::new);
    }

    public int getRGB(int index)
    {
        return colors[index];
    }
}
