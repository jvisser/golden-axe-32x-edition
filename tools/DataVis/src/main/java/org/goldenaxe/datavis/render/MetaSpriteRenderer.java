package org.goldenaxe.datavis.render;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import org.goldenaxe.datavis.parser.BoundsIndex;
import org.goldenaxe.datavis.parser.MetaSprite;

import static org.goldenaxe.datavis.render.GraphicsUtil.createTransparent;
import static org.goldenaxe.datavis.render.GraphicsUtil.transparent;


class MetaSpriteRenderer
{
    private final ColorWheel colorWheel =
            new ColorWheel(Color.pink, Color.magenta, Color.cyan, Color.orange, Color.lightGray, Color.blue);

    private final TileRenderer tileRenderer;
    private final BufferedImage graphicsImage;
    private final BufferedImage hitBoxImage;
    private final BufferedImage spriteBoxImage;

    public MetaSpriteRenderer(TileRenderer tileRenderer, int width, int height)
    {
        this.tileRenderer = tileRenderer;
        graphicsImage = createTransparent(width, height);
        hitBoxImage = createTransparent(width, height);
        spriteBoxImage = createTransparent(width, height);
    }

    public void render(int x, int y, MetaSprite metaSprite)
    {
        renderBounds(transparent(Color.red), x, y, metaSprite.damageBoundsIndex().bounds());
        renderBounds(transparent(Color.green), x, y, metaSprite.hurtBoundsIndex().bounds());

        metaSprite.sprites()
                .forEach(sprite ->
                         {
                             int sx = x + sprite.xOffset();
                             int sy = y + sprite.yOffset();

                             renderSpriteBox(sprite, sx, sy);

                             int tileId = 0;
                             for (int c = 0; c < sprite.calculatedWidth(); c++)
                             {
                                 int col = sprite.calculatedHflip() ? sprite.calculatedWidth() - 1 - c : c;
                                 for (int r = 0; r < sprite.calculatedHeight(); r++)
                                 {
                                     int row =  sprite.calculatedVflip() ? sprite.calculatedHeight() - 1 - r : r;

                                     tileRenderer.renderTile(graphicsImage, sprite.relativePatternId() + tileId, sx + col * 8, sy + row * 8);
                                     tileId++;
                                 }
                             }
                         });
    }

    private void renderSpriteBox(MetaSprite.Sprite sprite, int sx, int sy)
    {
        int soX = sprite.calculatedHflip() ? sx + sprite.calculatedWidth() * 8 - 2 : sx;
        int soY = sprite.calculatedVflip() ? sy + sprite.calculatedHeight() * 8 - 2 : sy;
        Graphics2D spriteBoxGraphics = spriteBoxImage.createGraphics();
        spriteBoxGraphics.setColor(transparent(colorWheel.getNextColor()));
        spriteBoxGraphics.fillRect(sx, sy, sprite.calculatedWidth() * 8, sprite.calculatedHeight() * 8);
        spriteBoxGraphics.setColor(Color.yellow);
        spriteBoxGraphics.drawRect(sx, sy, sprite.calculatedWidth() * 8, sprite.calculatedHeight() * 8);
        spriteBoxGraphics.drawRect(soX, soY, 2, 2);
        spriteBoxGraphics.dispose();
    }

    private void renderBounds(Color color, int x, int y, BoundsIndex.Bounds bounds)
    {
        Graphics2D graphics = hitBoxImage.createGraphics();
        graphics.setColor(color);
        graphics.fillRect(x + bounds.xOffset(), y + bounds.yOffset(), bounds.width(), bounds.height());
        graphics.dispose();
    }

    public BufferedImage getGraphicsImage()
    {
        return graphicsImage;
    }

    public BufferedImage getHitBoxImage()
    {
        return hitBoxImage;
    }

    public BufferedImage getSpriteBoxImage()
    {
        return spriteBoxImage;
    }
}
