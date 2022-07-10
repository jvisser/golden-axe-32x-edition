package org.goldenaxe.imgconv;

import java.awt.image.BufferedImage;
import java.awt.image.IndexColorModel;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.concurrent.Callable;
import javax.imageio.ImageIO;
import org.goldenaxe.compression.CompressionResult;
import org.goldenaxe.compression.comper.ComperCompressor;
import picocli.CommandLine;

import static java.lang.String.format;


public class ImgConv implements Callable<Integer>
{
    @CommandLine.Parameters (index = "0", paramLabel = "INPUT", description = "The input images file")
    File inputFile;

    @CommandLine.Parameters (index = "1", paramLabel = "OUTPUT", description = "The output .img file")
    File outputFile;

    public static void main(String[] args)
    {
        new CommandLine(new ImgConv()).execute(args);
    }

    @Override
    public Integer call() throws Exception
    {
        BufferedImage image = readImage();
        IndexColorModel colorModel = (IndexColorModel) image.getColorModel();


        outputFile.getParentFile().mkdirs();
        FileOutputStream fileOutputStream = new FileOutputStream(outputFile);

        byte[] pixels = readPixels(image);
        int maxColorIndex = getMaxColorIndex(pixels);

        writePalette(colorModel, maxColorIndex, fileOutputStream);

        ComperCompressor compressor = new ComperCompressor();
        CompressionResult compress = compressor.compress(pixels);
        compress.write(fileOutputStream);

        fileOutputStream.close();
        return 0;
    }

    private int getMaxColorIndex(byte[] pixels)
    {
        int max = 0;
        for (byte pixel : pixels)
        {
            max = Math.max(max, pixel & 0xff);
        }
        return max;
    }

    private byte[] readPixels(BufferedImage image)
    {
        int[] intPixels = new int[image.getWidth() * image.getHeight()];
        image.getRaster().getPixels(0, 0, image.getWidth(), image.getHeight(), intPixels);
        byte[] pixels = new byte[intPixels.length];
        for (int i = 0; i < intPixels.length; i++)
        {
            pixels[i] = (byte) intPixels[i];
        }
        return pixels;
    }

    private BufferedImage readImage() throws IOException
    {
        BufferedImage image = ImageIO.read(inputFile);
        if (image.getType() != BufferedImage.TYPE_BYTE_INDEXED)
        {
            throw new IllegalArgumentException(
                    format("Incorrect image type (%d). Only TYPE_BYTE_INDEXED supported.", image.getType()));
        }
        if (image.getWidth() != 320 && image.getHeight() != 224)
        {
            throw new IllegalArgumentException("Image width and height must be 320x224");
        }

        return image;
    }

    private void writePalette(IndexColorModel colorModel, int maxColorIndex, OutputStream outputStream)
            throws IOException
    {
        int colorCount = maxColorIndex + 1;
        outputStream.write((colorCount >> 8) & 0xff);
        outputStream.write(colorCount & 0xff);
        for (int i = 0; i < colorCount; i++)
        {
            int red = (int) Math.round((double) colorModel.getRed(i) / 8);
            int green = (int) Math.round((double) colorModel.getGreen(i) / 8);
            int blue = (int) Math.round((double) colorModel.getBlue(i) / 8);

            int color = (blue << 10) | (green << 5) | red;

            outputStream.write((color >> 8) & 0xff);
            outputStream.write(color & 0xff);
        }
    }
}
