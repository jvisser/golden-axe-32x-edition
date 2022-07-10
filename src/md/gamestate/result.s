|--------------------------------------------------------------------
| Add arcade background to result screen
|--------------------------------------------------------------------

    .include "patch.i"


    patch_start 0x00601e
        jsr     game_state_init_result.l
        nop
    patch_end


    |-------------------------------------------------------------------
    | Show arcade background
    |-------------------------------------------------------------------
    game_state_init_result:
        ori     #0x0700, %sr
        jsr     vdp_disable_display
        jmp     img_load_dungeon_background
