package org.goldenaxe.datavis.render;

import java.awt.Color;
import java.util.List;


class ColorWheel
{
    private final List<Color> colors;
    private int index;

    public ColorWheel(Color... colors)
    {
        this.colors = List.of(colors);
    }

    public Color getColor(int index)
    {
        return colors.get(index % colors.size());
    }

    public Color getNextColor()
    {
        return getColor(index++);
    }

    public int getIndex()
    {
        return index % colors.size();
    }
}
