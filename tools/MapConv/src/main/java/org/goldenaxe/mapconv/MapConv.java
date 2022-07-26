package org.goldenaxe.mapconv;

import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.PrintStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Stream;
import javax.imageio.ImageIO;
import org.tiledreader.FileSystemTiledReader;
import org.tiledreader.TiledFile;
import org.tiledreader.TiledImageLayer;
import org.tiledreader.TiledMap;
import org.tiledreader.TiledTileLayer;
import picocli.CommandLine;

import static java.lang.String.format;


public class MapConv implements Callable<Integer>
{
    private static final List<String> PALETTE_NAMES = List.of("dawn", "day", "dusk", "night");
    private static final int BLOCK_SIZE = 2;
    private static final int IMG_CELL_SIZE = 8;
    private static final PrintStream STDOUT = System.out;


    private static final String BYTE_FORMAT = ".dc.b 0x%02x%n";
    private static final String WORD_FORMAT = ".dc.w 0x%04x%n";
    private static final String LONG_FORMAT = ".dc.l 0x%08x%n";

    @CommandLine.Parameters (index = "0", paramLabel = "INPUT", description = "The input map (.tmx) file")
    String inputFile;

    public static void main(String[] args)
    {
        Logger.getLogger("org.tiledreader").setLevel(Level.OFF);

        new CommandLine(new MapConv()).execute(args);
    }

    @Override
    public Integer call() throws Exception
    {
        String name = new File(inputFile).getName();
        String symbol = "map_" + name.substring(0, name.indexOf(".")).replace('-', '_');

        FileSystemTiledReader tiledReader = new FileSystemTiledReader();
        TiledMap map = tiledReader.getMap(inputFile);

        TiledImageLayer imageLayer = map.getNonGroupLayers().stream()
                .filter(TiledImageLayer.class::isInstance)
                .map(TiledImageLayer.class::cast)
                .findAny().orElseThrow();

        TiledTileLayer heightLayer = map.getNonGroupLayers().stream()
                .filter(tiledLayer -> tiledLayer.getName().equals("Height"))
                .map(TiledTileLayer.class::cast)
                .findAny().orElseThrow();

        // For 32X side
        TileMap imageTileMap = createImageTileMap(imageLayer);
        List<List<Integer>> palettes = readPalettes(map);

        // For MD side
        TileMap foregroundTileMap = createForegroundTileMap(map.getWidth(), map.getHeight());
        TileMap heightTileMap = createHeightTileMap(heightLayer, map.getWidth(), map.getHeight());

        // Export constants for relocations
        constant(symbol + "_width", map.getWidth());
        constant(symbol + "_height", map.getHeight());
        constant(symbol + "_block_width", map.getWidth() / BLOCK_SIZE);
        constant(symbol + "_block_height", map.getHeight() / BLOCK_SIZE);

        STDOUT.println(".section .rodata");

        // Export MD map data
        write2(symbol + "_foreground_blocks", WORD_FORMAT, 2, foregroundTileMap.getBlocks());
        write2(symbol + "_height_blocks", WORD_FORMAT, 2, heightTileMap.getBlocks());
        write(symbol + "_foreground_map", BYTE_FORMAT, 1, foregroundTileMap.getCompressedTileMap());
        write(symbol + "_height_map", BYTE_FORMAT, 1, heightTileMap.getCompressedTileMap());

        // Export 32X map struct
        writeAddress(symbol + "_mars", 4);
        writeLong(map.getWidth());
        writeLong(map.getHeight());
        writeLong((imageTileMap.getMap().size() + 1) / 2);   // size in In long words/32 bit values
        write(symbol + "_mars_map", WORD_FORMAT, 4, imageTileMap.getMap());
        writeLong(imageTileMap.getBlocks().size());   // size in blocks (64 bytes)
        write2(symbol + "_mars_tiles", BYTE_FORMAT, 4, imageTileMap.getBlocks());
        for (int i = 0; i < palettes.size(); i++)
        {
            write(symbol + "_palette_" + PALETTE_NAMES.get(i), WORD_FORMAT, 4, palettes.get(i));
        }

        STDOUT.println();
        return 0;
    }

    private void writeWord(int value)
    {
        STDOUT.printf(WORD_FORMAT, value);
    }

    private void writeLong(int value)
    {
        STDOUT.printf(LONG_FORMAT, value);
    }

    private void writeAddress(String symbol, int alignment)
    {
        STDOUT.printf(".global %s%n", symbol);
        STDOUT.printf(".balign %d%n", alignment);
        STDOUT.printf("%s:%n", symbol);
    }

    private void constant(String symbol, int value)
    {
        STDOUT.printf(".global %s%n", symbol);
        STDOUT.printf(".equ %s,%d%n", symbol, value);
    }

    private void write2(String symbol, String format, int alignment, List<List<Integer>> values)
    {
        write(symbol, format, alignment, values.stream().flatMap(Collection::stream).toList());
    }

    private void write(String symbol, String format, int alignment, List<Integer> values)
    {
        write(symbol, format, alignment, values.stream());
    }

    private void write(String symbol, String format, int alignment, Stream<Integer> values)
    {
        PrintStream stdout = System.out;

        writeAddress(symbol, alignment);

        values.forEach(v -> stdout.printf(format, v));
    }

    private TileMap createForegroundTileMap(int width, int height)
    {
        TileMap tileMap = new TileMap();
        List<Integer> block = List.of(0, 0, 0, 0);
        for (int i = 0; i < (width / BLOCK_SIZE) * (height / BLOCK_SIZE); i++)
        {
            tileMap.add(block);
        }
        return tileMap;
    }

    private List<List<Integer>> readPalettes(TiledMap map) throws IOException
    {
        List<List<Integer>> palettes = new ArrayList<>();
        for (String paletteName : PALETTE_NAMES)
        {
            palettes.add(readPalette((TiledFile) map.getProperty("pal-" + paletteName)));
        }
        return palettes;
    }

    private List<Integer> readPalette(TiledFile paletteFile) throws IOException
    {
        File f = new File(paletteFile.getPath());
        if (f.exists() && f.isFile())
        {
            List<Integer> rgb = readHexPalette(f);

            List<Integer> palette = new ArrayList<>(rgb.size());
            palette.addAll(rgb);
            return palette;
        }
        else
        {
            return List.of(0);
        }
    }

    private List<Integer> readHexPalette(File f) throws IOException
    {
        try (Stream<String> stream = Files.lines(Paths.get(f.getAbsolutePath())))
        {
            return stream
                    .map(s -> Integer.parseUnsignedInt(s, 16) & 0xffffff)
                    .map(rgb ->
                         {
                             Color c = new Color(rgb, false);

                             int red = c.getRed() / 8;
                             int green = c.getGreen() / 8;
                             int blue = c.getBlue() / 8;

                             return (blue << 10) | (green << 5) | red;
                         })
                    .toList();
        }
    }

    private TileMap createHeightTileMap(TiledTileLayer heightLayer, int width, int height)
    {
        TileMap tileMap = new TileMap();

        for (int r = 0; r < height; r += BLOCK_SIZE)
        {
            for (int c = 0; c < width; c += BLOCK_SIZE)
            {
                List<Integer> heightBlock = new ArrayList<>();
                for (int rr = r; rr < r + 2; rr++)
                {
                    for (int cc = c; cc < c + 2; cc++)
                    {
                        heightBlock.add((Integer) heightLayer.getTile(cc, rr).getProperty("height"));
                    }
                }
                tileMap.add(heightBlock);
            }
        }

        return tileMap;
    }

    public TileMap createImageTileMap(TiledImageLayer imageLayer) throws IOException
    {
        BufferedImage image = readImage(imageLayer.getImage().getSource());

        int rows = image.getHeight() / IMG_CELL_SIZE;
        int columns = image.getWidth() / IMG_CELL_SIZE;

        TileMap tileMap = new TileMap();
        int[] pixels = new int[IMG_CELL_SIZE * IMG_CELL_SIZE];
        for (int r = 0; r < rows; r++)
        {
            for (int c = 0; c < columns; c++)
            {
                image.getRaster().getPixels(c * IMG_CELL_SIZE, r * IMG_CELL_SIZE, IMG_CELL_SIZE, IMG_CELL_SIZE, pixels);
                List<Integer> pixelList = Arrays.stream(pixels).boxed().toList();

                tileMap.add(pixelList);
            }
        }

        return tileMap;
    }

    private BufferedImage readImage(String imagePath) throws IOException
    {
        BufferedImage image = ImageIO.read(new File(imagePath));
        if (image.getType() != BufferedImage.TYPE_BYTE_INDEXED)
        {
            throw new IllegalArgumentException(
                    format("Incorrect image type (%d). Only TYPE_BYTE_INDEXED(%d) supported.", image.getType(),
                           BufferedImage.TYPE_BYTE_INDEXED));
        }
        if (image.getWidth() % IMG_CELL_SIZE != 0 || image.getHeight() % IMG_CELL_SIZE != 0)
        {
            throw new IllegalArgumentException(format("Image dimensions must be a multiple of %dpx", IMG_CELL_SIZE));
        }
        return image;
    }
}
