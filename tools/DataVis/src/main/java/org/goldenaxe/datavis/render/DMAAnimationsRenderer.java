package org.goldenaxe.datavis.render;

import com.google.common.collect.ArrayListMultimap;
import io.kaitai.struct.KaitaiStream;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.util.ArrayList;
import java.util.List;
import org.goldenaxe.datavis.DataVisConfiguration;
import org.goldenaxe.datavis.compression.NemesisCompression;
import org.goldenaxe.datavis.parser.DmaAnimation;
import org.goldenaxe.datavis.parser.Palette;
import org.goldenaxe.datavis.util.KaitaiInputStream;
import org.goldenaxe.datavis.util.Limits;

import static java.lang.String.format;
import static org.goldenaxe.datavis.render.GraphicsUtil.createTransparent;
import static org.goldenaxe.datavis.util.StreamUtil.withCounter;


public class DMAAnimationsRenderer implements AnimationsRenderer
{
    KaitaiStream source;
    private final DataVisConfiguration.Animation animationConfiguration;
    private final int spriteMargin;

    private final PaletteRGB24 palette;
    private DmaAnimation animation;
    private int width;
    private int height;
    private int x;
    private int y;

    public DMAAnimationsRenderer(KaitaiStream source, DataVisConfiguration.Animation animationConfiguration,
                                 int spriteMargin)
    {
        this.source = source;
        this.animationConfiguration = animationConfiguration;
        this.spriteMargin = spriteMargin;
        source.seek(animationConfiguration.paletteAddress());
        palette = new PaletteRGB24(new Palette(source), true);
    }

    @Override
    public List<ArrayListMultimap<String, BufferedImage>> renderAnimations()
    {
        List<ArrayListMultimap<String, BufferedImage>> result = new ArrayList<>();

        for (int i = 0; i < animationConfiguration.animationCount(); i++)
        {
            long animationTableAddress = animationConfiguration.animationTableAddress() +
                                         ((long) animationConfiguration.animationIndex() + i) * 4;
            source.seek(animationTableAddress);
            long animationAddress = source.readU4be();
            source.seek(animationAddress);

            animation = new DmaAnimation(source,
                                         animationConfiguration.boundsTableAddress(),
                                         animationConfiguration.dmaFrameTableAddress());
            calculateImageBoundsAndOrigin();

            result.add(renderSpriteData());
        }

        return result;
    }

    private ArrayListMultimap<String, BufferedImage> renderSpriteData()
    {
        ArrayListMultimap<String, BufferedImage> result = ArrayListMultimap.create();

        long tileSourceAddress = animationConfiguration.tileDataAddresses().get(0);
        final byte[] sourceTileData;
        if (animationConfiguration.tileDataCompressed())
        {
            source.seek(tileSourceAddress);
            sourceTileData = NemesisCompression.decompress(new KaitaiInputStream(source));
        }
        else
        {
            sourceTileData = new byte[0];
        }

        animation.animationFrames()
                .forEach(withCounter((frameIndex, ap) ->
                                     {
                                         DmaAnimation.AnimationFrame animationFrame = ap.deReference();

                                         int dmaTarget = 0;
                                         byte[] tileData = new byte[0x600]; // Player dma buffer = 0x600 enemies = 0x400
                                         for (DmaAnimation.DmaTransfer dmaTransfer : animationFrame.dmaIndex()
                                                 .dmaFramePtr()
                                                 .deReference().dmaTransferList())
                                         {
                                             if (dmaTransfer.dmaLength() == -1)
                                             {
                                                 break;
                                             }

                                             if (animationConfiguration.tileDataCompressed())
                                             {
                                                 int dmaSource = dmaTransfer.sourceOffset();
                                                 for (int i = 0; i < dmaTransfer.dmaLength(); i++)
                                                 {
                                                     tileData[dmaTarget++] = sourceTileData[dmaSource++];
                                                     tileData[dmaTarget++] = sourceTileData[dmaSource++];
                                                 }
                                             }
                                             else
                                             {
                                                 long dmaSource = tileSourceAddress + dmaTransfer.sourceOffset();
                                                 source.seek(dmaSource);
                                                 for (int i = 0; i < dmaTransfer.dmaLength(); i++)
                                                 {
                                                     tileData[dmaTarget++] = source.readS1();
                                                     tileData[dmaTarget++] = source.readS1();
                                                 }
                                             }
                                         }

                                         MetaSpriteRenderer spriteRenderer =
                                                 new MetaSpriteRenderer(new TileRenderer(tileData, palette), width,
                                                                        height);
                                         spriteRenderer.render(x, y, ap.deReference().metaSprite());

                                         result.put(format("graphics_ft%d_", animation.frameTime()),
                                                    spriteRenderer.getGraphicsImage());
                                         result.put("sprite_box", spriteRenderer.getSpriteBoxImage());
                                         result.put("hit_box", spriteRenderer.getHitBoxImage());
                                         result.put(
                                                 format("overlay_x%d_y%d_s%d_m%d_", x, y, animation.markerFrameIndex(),
                                                        animation.maxFrameIndex()), renderOverlay(frameIndex));
                                     }));

        return result;
    }

    private BufferedImage renderOverlay(int frameIndex)
    {
        BufferedImage image = createTransparent(width, height);
        Graphics2D graphics = image.createGraphics();

        if (frameIndex == animation.markerFrameIndex())
        {
            graphics.setColor(Color.blue);
            graphics.fillRect(5, 5, 5, 5);
        }

        if (frameIndex == animation.maxFrameIndex())
        {
            graphics.setColor(Color.red);
            graphics.fillRect(15, 5, 5, 5);
        }

        if (spriteMargin > 0)
        {
            graphics.setColor(Color.lightGray);
            graphics.drawRect(spriteMargin, spriteMargin, width - spriteMargin * 2, height - spriteMargin * 2);
        }
        graphics.setColor(Color.black);
        graphics.fillRect(x, 0, 1, height);
        graphics.fillRect(0, y, width, 1);
        graphics.dispose();

        return image;
    }

    private void calculateImageBoundsAndOrigin()
    {
        Limits limits = animation.animationFrames().stream()
                .map(DmaAnimation.AnimationFramePtr::deReference)
                .flatMap(a -> a.metaSprite().sprites().stream())
                .map(sprite ->
                     {
                         int spriteWidth = sprite.calculatedWidth() * 8;
                         int spriteHeight = sprite.calculatedHeight() * 8;

                         return new Limits(sprite.xOffset(), sprite.xOffset() + spriteWidth,
                                           sprite.yOffset(), sprite.yOffset() + spriteHeight);
                     })
                .reduce(new Limits(), Limits::combine);

        x = Math.abs(limits.minX()) + spriteMargin;
        y = Math.abs(limits.minY()) + spriteMargin;
        width = limits.width() + spriteMargin * 2;
        height = limits.height() + spriteMargin * 2;
    }
}
