|--------------------------------------------------------------------
| Add arcade background to result screen
|--------------------------------------------------------------------

    .include "goldenaxe.i"
    .include "patch.i"
    .include "marscomm.i"


    |-------------------------------------------------------------------
    | Load arcade background and initiate fade in
    |-------------------------------------------------------------------
    patch_start 0x0060fc
        jmp     game_state_handler_result_init.l
    patch_end

    game_state_handler_result_init:
        move.l  %a0, -(%sp)
        lea     img_dungeon_background, %a0
        jsr     mars_comm_image_fade_in
        movea.l (%sp)+, %a0

        jsr     palette_interpolate_full

        move.w  #SONG_ENDING, %d7
        jmp     sound_command
