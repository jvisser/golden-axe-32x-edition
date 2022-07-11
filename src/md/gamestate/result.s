|--------------------------------------------------------------------
| Add arcade background to result screen
|--------------------------------------------------------------------

    .include "goldenaxe.i"
    .include "marscomm.i"
    .include "patch.i"


    patch_start 0x006100
        jmp     game_state_init_result.l
    patch_end


    |-------------------------------------------------------------------
    | Show arcade background
    |-------------------------------------------------------------------
    game_state_init_result:
        mars_comm_image img_dungeon_background

        move.w  #SONG_ENDING, %d7
        jmp     sound_command
