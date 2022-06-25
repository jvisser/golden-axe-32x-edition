package org.goldenaxe.datavis.util;


public record Limits(int minX, int maxX, int minY, int maxY)
{
    public Limits()
    {
        this(0, 0, 0, 0);
    }

    public Limits combine(Limits other)
    {
        return new Limits(
                Math.min(minX, other.minX),
                Math.max(maxX, other.maxX),
                Math.min(minY, other.minY),
                Math.max(maxY, other.maxY));
    }

    public int width()
    {
        return maxX - minX + 1;
    }

    public int height()
    {
        return maxY - minY + 1;
    }
}
