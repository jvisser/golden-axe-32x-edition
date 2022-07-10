|--------------------------------------------------------------------
| Add arcade background to player select screen
|--------------------------------------------------------------------

    .include "ga.i"
    .include "mars.i"
    .include "marscomm.i"
    .include "patch.i"


    patch_start 0x004384
        jsr     game_state_handler_player_select_init.l
        nop
    patch_end


    |-------------------------------------------------------------------
    | Show arcade background
    |-------------------------------------------------------------------
    game_state_handler_player_select_init:
        ori     #0x0700, %sr
        jsr     vdp_disable_display

        move.l  #dungeon_background_image, (MARS_REG_BASE + MARS_COMM4)
        moveq   #MARSCOMM_IMAGE, %d0
        jmp     mars_comm
