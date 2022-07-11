|--------------------------------------------------------------------
| Modify the amazon entity to use uncompressed tile data directly from ROM
|--------------------------------------------------------------------

    .include "patch.i"


    |-------------------------------------------------------------------
    | Set the amazon tile data address in the entity to point to the uncompressed data in ROM
    |-------------------------------------------------------------------
    patch_start 0x011040
        move.l  #pat_amazon, 0x74(%a0)
    patch_end
