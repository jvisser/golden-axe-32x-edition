|--------------------------------------------------------------------
| Add arcade background to player select
|--------------------------------------------------------------------

    .include "patch.i"


    patch_start 0x004384
        jsr     game_state_init_player_select.l
        nop
    patch_end


    |-------------------------------------------------------------------
    | Show arcade background
    |-------------------------------------------------------------------
    game_state_init_player_select:
        ori     #0x0700, %sr
        jsr     vdp_disable_display
        jmp     img_load_dungeon_background
