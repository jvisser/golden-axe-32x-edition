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

import static java.lang.String.format;
import static org.goldenaxe.datavis.util.StreamUtil.withCounter;


public class DMAAnimationsRenderer implements AnimationsRenderer
{
    KaitaiStream source;
    private final DataVisConfiguration.Animation animationConfiguration;
    private final int spriteMargin;
    private final PaletteRGB24 palette;
    private DmaAnimation animation;

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
            result.add(renderSpriteData());
        }

        return result;
    }

    private ArrayListMultimap<String, BufferedImage> renderSpriteData()
    {
        ArrayListMultimap<String, BufferedImage> result = ArrayListMultimap.create();

        SpriteCanvasFactory canvasFactory = SpriteCanvasFactory.forSprites(animation.animationFrames().stream().map(
                animationFramePtr -> animationFramePtr.deReference().metaSprite()), spriteMargin);

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

                                         byte[] tileData = getTileData(tileSourceAddress, sourceTileData, animationFrame);

                                         MetaSpriteRenderer spriteRenderer =
                                                 new MetaSpriteRenderer(new TileRenderer(tileData, palette), canvasFactory);
                                         spriteRenderer.render(ap.deReference().metaSprite());

                                         result.put(format("graphics_ft%d_", animation.frameTime()),
                                                    spriteRenderer.getGraphicsImage());
                                         result.put("sprite_box", spriteRenderer.getSpriteBoxImage());
                                         result.put("hit_box", spriteRenderer.getHitBoxImage());
                                         result.put(
                                                 format("overlay_x%d_y%d_s%d_m%d_", canvasFactory.x(), canvasFactory.y(), animation.markerFrameIndex(),
                                                        animation.maxFrameIndex()), renderOverlay(canvasFactory, frameIndex));
                                     }));

        return result;
    }

    private byte[] getTileData(long tileSourceAddress, byte[] sourceTileData, DmaAnimation.AnimationFrame animationFrame)
    {
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
        return tileData;
    }

    private BufferedImage renderOverlay(SpriteCanvasFactory canvasFactory, int frameIndex)
    {
        BufferedImage image = canvasFactory.createImage();
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
        canvasFactory.renderBoundsAndOrigin(image);
        return image;
    }
}
