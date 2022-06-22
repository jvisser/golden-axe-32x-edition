package org.goldenaxe.datavis;

import com.google.common.collect.ArrayListMultimap;
import io.kaitai.struct.KaitaiStream;
import io.kaitai.struct.RandomAccessFileKaitaiStream;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.Callable;
import javax.imageio.ImageIO;
import org.goldenaxe.datavis.render.MapRenderer;
import picocli.CommandLine;


public class DataVis implements Callable<Integer>
{
    @CommandLine.Option (names = {
            "-c", "--config"
    }, required = true, paramLabel = "CONFIG", description = "The configuration file")
    File configurationFile;

    @CommandLine.Option (names = {
            "-o", "--output-directory"
    }, required = true, paramLabel = "OUTPUT", description = "The output directory")
    File outputDirectory;

    @CommandLine.Parameters (index = "0", paramLabel = "INPUT", description = "The input ROM file")
    File inputFile;

    public static void main(String[] args)
    {
        new CommandLine(new DataVis()).execute(args);
    }

    @Override
    public Integer call() throws Exception
    {
        DataVisConfiguration config = DataVisConfiguration.read(configurationFile);

        RandomAccessFileKaitaiStream kaitaiStream = new RandomAccessFileKaitaiStream(inputFile.getAbsolutePath());

        dumpMaps(config.maps(), kaitaiStream);

        return 0;
    }

    private void dumpMaps(Map<String, DataVisConfiguration.MapFile> mapsByName, KaitaiStream kaitaiStream)
    {
        // @formatter:off
        Optional.ofNullable(mapsByName)
            .ifPresent(maps -> maps
                .forEach((name, mapFileConfig) ->
                 {
                     String dir = "maps" + File.separator + name;

                     writeImages(new File(outputDirectory, dir),
                                 new MapRenderer(kaitaiStream, mapFileConfig).renderLayers());

                     Optional.ofNullable(mapFileConfig.customEntityTriggerLists())
                             .ifPresent(customEntityTriggerLists ->
                                    customEntityTriggerLists.forEach(customEntityTriggerList ->
                                         writeImages(new File(outputDirectory, dir + "-" + customEntityTriggerList.name()),
                                                     new MapRenderer(kaitaiStream, mapFileConfig, customEntityTriggerList.address())
                                                             .renderLayers())));
        }));
        // @formatter:on
    }

    private static void writeImages(File dir, ArrayListMultimap<String, BufferedImage> imageMap)
    {
        imageMap.keys()
                .forEach(key ->
                         {
                             List<BufferedImage> images = imageMap.get(key);
                             for (int i = 0; i < images.size(); i++)
                             {
                                 try
                                 {
                                     File output = new File(dir, key + ((images.size() > 1) ? i : "") + ".png");
                                     dir.mkdirs();
                                     ImageIO.write(images.get(i), "PNG", output);
                                 }
                                 catch (IOException e)
                                 {
                                     throw new RuntimeException(e);
                                 }
                             }
                         });
    }
}
