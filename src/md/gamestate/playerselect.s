|--------------------------------------------------------------------
| Player select screen patches
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
        lea     (img_dungeon_background), %a0
        move.w  #SONG_TITLE, %d7
        jmp     show_image_with_sound
