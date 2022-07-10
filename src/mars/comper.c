/*
 * Comper decompression routine
 */

#include "comper.h"


void comper_decompress(u16* in, u16* out)
{
    u32 descriptor = *in++;
    u32 descriptor_remaining = 16;
    
    while (1)
    {
        if (descriptor & 0x8000)
        {
            u32 token = *in++;
            u32 length = token & 0xff;
            if (!length)
            {
                break;
            }

            u32 distance = 0x100 - ((token >> 8) & 0xff);
            u16* source = out - distance;
            for (u32 i = 0; i <= length; i++)
            {
                *out++ = *source++;
            }
        }
        else
        {
            *out++ = *in++;
        }

        if (!--descriptor_remaining)
        {
            descriptor = *in++;
            descriptor_remaining = 16;
        }
        else
        {
            descriptor <<= 1;
        }
    }
}