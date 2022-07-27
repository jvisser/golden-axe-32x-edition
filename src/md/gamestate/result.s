|--------------------------------------------------------------------
| Result screen patches
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
        lea     (img_dungeon_background), %a0
        move.w  #SONG_ENDING, %d7
        jmp     show_image_with_sound
