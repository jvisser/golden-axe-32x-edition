package org.goldenaxe.compression.slz;

import java.util.Arrays;
import java.util.List;
import org.goldenaxe.compression.CompressionToken;


class SLZToken implements CompressionToken
{
    public static final short LENGTH_BITS = 4;
    public static final short LENGTH_MASK = (1 << LENGTH_BITS) - 1;
    public static final short DISTANCE_BITS = Short.SIZE - LENGTH_BITS;
    public static final short DISTANCE_MASK = (1 << DISTANCE_BITS) - 1;

    private static final int MAX_SEARCH_DISTANCE = (1 << DISTANCE_BITS) - 1 + 3;
    private static final int MAX_TOKEN_LENGTH = (1 << LENGTH_BITS) - 1 + 3;

    private final int distance;
    private final int length;
    private final int position;

    private final byte value;

    private SLZToken(byte value)
    {
        this.position = 0;
        this.distance = 0;
        this.length = 0;
        this.value = value;
    }

    private SLZToken(int distance, int length, int position, byte value)
    {
        this.distance = distance;
        this.length = length;
        this.position = position;
        this.value = value;
    }

    static SLZToken init(byte[] inputBytes)
    {
        if (inputBytes.length == 0)
        {
            return terminal();
        }
        return new SLZToken(inputBytes[0]);
    }

    private static SLZToken terminal()
    {
        return new SLZToken(0, 0, -1, (byte) 0);
    }

    @Override
    public void write(List<Byte> buffer)
    {
        if (isCompressed())
        {
            int d = distance - 3;
            int l = length - 3;

            buffer.add((byte)(d >>> LENGTH_BITS));
            buffer.add((byte)(d << LENGTH_BITS | (l & LENGTH_MASK)));
        }
        else
        {
            buffer.add(value);
        }
    }

    @Override
    public boolean isCompressed()
    {
        return distance > 0 && length > 0;
    }

    public SLZToken next(byte[] inputBytes)
    {
        int nextPosition = isCompressed() ? position + length : position + 1;
        if (nextPosition >= inputBytes.length)
        {
            return terminal();
        }
        int nextDistance = 0;
        int nextLength = 0;

        int curNextLength = 2;
        if (nextPosition > 0 && inputBytes.length - nextPosition >= 3)
        {
            int maxDistance = Math.min(nextPosition, MAX_SEARCH_DISTANCE);
            int maxLength = Math.min(inputBytes.length - nextPosition, MAX_TOKEN_LENGTH);

            int readBehindPosition = nextPosition - maxDistance;
            for (int currentDistance = maxDistance; currentDistance >= 3; currentDistance--, readBehindPosition++)
            {
                if (inputBytes[readBehindPosition] != inputBytes[nextPosition])
                {
                    continue;
                }

                for (int currentLength = maxLength; currentLength > curNextLength; currentLength--)
                {
                    if (Arrays.compare(inputBytes, readBehindPosition, readBehindPosition + currentLength,
                                       inputBytes, nextPosition, nextPosition + currentLength) == 0)
                    {
                        nextDistance = currentDistance;
                        nextLength = currentLength;

                        curNextLength = currentLength;
                        break;
                    }
                }
            }
        }

        return new SLZToken(nextDistance, nextLength, nextPosition, inputBytes[nextPosition]);
    }

    public boolean isTerminal()
    {
        return position < 0;
    }
}
