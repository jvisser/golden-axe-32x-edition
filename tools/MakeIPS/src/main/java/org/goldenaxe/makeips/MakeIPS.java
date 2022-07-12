package org.goldenaxe.makeips;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.IntBuffer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.stream.Collectors;
import picocli.CommandLine;


public class MakeIPS implements Callable<Integer>
{
    private static final String HEADER = "PATCH";
    private static final String EOF = "EOF";

    @CommandLine.Option (names = {
            "-p", "--patch-content-file"
    }, required = true, description = "The patch content file")
    Path patchContextPath;

    @CommandLine.Option (names = {
            "-i", "--index-file"
    }, required = true, description = "The patch index file")
    Path indexPath;

    @CommandLine.Parameters (index = "0", paramLabel = "OUTPUT", description = "The output .ips file")
    File outputFile;

    public static void main(String[] args)
    {
        new CommandLine(new MakeIPS()).execute(args);
    }

    @Override
    public Integer call() throws Exception
    {
        return createIPSPatchFile(processPatchRecords(readPatchRecords()));
    }

    private int createIPSPatchFile(List<IPSRecord> ipsRecords) throws IOException
    {
        try (DataOutputStream dataOutputStream = new DataOutputStream(new FileOutputStream(outputFile)))
        {
            dataOutputStream.writeBytes(HEADER);
            for (IPSRecord ipsRecord : ipsRecords)
            {
                write24Bit(dataOutputStream, ipsRecord.getOffset());
                write16Bit(dataOutputStream, ipsRecord.getSize());

                dataOutputStream.write(ipsRecord.getData());
            }
            dataOutputStream.writeBytes(EOF);
        }

        return 0;
    }

    private void write24Bit(DataOutputStream dataOutputStream, int value) throws IOException
    {
        write16Bit(dataOutputStream, value >> 8);
        dataOutputStream.write(value & 0xff);
    }

    private void write16Bit(DataOutputStream dataOutputStream, int value) throws IOException
    {
        dataOutputStream.write((value >> 8) & 0xff);
        dataOutputStream.write(value & 0xff);
    }

    private List<IPSRecord> processPatchRecords(List<IPSRecord> ipsRecords)
    {
        return ipsRecords.stream()
                .sorted()
                .reduce(new ArrayList<IPSRecord>(), (records, ipsRecord) ->
                {
                    if (records.isEmpty())
                    {
                        records.add(ipsRecord);
                    }
                    else
                    {
                        IPSRecord lastRecord = records.get(records.size() - 1);
                        if (!lastRecord.merge(ipsRecord))
                        {
                            records.add(ipsRecord);
                        }
                    }

                    return records;
                }, (r1, r2) -> r1)
                .stream()
                .flatMap((IPSRecord ipsRecord) -> ipsRecord.split().stream())
                .collect(Collectors.toList());
    }

    private List<IPSRecord> readPatchRecords() throws IOException
    {
        ByteBuffer patchContent = ByteBuffer.wrap(Files.readAllBytes(patchContextPath));
        patchContent.order(ByteOrder.BIG_ENDIAN);

        IntBuffer patchIndex = ByteBuffer.wrap(Files.readAllBytes(indexPath))
                .order(ByteOrder.BIG_ENDIAN)
                .asIntBuffer();

        List<IPSRecord> ipsRecords = new ArrayList<>();
        while (patchIndex.position() < patchIndex.limit())
        {
            int sourceOffset = patchIndex.get();
            int targetOffset = patchIndex.get();
            int size = patchIndex.get();

            byte[] patchData = new byte[size];
            patchContent.position(sourceOffset);
            patchContent.get(patchData);

            ipsRecords.add(new IPSRecord(targetOffset, patchData));
        }
        return ipsRecords;
    }
}
