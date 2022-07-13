|--------------------------------------------------------------------
| Add arcade background to player select
|--------------------------------------------------------------------

    .include "goldenaxe.i"
    .include "patch.i"
    .include "marscomm.i"


    |-------------------------------------------------------------------
    | Load arcade background and initiate fade in
    |-------------------------------------------------------------------
    patch_start 0x004436
        jmp     game_state_handler_player_select_init.l
    patch_end

    game_state_handler_player_select_init:
        move.l  %a0, -(%sp)
        lea     (img_dungeon_background), %a0
        jsr     mars_comm_image_fade_in
        movea.l (%sp)+, %a0

        jsr     palette_interpolate_full

        move.w  #SONG_TITLE, %d7
        jmp     sound_command
