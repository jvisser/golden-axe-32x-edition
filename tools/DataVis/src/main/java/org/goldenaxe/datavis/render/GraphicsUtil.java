package org.goldenaxe.datavis.render;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.image.BufferedImage;


class GraphicsUtil
{
    private GraphicsUtil()
    {
    }

    static BufferedImage createTransparent(int width, int height)
    {
        BufferedImage image =
                new BufferedImage(width, height,
                                  BufferedImage.TYPE_INT_ARGB);
        Graphics graphics = image.getGraphics();
        graphics.setColor(new Color(0, true));
        graphics.fillRect(0, 0, image.getWidth(), image.getHeight());
        graphics.dispose();

        return image;
    }


    static Color transparent(Color color)
    {
        return new Color((color.getRGB() & 0xffffff) | 0x80000000, true);
    }
}
