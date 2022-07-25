package org.goldenaxe.compression;

import static java.lang.String.format;


public final class BitPacker
{
    private final long value;
    private final int shift;
    private final int maxBits;

    public BitPacker()
    {
        this(Long.SIZE);
    }

    public BitPacker(int maxBits)
    {
        if (maxBits > Long.SIZE)
        {
            throw new IllegalArgumentException("Not enough storage");
        }

        this.maxBits = maxBits;
        this.value = 0;
        this.shift = 0;
    }

    private BitPacker(long value, int shift, int maxBits)
    {
        this.value = value;
        this.shift = shift;
        this.maxBits = maxBits;
    }

    public BitPacker insert(long value)
    {
        return insert(value, Long.SIZE);
    }

    public BitPacker insert(int value)
    {
        return insert(value, Integer.SIZE);
    }

    public BitPacker insert(short value)
    {
        return insert(value, Short.SIZE);
    }

    public BitPacker insert(byte value)
    {
        return insert(value, Byte.SIZE);
    }

    public BitPacker insert(boolean value)
    {
        return insert(value ? 1 : 0, 1);
    }

    public BitPacker insert(long value, int bitCount)
    {
        if (shift + bitCount > maxBits)
        {
            throw new IllegalArgumentException(format("Overflow (shift:%d + bitCount:%d > maxBits:%d)", shift, bitCount, maxBits));
        }

        return new BitPacker((this.value << bitCount) | (value & ((1L << bitCount) - 1)),
                             shift + bitCount,
                             maxBits);

    }

    public BitPacker add(long value)
    {
        return add(value, Long.SIZE);
    }

    public BitPacker add(int value)
    {
        return add(value, Integer.SIZE);
    }

    public BitPacker add(short value)
    {
        return add(value, Short.SIZE);
    }

    public BitPacker add(byte value)
    {
        return add(value, Byte.SIZE);
    }

    public BitPacker add(boolean value)
    {
        return add(value ? 1 : 0, 1);
    }

    public BitPacker add(long value, int bitCount)
    {
        if (shift + bitCount > maxBits)
        {
            throw new IllegalArgumentException(format("Overflow (shift:%d + bitCount:%d > maxBits:%d)", shift, bitCount, maxBits));
        }

        return new BitPacker(this.value | ((value & ((1L << bitCount) - 1)) << shift),
                             shift + bitCount,
                             maxBits);
    }

    public BitPacker add(BitPacker other)
    {
        return add(other.value, other.shift);
    }

    public BitPacker add(Packable packable)
    {
        return add(packable.pack());
    }

    public long longValue()
    {
        return value;
    }

    public int intValue()
    {
        if (value > 0xffffffffL)
        {
            throw new IllegalArgumentException("Not enough storage in Integer");
        }

        return (int) value;
    }

    public short shortValue()
    {
        if (value > 0xffffL)
        {
            throw new IllegalArgumentException("Not enough storage in Short");
        }

        return (short) value;
    }

    public byte byteValue()
    {
        if (value > 0xffL)
        {
            throw new IllegalArgumentException("Not enough storage in Byte");
        }

        return (byte) value;
    }

    public Number numberValue()
    {
        if (maxBits <= Byte.SIZE)
        {
            return byteValue();
        }

        if (maxBits <= Short.SIZE)
        {
            return shortValue();
        }

        if (maxBits <= Integer.SIZE)
        {
            return intValue();
        }

        return value;
    }

    public BitPacker pad(int i)
    {
        return add(0, i);
    }

    public BitPacker padStart(int i)
    {
        return insert(0, i);
    }

    public BitPacker reverse()
    {
        return new BitPacker(Long.reverse(value ) >>> (Long.SIZE - shift), shift, maxBits);
    }

    public int getSize()
    {
        return shift;
    }

    public boolean isFull()
    {
        return shift >= maxBits;
    }

    public boolean isEmpty()
    {
        return shift == 0;
    }
}
