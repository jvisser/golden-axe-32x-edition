package org.goldenaxe.datavis.render;

import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.ImmutableMultimap;
import io.kaitai.struct.KaitaiStream;
import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.stream.Collectors;
import org.goldenaxe.datavis.DataVisConfiguration;
import org.goldenaxe.datavis.compression.GATilemapCompression;
import org.goldenaxe.datavis.compression.NemesisCompression;
import org.goldenaxe.datavis.parser.MapBaseYPositionTable;
import org.goldenaxe.datavis.parser.MapFile;
import org.goldenaxe.datavis.parser.Palette;
import org.goldenaxe.datavis.util.KaitaiInputStream;

import static java.lang.String.format;
import static org.goldenaxe.datavis.util.StreamUtil.withCounter;


public class MapRenderer
{
    private static final Color LEGEND_COLOR = new Color(1f, 1f, 1f, 0.5f);
    private static final Font LEGEND_FONT = new Font(Font.SANS_SERIF, Font.PLAIN, 9);

    private final ColorWheel colorWheel =
            new ColorWheel(Color.yellow, Color.pink, Color.magenta, Color.cyan, Color.orange, Color.lightGray);
    private final KaitaiStream source;
    private final MapFile mapFile;
    private final MapBaseYPositionTable mapBaseYPositionTable;
    private final List<Integer> heightTilemap;
    private final List<MapFile.MapEntityLoadGroup> customLoadGroups;
    private final MapFile.MapEntityLoadTriggerList customEntityTriggerList;

    public MapRenderer(KaitaiStream source, DataVisConfiguration.MapFile mapConfiguration)
    {
        this(source, mapConfiguration, -1);
    }

    public MapRenderer(KaitaiStream source, DataVisConfiguration.MapFile mapConfiguration,
                       int customEntityTriggerListAddress)
    {
        this.source = source;
        source.seek(mapConfiguration.address());
        mapFile = new MapFile(source,
                              mapConfiguration.getEntityLoadSlotDescriptorTableAddress(),
                              mapConfiguration.getEntityGroupGraphicsTableAddress(),
                              mapConfiguration.getEntityGroupPaletteTableAddress(),
                              mapConfiguration.getEntityGroupTileAddressTable());
        heightTilemap = readTilemap(mapFile.compressedHeightBlockMapDataAddress(),
                                    mapFile.heightBlockDataAddress(),
                                    0xffff);
        customLoadGroups = Optional.ofNullable(mapConfiguration.customEntityLoadGroupAddresses())
                .map(loadGroupAddresses -> loadGroupAddresses.stream()
                        .map(address ->
                             {
                                 source.seek(address);
                                 return new MapFile.MapEntityLoadGroup(source);
                             })
                        .toList())
                .orElse(Collections.emptyList());
        if (customEntityTriggerListAddress >= 0)
        {
            source.seek(customEntityTriggerListAddress);
            customEntityTriggerList = new MapFile.MapEntityLoadTriggerList(
                    source, null, mapFile);
        }
        else
        {
            customEntityTriggerList = null;
        }
        if (mapConfiguration.baseYTableAddress() != 0)
        {
            source.seek(mapConfiguration.baseYTableAddress());
            mapBaseYPositionTable = new MapBaseYPositionTable(source);
        }
        else
        {
            mapBaseYPositionTable = null;
        }
    }

    public ArrayListMultimap<String, BufferedImage> renderLayers()
    {
        ArrayListMultimap<String, BufferedImage> result = ArrayListMultimap.create();

        result.put("base_y_map", renderBaseY());
        result.put("gfx_map", renderTileMap());
        result.put("height_map", renderHeightMap());
        result.put("event_map", renderEventTriggers());
        result.putAll(renderEntities());

        return result;
    }

    private BufferedImage renderBaseY()
    {
        BufferedImage image = createImage();
        if (mapBaseYPositionTable != null)
        {
            Graphics2D graphics = image.createGraphics();

            ArrayList<MapBaseYPositionTable.MapBaseYPositionStart> positionStarts =
                    mapBaseYPositionTable.baseYPositionArray();

            int currentX = 0;
            for (MapBaseYPositionTable.MapBaseYPositionStart positionStart : positionStarts)
            {
                if (positionStart.mapXEnd() <= currentX)
                {
                    break;
                }
                graphics.setColor(Color.green);
                graphics.drawLine(currentX, positionStart.baseY(), positionStart.mapXEnd(), positionStart.baseY());
                graphics.setColor(Color.black);
                drawLabelBox(graphics, currentX, positionStart.baseY() - 25, String.valueOf(positionStart.baseY()),
                             Color.white);
                currentX = positionStart.mapXEnd();
            }
        }
        return image;
    }

    private BufferedImage renderEventTriggers()
    {
        Color transparentBlack = transparent(Color.black);

        int mapCenter = mapFile.calculatedHeightPixels() / 2;
        BufferedImage image = createImage();
        Graphics2D graphics = image.createGraphics();
        graphics.setColor(transparent(Color.white));
        graphics.fillRect(0, mapCenter - 2, mapFile.calculatedWidthPixels(), 4);
        graphics.setColor(transparentBlack);
        graphics.fillRect(0, mapCenter - 1, mapFile.calculatedWidthPixels(), 2);
        graphics.setFont(LEGEND_FONT);

        mapFile.events().deReference()
                .forEach(withCounter(
                        (counter, mapEventTrigger) ->
                        {
                            if (mapEventTrigger.hScrollTrigger() == 0x500)//out of scroll bounds used as terminator
                            {
                                return;
                            }

                            Color color = transparent(colorWheel.getColor((int) mapEventTrigger.eventId().id() / 4));
                            int ly;
                            int offs = 10 * (2 + ((counter & 0x06) >> 1));
                            if ((counter & 0x01) == 1)
                            {
                                graphics.setColor(color);
                                graphics.fillRect(mapEventTrigger.hScrollTrigger() - 2, mapCenter - offs, 4, offs - 1);
                                graphics.setColor(transparentBlack);
                                graphics.fillRect(mapEventTrigger.hScrollTrigger() - 1, mapCenter - offs + 1, 2,
                                                  offs - 2);
                                ly = mapCenter - 20 - offs;
                            }
                            else
                            {
                                graphics.setColor(color);
                                graphics.fillRect(mapEventTrigger.hScrollTrigger() - 2, mapCenter + 1, 4, offs - 1);
                                graphics.setColor(transparentBlack);
                                graphics.fillRect(mapEventTrigger.hScrollTrigger() - 1, mapCenter + 1, 2, offs - 2);
                                ly = mapCenter + offs;
                            }
                            drawLabelBox(graphics, mapEventTrigger.hScrollTrigger() + 5, ly,
                                         format("%d: %s($%02x)", mapEventTrigger.hScrollTrigger(),
                                                mapEventTrigger.eventId().name(),
                                                mapEventTrigger.eventData()), color);
                        }));
        graphics.dispose();
        return image;
    }

    private ImmutableMultimap<String, BufferedImage> renderEntities()
    {
        BufferedImage image = createImage();
        BufferedImage labelImage = createImage();
        Graphics2D graphics = image.createGraphics();
        Graphics2D labelGraphics = labelImage.createGraphics();
        graphics.setFont(LEGEND_FONT);
        labelGraphics.setFont(LEGEND_FONT);

        renderPlayerPosition(graphics, labelGraphics, "P1", mapFile.player1EntityX(), mapFile.player1BaseYOffset());
        renderPlayerPosition(graphics, labelGraphics, "P2", mapFile.player2EntityX(), mapFile.player2BaseYOffset());
        if (customEntityTriggerList != null)
        {
            renderEntityTriggerList(customEntityTriggerList.triggerList(), graphics, labelGraphics);
        }
        else
        {
            renderEntityTriggerList(mapFile.entityLoadData().deReference().triggerList(), graphics, labelGraphics);
        }

        customLoadGroups.forEach(withCounter(
                (counter, mapEntityLoadGroup) ->
                        renderEntityLoadGroup(graphics, labelGraphics,
                                              0, 30 + colorWheel.getIndex() * 20, 0,
                                              counter, mapEntityLoadGroup)));
        graphics.dispose();
        labelGraphics.dispose();
        return ImmutableMultimap.of("entity_position_map", image,
                                    "entity_label_map", labelImage);
    }

    private void renderEntityTriggerList(
            ArrayList<MapFile.MapEntityLoadTriggerList.MapEntityLoadTrigger> mapEntityLoadTriggers,
            Graphics2D graphics, Graphics2D labelGraphics)
    {
        mapEntityLoadTriggers.stream()
                .filter(mapEntityLoadTrigger -> mapEntityLoadTrigger.hScrollTrigger() != 0xffff)
                .forEach(trigger ->
                         {
                             Color color = colorWheel.getNextColor();
                             graphics.setColor(color);
                             graphics.fillRect(trigger.hScrollTrigger(), 0, 1, mapFile.calculatedHeightPixels());
                             int screenWidthIndicatorY = 30 + colorWheel.getIndex() * 20;
                             graphics.fillRect(trigger.hScrollTrigger(), screenWidthIndicatorY, 320, 1);
                             graphics.fillRect(trigger.hScrollTrigger() + 320, screenWidthIndicatorY, 1, 10);
                             drawLabelBox(graphics, trigger.hScrollTrigger() + 2, 2, "" + trigger.hScrollTrigger(),
                                          Color.black);
                             graphics.setColor(color);
                             labelGraphics.setColor(transparent(color));

                             int slotIndex = trigger.loadIndex().loadSlotIndex();
                             trigger.loadIndex().loadSlotAddress().deReference().loadGroups()
                                     .stream().map(MapFile.MapEntityLoadTriggerList.MapEntityLoadGroupPtr::deReference)
                                     .forEach(withCounter(
                                             (groupIndex, loadGroup) ->
                                                     renderEntityLoadGroup(graphics, labelGraphics,
                                                                           trigger.hScrollTrigger(),
                                                                           screenWidthIndicatorY, slotIndex,
                                                                           groupIndex, loadGroup)));
                         });
    }

    private void renderEntityLoadGroup(Graphics2D graphics, Graphics2D labelGraphics,
                                       int hScrollTrigger, int screenWidthIndicatorY,
                                       int slotIndex, int groupId, MapFile.MapEntityLoadGroup loadGroup)
    {
        String groupIdLabel = format("[%d|%d]", slotIndex, groupId);
        String groupLabel = groupIdLabel + ((loadGroup.canLoadWithActiveEnemies() != 0) ? "+" : "");
        drawLabelBox(labelGraphics, hScrollTrigger + 2,
                     screenWidthIndicatorY + 2 + groupId * 20,
                     groupLabel, Color.BLACK);
        loadGroup.entityInstanceData()
                .forEach(entityInstance ->
                         {
                             int x = entityInstance.entityX() - 128 + hScrollTrigger;
                             int baseY = entityInstance.entityY();
                             int y = baseY + Math.min(sampleHeight(baseY, x - 8), sampleHeight(baseY, x + 8)) - 0x8000;
                             graphics.fillOval(x - 5, baseY - 5, 10, 10);
                             if (baseY != y)
                             {
                                 graphics.fillRect(x - 5, y, 10, 1);
                                 graphics.drawLine(x, baseY, x, y);
                                 int ydisp = (baseY > y) ? 5 : -5;
                                 graphics.drawLine(x, y, x - 5, y + ydisp);
                                 graphics.drawLine(x, y, x + 5, y + ydisp);
                             }
                             drawLabelBox(labelGraphics, x + 5, y,
                                          format("%s:%s", groupIdLabel, entityInstance.entityId().name()), Color.black);
                         });
    }

    private int sampleHeight(int y, int x)
    {
        return heightTilemap.get((y >> 3) * mapFile.calculatedWidthPatterns() +
                                 (Math.min(mapFile.calculatedWidthPixels() - 1, x) >> 3));
    }

    private void renderPlayerPosition(Graphics2D graphics, Graphics2D labelGraphics, String label, int px,
                                      int pBaseYDisp)
    {
        if (mapBaseYPositionTable == null)
        {
            return;
        }

        int mapX = mapFile.initialHorizontalScrollBlocks() * 16 + Math.max(0, px - 128);
        int baseY = mapBaseYPositionTable.baseYPositionArray().stream()
                            .filter(ps -> ps.mapXEnd() >= mapX)
                            .findFirst()
                            .orElseGet(() -> mapBaseYPositionTable.baseYPositionArray()
                                    .get(mapBaseYPositionTable.numberPositionChanges())).baseY() + pBaseYDisp;

        int height = sampleHeight(baseY, mapX);


        Color gold = new Color(0xFFD700, false);
        graphics.setColor(gold);
        labelGraphics.setColor(gold);

        int screenY = baseY + height - 0x8000;
        int screenX = mapFile.initialHorizontalScrollBlocks() * 16 + px - 128;
        if (screenX < 20) // Ensure circle is visible with 10 pixel margin
        {
            screenX += 140;
            graphics.fillOval(screenX - 10, baseY - 10, 20, 20);
            graphics.drawLine(px - 128, baseY, screenX, baseY);
            graphics.drawLine(screenX, baseY, screenX, screenY);
            drawLabelBox(labelGraphics, screenX + 15, screenY - 20, format("%s (x: %d)", label, px - 128), Color.black);
        }
        else
        {
            graphics.fillOval(screenX - 10, baseY - 10, 20, 20);
            graphics.drawLine(screenX, baseY, screenX, screenY);
            drawLabelBox(labelGraphics, screenX + 15, screenY - 20, label, Color.black);
        }
    }

    private BufferedImage renderTileMap()
    {
        List<Integer> graphicsTilemap = readTilemap(mapFile.compressedGraphicsBlockMapDataAddress(),
                                                    mapFile.graphicsBlockDataAddress(),
                                                    0);

        source.seek(mapFile.tileData().get(0).nemesisDataAddress());
        byte[] tileData = NemesisCompression.decompress(new KaitaiInputStream(source));
        Palette backgroundPalette = mapFile.palettes().stream()
                .map(MapFile.PalettePtr::deReference)
                .filter(palette -> palette.colorOffset() == 0x60)
                .findAny()
                .orElseThrow();

        TileRenderer tileRenderer = new TileRenderer(tileData, new PaletteRGB24(backgroundPalette));
        BufferedImage image = createImage();
        for (int r = 0; r < mapFile.calculatedHeightPatterns(); r++)
        {
            for (int c = 0; c < mapFile.calculatedWidthPatterns(); c++)
            {
                int tileAttr = graphicsTilemap.get(r * mapFile.calculatedWidthPatterns() + c);
                tileRenderer.renderTile(image, tileAttr, c * 8, r * 8);
            }
        }

        return image;
    }

    private BufferedImage renderHeightMap()
    {
        TreeSet<Integer> heightValues = heightTilemap.stream()
                .filter(integer -> integer != 0x8200 && integer != 0x7e00 && integer != 0xffff)
                .collect(Collectors.toCollection(TreeSet::new));

        Map<Integer, Color> colorGradient = new TreeMap<>();
        // float highRange = (float)0x8000 - heightValues.first();
        float highRange = (float) 0x8000 - 0x7f40;
        heightValues.headSet(0x8000)
                .forEach(height ->
                         {
                             float relativeHeight = 0x8000 - (float) height;
                             float gradient = relativeHeight / highRange;
                             colorGradient.put(height, new Color(1, 1 - gradient, 1 - gradient));
                         });
        // float lowRange = (float)heightValues.last() - 0x8000;
        float lowRange = (float) 0x8040 - 0x8000;
        heightValues.tailSet(0x8001)
                .forEach(height ->
                         {
                             float relativeHeight = (float) height - 0x8000;
                             float gradient = relativeHeight / lowRange;
                             colorGradient.put(height, new Color(1 - gradient, 1, 1 - gradient));
                         });
        colorGradient.put(0xffff, new Color(0, true));
        colorGradient.put(0x8200, Color.black);
        colorGradient.put(0x8000, Color.white);
        colorGradient.put(0x7e00, Color.blue);

        BufferedImage image = createImage();
        Graphics graphics = image.getGraphics();
        for (int r = 0; r < mapFile.calculatedHeightPatterns(); r++)
        {
            for (int c = 0; c < mapFile.calculatedWidthPatterns(); c++)
            {
                Integer heightValue = heightTilemap.get(r * mapFile.calculatedWidthPatterns() + c);

                graphics.setColor(colorGradient.get(heightValue));
                graphics.fillRect(c * 8, r * 8, 8, 8);
            }
        }
        graphics.setFont(LEGEND_FONT);
        graphics.setColor(LEGEND_COLOR);
        graphics.fillRect(10, 10, 100, colorGradient.size() * 20 - 10);
        Iterator<Map.Entry<Integer, Color>> iterator = colorGradient.entrySet().iterator();
        int y = 20;
        for (int i = 0; i < colorGradient.size(); i++)
        {
            Map.Entry<Integer, Color> next = iterator.next();
            if (next.getKey() != 0xffff)
            {
                graphics.setColor(next.getValue());
                graphics.fillRect(20, y, 10, 10);
                graphics.setColor(Color.black);
                graphics.drawString("" + (next.getKey() - 0x8000), 40, y + 10);
                y += 20;
            }
        }
        graphics.dispose();
        return image;
    }

    private List<Integer> readTilemap(long compressedTilemapAddress, long blockAddress, int unmappedValue)
    {
        source.seek(compressedTilemapAddress);
        List<Integer> tilemap = GATilemapCompression.decompress(new KaitaiInputStream(source));

        Integer[] cellValues = new Integer[mapFile.heightBlocks() * mapFile.widthBlocks() * 4];
        Arrays.fill(cellValues, unmappedValue);

        for (int r = 0; r < mapFile.heightBlocks(); r++)
        {
            for (int c = 0; c < mapFile.widthBlocks(); c++)
            {
                int index = r * mapFile.widthBlocks() + c;
                // For some maps (Duel) the map dimensions do not match the tile map data
                if (index < tilemap.size())
                {
                    Integer blockId = tilemap.get(index);
                    if (blockId != 0xff)
                    {
                        source.seek(blockAddress + blockId * 8);
                        for (int rr = 0; rr < 2; rr++)
                        {
                            for (int cc = 0; cc < 2; cc++)
                            {
                                cellValues[(r * 2 + rr) * mapFile.calculatedWidthPatterns() + (c * 2) + cc] =
                                        source.readU2be();
                            }
                        }
                    }
                }
            }
        }

        return new ArrayList<>(Arrays.asList(cellValues));
    }

    private BufferedImage createImage()
    {
        BufferedImage image =
                new BufferedImage(mapFile.calculatedWidthPixels(), mapFile.calculatedHeightPixels(),
                                  BufferedImage.TYPE_INT_ARGB);
        Graphics graphics = image.getGraphics();
        graphics.setColor(new Color(0, true));
        graphics.fillRect(0, 0, image.getWidth(), image.getHeight());
        graphics.dispose();

        return image;
    }

    private void drawLabelBox(Graphics2D graphics, int x, int y, String label, Color fontColor)
    {
        FontMetrics fontMetrics = graphics.getFontMetrics();
        int stringWidth = fontMetrics.stringWidth(label);
        if (x < 0 || x >= mapFile.calculatedWidthPixels() - stringWidth)
        {
            label = format("%s|x:%d", label, x);
            stringWidth = fontMetrics.stringWidth(label);
            x = Math.min(Math.max(0, x), mapFile.calculatedWidthPixels() - stringWidth - 6);
        }
        int labelHeight = fontMetrics.getHeight() + 6;
        if (y >= mapFile.calculatedHeightPixels() - labelHeight)
        {
            label = format("%s|y:%d", label, y);
            stringWidth = fontMetrics.stringWidth(label);
            y = mapFile.calculatedHeightPixels() - labelHeight;
            x = Math.min(x, mapFile.calculatedWidthPixels() - stringWidth - 6);
        }
        graphics.fillRect(x, y, stringWidth + 6, labelHeight);
        Color color = graphics.getColor();
        graphics.setColor(fontColor);
        graphics.drawString(label, x + 3, y + 3 + fontMetrics.getAscent());
        graphics.setColor(color);
    }

    Color transparent(Color color)
    {
        return new Color((color.getRGB() & 0xffffff) | 0x80000000, true);
    }
}