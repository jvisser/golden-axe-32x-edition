|--------------------------------------------------------------------
| Add arcade background to result screen
|--------------------------------------------------------------------

    .include "ga.i"
    .include "patch.i"


    patch_start 0x006100
        jsr     game_state_init_result.l
        nop
    patch_end


    |-------------------------------------------------------------------
    | Show arcade background
    |-------------------------------------------------------------------
    game_state_init_result:
        jsr     img_load_dungeon_background
        move.w  #SONG_ENDING, %d7
        jmp     sound_command
