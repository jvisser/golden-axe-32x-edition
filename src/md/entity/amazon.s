|--------------------------------------------------------------------
| The amazon entity uses a compressed tileset of about 16k uncompressed which is decompressed to 0xff8000
| We modify the amazon entity to use uncompressed data directly from ROM so we can claim the freed up RAM
|--------------------------------------------------------------------

    .include "patch.i"


    .section    .rodata
    .align      2

    amazon_tile_data:   .incbin "amazon.pat"


    |-------------------------------------------------------------------
    | Disable the nemesis decompression to RAM subroutine.
    | Which is only used for the amazon tile data and the sega logo (which will be patched out).
    |-------------------------------------------------------------------
    patch_start 0x002fda
        rts
    patch_end


    |-------------------------------------------------------------------
    | Set the amazon tile data address in the entity to point to the uncompressed data in ROM
    |-------------------------------------------------------------------
    patch_start 0x011040
        move.l  #amazon_tile_data, 0x74(%a0)
    patch_end
