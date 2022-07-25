package org.goldenaxe.compression;


import java.util.List;
import java.util.function.Function;
import java.util.function.UnaryOperator;
import java.util.stream.IntStream;

import static java.util.function.UnaryOperator.identity;
import static java.util.stream.Collectors.toList;


public enum Endianess
{
    BIG(Long::reverseBytes, Integer::reverseBytes, Short::reverseBytes),
    LITTLE(identity(), identity(), identity());

    private final Function<Long, Long> longTransform;
    private final Function<Integer, Integer> integerTransform;
    private final Function<Short, Short> shortTransform;

    Endianess(UnaryOperator<Long> longTransform,
              UnaryOperator<Integer> integerTransform,
              UnaryOperator<Short> shortTransform)
    {
        this.longTransform = longTransform;
        this.integerTransform = integerTransform;
        this.shortTransform = shortTransform;
    }

    public List<Byte> toBytes(long value)
    {
        return toBytes(longTransform.apply(value), Long.BYTES);
    }

    public List<Byte> toBytes(int value)
    {
        return toBytes(integerTransform.apply(value), Integer.BYTES);
    }

    public List<Byte> toBytes(short value)
    {
        return toBytes(shortTransform.apply(value), Short.BYTES);
    }

    public List<Byte> toBytes(Number number)
    {
        if (number instanceof  Integer)
        {
            return toBytes(number.intValue());
        }

        if (number instanceof Short)
        {
            return toBytes(number.shortValue());
        }

        if (number instanceof Byte)
        {
            return toBytes(number.byteValue(), 1);
        }

        return toBytes(number.longValue());
    }

    public long longFromBytes(List<Byte> bytes)
    {
        long value = fromBytes(bytes, Long.BYTES);

        return longTransform.apply(value);
    }

    public int intFromBytes(List<Byte> bytes)
    {
        int value = (int) fromBytes(bytes, Integer.BYTES);

        return integerTransform.apply(value);
    }

    public short shortFromBytes(List<Byte> bytes)
    {
        short value = (short) fromBytes(bytes, Short.BYTES);

        return shortTransform.apply(value);
    }

    private long fromBytes(List<Byte> bytes, int byteCount)
    {
        if (bytes.size() < byteCount)
        {
            throw new IllegalArgumentException("Insufficient data to reconstruct value");
        }

        BitPacker bitPacker = new BitPacker();
        for (byte byteValue : bytes)
        {
            bitPacker = bitPacker.add(byteValue);
        }
        return bitPacker.longValue();
    }

    private List<Byte> toBytes(long value, int byteCount)
    {
        return IntStream.range(0, byteCount)
                .mapToObj(b -> (byte) ((value >>> (b << 3)) & 0xff))
                .collect(toList());
    }
}
