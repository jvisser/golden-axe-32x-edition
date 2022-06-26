package org.goldenaxe.datavis.render;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.image.BufferedImage;
import java.util.stream.Stream;
import org.goldenaxe.datavis.parser.MetaSprite;
import org.goldenaxe.datavis.util.Limits;

import static org.goldenaxe.datavis.render.GraphicsUtil.createTransparent;


record SpriteCanvasFactory(int x, int y, int width, int height, int margin)
{
    public static SpriteCanvasFactory forSprites(Stream<MetaSprite> metaSpriteStream, int margin)
    {
        Limits limits = metaSpriteStream
                .flatMap(metaSprite -> metaSprite.sprites().stream())
                .map(sprite ->
                     {
                         int spriteWidth = sprite.calculatedWidth() * 8;
                         int spriteHeight = sprite.calculatedHeight() * 8;

                         return new Limits(sprite.xOffset(), sprite.xOffset() + spriteWidth,
                                           sprite.yOffset(), sprite.yOffset() + spriteHeight);
                     })
                .reduce(new Limits(), Limits::combine);

        int x = Math.abs(limits.minX()) + margin;
        int y = Math.abs(limits.minY()) + margin;
        int width = limits.width() + margin * 2;
        int height = limits.height() + margin * 2;

        return new SpriteCanvasFactory(x, y, width, height, margin);
    }

    public BufferedImage createImage()
    {
        return createTransparent(width, height);
    }

    public void renderBoundsAndOrigin(BufferedImage image)
    {
        Graphics graphics = image.getGraphics();
        if (margin > 0)
        {
            graphics.setColor(Color.lightGray);
            graphics.drawRect(margin, margin, width - margin * 2, height - margin * 2);
        }
        graphics.setColor(Color.black);
        graphics.fillRect(x, 0, 1, height);
        graphics.fillRect(0, y, width, 1);
        graphics.dispose();
    }
}
