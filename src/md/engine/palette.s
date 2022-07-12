|--------------------------------------------------------------------
| Palette functions
|--------------------------------------------------------------------

    .include "goldenaxe.i"
    .include "patch.i"
    .include "marscomm.i"


    |-------------------------------------------------------------------
    | Patch palette fadeout to also fade out on the 32X
    |-------------------------------------------------------------------
    patch_start 0x0031d2
        jsr     mars_palette_fadeout.l
    patch_end

    mars_palette_fadeout:
        jsr     mars_comm_palette_fade_out

        lea     palette_target, %a1
        moveq   #7, %d1
        rts
