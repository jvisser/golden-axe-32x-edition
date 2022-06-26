package org.goldenaxe.datavis.render;

import com.google.common.collect.ArrayListMultimap;
import io.kaitai.struct.KaitaiStream;
import java.awt.image.BufferedImage;
import java.util.ArrayList;
import java.util.List;
import org.goldenaxe.datavis.DataVisConfiguration;
import org.goldenaxe.datavis.compression.NemesisCompression;
import org.goldenaxe.datavis.parser.Palette;
import org.goldenaxe.datavis.parser.PreLoadAnimation;
import org.goldenaxe.datavis.util.KaitaiInputStream;

import static java.lang.String.format;


public class PreLoadAnimationsRenderer implements AnimationsRenderer
{
    KaitaiStream source;
    private final DataVisConfiguration.Animation animationConfiguration;
    private final int spriteMargin;

    private final PaletteRGB24 palette;
    private PreLoadAnimation animation;

    public PreLoadAnimationsRenderer(KaitaiStream source, DataVisConfiguration.Animation animationConfiguration,
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

        TileRenderer tileRenderer = createTileRenderer();

        for (int i = 0; i < animationConfiguration.animationCount(); i++)
        {
            long animationTableAddress = animationConfiguration.animationTableAddress() +
                                         ((long) animationConfiguration.animationIndex() + i) * 4;
            source.seek(animationTableAddress);
            long animationAddress = source.readU4be();
            source.seek(animationAddress);

            animation = new PreLoadAnimation(source, animationConfiguration.boundsTableAddress());

            result.add(renderSpriteData(tileRenderer));
        }

        return result;
    }

    private ArrayListMultimap<String, BufferedImage> renderSpriteData(TileRenderer tileRenderer)
    {
        ArrayListMultimap<String, BufferedImage> result = ArrayListMultimap.create();

        SpriteCanvasFactory canvasFactory = SpriteCanvasFactory.forSprites(animation.animationFrames().stream().map(
                PreLoadAnimation.MetaSpritePtr::deReference), spriteMargin);
        animation.animationFrames()
                .forEach(ap ->
                         {
                             MetaSpriteRenderer spriteRenderer =
                                     new MetaSpriteRenderer(tileRenderer, canvasFactory);
                             spriteRenderer.render(ap.deReference());

                             result.put(format("graphics_ft%d_", animation.frameTime()),
                                        spriteRenderer.getGraphicsImage());
                             result.put("sprite_box", spriteRenderer.getSpriteBoxImage());
                             result.put("hit_box", spriteRenderer.getHitBoxImage());
                             result.put(format("overlay_x%d_y%d", canvasFactory.x(), canvasFactory.y()),
                                        renderOverlay(canvasFactory));
                         });

        return result;
    }

    private TileRenderer createTileRenderer()
    {
        byte[] sourceTileData = animationConfiguration.tileDataAddresses().stream()
                .map(tileDataAddress ->
                     {
                         source.seek(tileDataAddress);
                         return NemesisCompression.decompress(new KaitaiInputStream(source));
                     })
                .reduce(new byte[0], (bytes, bytes2) ->
                {
                    byte[] merged = new byte[bytes.length + bytes2.length];
                    System.arraycopy(bytes, 0, merged, 0, bytes.length);
                    System.arraycopy(bytes2, 0, merged, bytes.length, bytes2.length);
                    return merged;
                });
        return new TileRenderer(sourceTileData, palette);
    }

    private BufferedImage renderOverlay(SpriteCanvasFactory canvasFactory)
    {
        BufferedImage image = canvasFactory.createImage();
        canvasFactory.renderBoundsAndOrigin(image);
        return image;
    }
}
