package org.goldenaxe.mapconv;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;


class TileMap
{
    private final Map<List<Integer>, Integer> blockIndex = new LinkedHashMap<>();
    private final List<Integer> map = new ArrayList<>();

    public void add(List<Integer> block)
    {
        map.add(blockIndex.computeIfAbsent(block, p -> blockIndex.size()));
    }

    List<List<Integer>> getBlocks()
    {
        return blockIndex.keySet().stream().toList();
    }

    List<Integer> getMap()
    {
        return map;
    }

    List<Integer> getCompressedTileMap()
    {
        List<Integer> compressedMap = new ArrayList<>();

        List<Integer> uncompressedTokens = new ArrayList<>();
        for (int i = 0; i < map.size(); i++)
        {
            int count = 1;
            while (i + 1 < map.size() && Objects.equals(map.get(i), map.get(i + 1)))
            {
                count++;
                i++;
            }

            if (count == 1)
            {
                uncompressedTokens.add(map.get(i));
            }
            else
            {
                if (!uncompressedTokens.isEmpty())
                {
                    List<List<Integer>> split = split(uncompressedTokens, 31);
                    split.forEach(integers ->
                                  {
                                      compressedMap.add(integers.size() | 0xc0);
                                      compressedMap.addAll(integers);
                                  });
                    uncompressedTokens.clear();
                }

                int fillTokens = count / 127;
                while (fillTokens > 0)
                {
                    int repeat = Math.min(fillTokens, 63);

                    compressedMap.add(repeat | 0x80);
                    compressedMap.add(127);
                    compressedMap.add(map.get(i));

                    fillTokens -= repeat;
                    count -= repeat * 127;
                }

                if (count != 0)
                {
                    compressedMap.add(count);
                    compressedMap.add(map.get(i));
                }
            }
        }

        if (!uncompressedTokens.isEmpty())
        {
            List<List<Integer>> split = split(uncompressedTokens, 31);
            split.forEach(integers ->
                          {
                              compressedMap.add(integers.size() | 0xc0);
                              compressedMap.addAll(integers);
                          });
        }

        // Terminate
        compressedMap.add(0);

        return compressedMap;
    }

    private List<List<Integer>> split(List<Integer> uncompressedTokens, int maxSize)
    {
        List<List<Integer>> split = new ArrayList<>();

        int index = 0;
        while (uncompressedTokens.size() - index > maxSize)
        {
            split.add(uncompressedTokens.subList(index, index + maxSize));

            index += maxSize;
        }

        List<Integer> lastSplit = uncompressedTokens.subList(index, Math.min(index + maxSize, uncompressedTokens.size()));
        if (!lastSplit.isEmpty())
        {
            split.add(lastSplit);
        }

        return split;
    }
}
