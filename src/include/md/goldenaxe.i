|--------------------------------------------------------------------
| Golden Axe game constants/variables and subroutine addresses
|--------------------------------------------------------------------

    .ifnotdef   __GOLDEN_AXE_I__
    .equ        __GOLDEN_AXE_I__, 1

    |-------------------------------------------------------------------
    | Variables
    |-------------------------------------------------------------------
    .equ requested_game_state,      0xffffc170  | .w
    .equ current_game_state,        0xffffc172  | .w

    .equ vblank_update_flags,       0xffffc183  | .b

    .equ vdp_reg_mode1,             0xffffc114  | .w in register set command format
    .equ vdp_reg_mode2,             0xffffc116  | .w in register set command format

    .equ ctrl_player_1,             0xffffc176  | .b
    .equ ctrl_player_1_changed,     0xffffc177  | .b
    .equ ctrl_player_2,             0xffffc178  | .b
    .equ ctrl_player_2_changed,     0xffffc179  | .b

    .equ palette_base,              0xffffc000
    .equ palette_target,            0xffffc080


    |-------------------------------------------------------------------
    | Original golden axe sub routines
    |-------------------------------------------------------------------
    .equ nemesis_decompress_vram,   0x00002fc8
    .equ audio_init,                0x000034bc
    .equ sound_command,             0x000035e8
    .equ vblank_int_handler,        0x00000cf6
    .equ vdp_reset,                 0x00000df6
    .equ palette_interpolate_full,  0x00003126


    |-------------------------------------------------------------------
    | Constants
    |-------------------------------------------------------------------

    | Bit numbers
    .equ VBLANK_UPDATE_SPRITE_ATTR, 0x01
    .equ VBLANK_UPDATE_CONTROLLER,  0x02

    | Game states
    .equ GAME_STATE_SEGA,           0x00
    .equ GAME_STATE_TITLE,          0x04
    .equ GAME_STATE_PLAYER,         0x08
    .equ GAME_STATE_GAME_PLAY,      0x0c
    .equ GAME_STATE_DEMO,           0x10
    .equ GAME_STATE_PROFILE,        0x14
    .equ GAME_STATE_INTERMISSION,   0x18
    .equ GAME_STATE_CAMP,           0x1c
    .equ GAME_STATE_RESULT,         0x20
    .equ GAME_STATE_END,            0x24
    .equ GAME_STATE_BEGINNER_END,   0x28
    .equ GAME_STATE_CAST,           0x2c
    .equ GAME_STATE_CREDITS,        0x30
    .equ GAME_STATE_VS,             0x34
    .equ GAME_STATE_DUEL,           0x38
    .equ GAME_STATE_NEXT_DUEL,      0x3c
    .equ GAME_STATE_GAME_OVER,      0x40

    | Song id's
    .equ SONG_WILDERNESS,           0x81
    .equ SONG_TURTLE_VILLAGE,       0x82
    .equ SONG_MAIN_LAND_COAST,      0x84
    .equ SONG_FIENDS_PATH,          0x83
    .equ SONG_EAGLES_HEAD,          0x86        | Also boss
    .equ SONG_DEATH_ADDER,          0x85        | Also used for dungeon
    .equ SONG_DEATH_BRINGER,        0x87
    .equ SONG_ENDING,               0x8d
    .equ SONG_GAME_OVER,            0x88
    .equ SONG_TITLE,                0x89        | Also for player select
    .equ SONG_CAMP,                 0x8b
    .equ SONG_INTERMISSION,         0x8c
    .equ SONG_CREDITS,              0x8e

    .endif
