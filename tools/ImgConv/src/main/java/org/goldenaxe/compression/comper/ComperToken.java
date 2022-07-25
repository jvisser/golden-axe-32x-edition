package org.goldenaxe.compression.comper;

import java.util.List;
import java.util.Objects;
import org.goldenaxe.compression.CompressionToken;
import org.goldenaxe.compression.Endianess;


class ComperToken implements CompressionToken, Comparable<ComperToken>
{
    private final static int COST_INCREMENT = 17;

    private final int index;
    private final short value;

    private ComperToken next;
    private ComperToken previous;

    private int cost;
    private int length;
    private int offset;

    ComperToken(int cost, int index, short value)
    {
        this.cost = cost;
        this.index = index;
        this.value = value;
    }

    public static CompressionToken terminal()
    {
        return new ComperToken(0, 0, (short) 0)
        {
            @Override
            public void write(List<Byte> compressionBuffer)
            {
                compressionBuffer.add((byte) 0);
                compressionBuffer.add((byte) 0);
            }

            @Override
            public boolean isCompressed()
            {
                return true;
            }
        };
    }

    @Override
    public void write(List<Byte> compressionBuffer)
    {
        if (isCompressed())
        {
            int length = next.length;
            int distance = next.index - next.length - next.offset;

            compressionBuffer.add((byte) -distance);
            compressionBuffer.add((byte) (length - 1));
        }
        else
        {
            compressionBuffer.addAll(Endianess.BIG.toBytes(value));
        }
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
        final ComperToken that = (ComperToken) o;
        return value == that.value;
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(index, value);
    }

    @Override
    public boolean isCompressed()
    {
        return hasNext() && next.length != 0;
    }

    @Override
    public int compareTo(ComperToken token)
    {
        return cost - (token.cost + COST_INCREMENT);
    }

    public void link(ComperToken token, int offset)
    {
        cost = token.cost + COST_INCREMENT;
        previous = token;
        length = index - token.index;
        this.offset = offset;
    }

    public void linkUncompressed(ComperToken token)
    {
        cost = token.cost + COST_INCREMENT;
        previous = token;
        length = 0;
    }

    public boolean hasNext()
    {
        return next != null;
    }

    public void linkNext()
    {
        previous.next = this;
    }

    public void terminatePrevious()
    {
        previous = null;
    }

    public void terminateNext()
    {
        next = null;
    }

    public boolean hasPrevious()
    {
        return previous != null;
    }

    public ComperToken getPrevious()
    {
        return previous;
    }

    public ComperToken getNext()
    {
        return next;
    }
}
