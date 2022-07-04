package org.goldenaxe.makeips;

import java.util.Objects;


class IPSRecord implements Comparable<IPSRecord>
{
    private static final int EOF = 0x454f46;

    private final int offset;
    private byte[] data;

    public IPSRecord(int offset, byte[] data)
    {
        if (offset == EOF)
        {
            // Should never happen with a standard MD ROM image
            throw new IllegalArgumentException("Patch offset == EOF");
        }
        this.offset = offset;
        this.data = data;
    }

    @Override
    public int compareTo(IPSRecord o)
    {
        return offset - o.offset;
    }

    @Override
    public boolean equals(Object o)
    {
        if (this == o)
        {
            return true;
        }
        if (o == null || getClass() != o.getClass())
        {
            return false;
        }
        final IPSRecord that = (IPSRecord) o;
        return offset == that.offset;
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(offset);
    }

    public boolean merge(IPSRecord ipsRecord)
    {
        if (offset + getSize() == ipsRecord.offset)
        {
            byte[] mergedData = new byte[getSize() + ipsRecord.getSize()];
            System.arraycopy(data, 0, mergedData, 0, getSize());
            System.arraycopy(ipsRecord.data, 0, mergedData, getSize(), ipsRecord.getSize());
            data = mergedData;

            return true;
        }
        return false;
    }

    public int getOffset()
    {
        return offset;
    }

    public int getSize()
    {
        return data.length;
    }

    public byte[] getData()
    {
        return data;
    }
}
