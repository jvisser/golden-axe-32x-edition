package org.goldenaxe.datavis.render;

import java.awt.image.BufferedImage;


class TileRenderer
{
    private final byte[] tileData;

    private final PaletteRGB24 palette;

    TileRenderer(byte[] tileData, PaletteRGB24 palette)
    {
        this.tileData = tileData;
        this.palette = palette;
    }

    public void renderTile(BufferedImage image, int attr, int x, int y)
    {
        int pixelOffset = (attr & 0x7ff) * 32;
        boolean hflip = ((attr & 0x800) != 0);
        boolean vflip = ((attr & 0x1000) != 0);
        for (int r = 0; r < 8; r++)
        {
            for (int c = 0; c < 4; c++)
            {
                byte pixel1 = tileData[pixelOffset++];

                for (int i = 0; i < 2; i++)
                {
                    int px = c * 2 + i;
                    int py = r;

                    if (hflip)
                    {
                        px = 7 - px;
                    }

                    if (vflip)
                    {
                        py = 7 - py;
                    }

                    int colorIndex = (pixel1 >>> ((i ^ 1) << 2)) & 0x0f;

                    image.setRGB(x + px, y + py, palette.getRGB(colorIndex));
                }
            }
        }
    }
}
