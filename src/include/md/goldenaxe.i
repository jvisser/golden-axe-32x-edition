|--------------------------------------------------------------------
| Golden Axe game constants/variables and subroutine addresses
|--------------------------------------------------------------------

    .ifnotdef   __GOLDEN_AXE_I__
    .equ        __GOLDEN_AXE_I__, 1

    |-------------------------------------------------------------------
    | Constants
    |-------------------------------------------------------------------

        .equ VBLANK_UPDATE_SPRITE_ATTR,         0x01
        .equ VBLANK_UPDATE_CONTROLLER,          0x02

        .equ VDP_ADDR_SET_NAME_TBL_A,           0x40000003    | VRAM address 0xC000
        .equ VDP_ADDR_SET_NAME_TBL_B,           0x60000003    | VRAM address 0xE000

        | Game states
        .equ GAME_STATE_SEGA,                   0x00
        .equ GAME_STATE_TITLE,                  0x04
        .equ GAME_STATE_PLAYER,                 0x08
        .equ GAME_STATE_GAME_PLAY,              0x0c
        .equ GAME_STATE_DEMO,                   0x10
        .equ GAME_STATE_PROFILE,                0x14
        .equ GAME_STATE_INTERMISSION,           0x18
        .equ GAME_STATE_CAMP,                   0x1c
        .equ GAME_STATE_RESULT,                 0x20
        .equ GAME_STATE_END,                    0x24
        .equ GAME_STATE_BEGINNER_END,           0x28
        .equ GAME_STATE_CAST,                   0x2c
        .equ GAME_STATE_CREDITS,                0x30
        .equ GAME_STATE_VS,                     0x34
        .equ GAME_STATE_DUEL,                   0x38
        .equ GAME_STATE_NEXT_DUEL,              0x3c
        .equ GAME_STATE_GAME_OVER,              0x40

        | Song id's
        .equ SONG_WILDERNESS,                   0x81
        .equ SONG_TURTLE_VILLAGE,               0x82
        .equ SONG_MAIN_LAND_COAST,              0x84
        .equ SONG_FIENDS_PATH,                  0x83
        .equ SONG_EAGLES_HEAD,                  0x86        | Also boss
        .equ SONG_DEATH_ADDER,                  0x85        | Also used for dungeon
        .equ SONG_DEATH_BRINGER,                0x87
        .equ SONG_ENDING,                       0x8d
        .equ SONG_GAME_OVER,                    0x88
        .equ SONG_TITLE,                        0x89        | Also for player select
        .equ SONG_CAMP,                         0x8b
        .equ SONG_INTERMISSION,                 0x8c
        .equ SONG_CREDITS,                      0x8e

        | Entity struct offsets
        .equ ENTITY_STATE,                      0x42
        .equ ENTITY_X,                          0x1c


    |-------------------------------------------------------------------
    | Data addresses
    |-------------------------------------------------------------------
        .equ hud_player_palette,                0x00038492


    |-------------------------------------------------------------------
    | Variables
    |-------------------------------------------------------------------

        .equ entity_player_1,                   0xffffd000
        .equ entity_player_2,                   0xffffd080

        .equ requested_game_state,              0xffffc170  | .w
        .equ current_game_state,                0xffffc172  | .w

        .equ current_level,                     0xfffffe2c  | .w
        .equ demo_index,                        0xfffffe08  | .b

        .equ vblank_update_flags,               0xffffc183  | .b

        .equ vdp_reg_mode1,                     0xffffc114  | .w in register set command format
        .equ vdp_reg_mode2,                     0xffffc116  | .w in register set command format
        .equ vdp_vertical_scroll_plane_a,       0xffffc218  | .w
        .equ vdp_horizontal_scroll_plane_a,     0xffffc21a  | .w
        .equ vdp_vertical_scroll_plane_b,       0xffffc21c  | .w
        .equ vdp_horizontal_scroll_plane_b,     0xffffc21e  | .w

        .equ ctrl_player_1,                     0xffffc176  | .b
        .equ ctrl_player_1_changed,             0xffffc177  | .b
        .equ ctrl_player_2,                     0xffffc178  | .b
        .equ ctrl_player_2_changed,             0xffffc179  | .b

        .equ palette_base,                      0xffffc000
        .equ palette_target,                    0xffffc080

        .equ vertical_scroll_increment,         0xffffc204  | .l 16.16 fixed point
        .equ horizontal_scroll_increment,       0xffffc208  | .l 16.16 fixed point
        .equ vertical_scroll,                   0xffffc20c  | .l 16.16 fixed point in map coordinates
        .equ horizontal_scroll,                 0xffffc210  | .l 16.16 fixed point in map coordinates
        .equ vertical_scroll_min,               0xffffc224  | .w
        .equ vertical_scroll_max,               0xffffc226  | .w
        .equ horizontal_scroll_max,             0xffffc228  | .w


    |-------------------------------------------------------------------
    | Original golden axe sub routines
    |-------------------------------------------------------------------

        .equ audio_init,                        0x000034bc
        .equ vblank_int_handler,                0x00000cf6

        .equ vdp_reset,                         0x00000df6
        .equ vdp_disable_display,               0x00002dca
        .equ vdp_enable_display,                0x00002dc2
        .equ vdp_clear_palette,                 0x00002eec

        .equ screen_transition_from_dark,       0x00003690
        .equ screen_transition_to_dark,         0x000036d8


        |-------------------------------------------------------------------
        | Decompresses directly to the VDP data port so the target address must be set before calling.
        |
        | Parameters:
        | - a0: compressed data address
        |-------------------------------------------------------------------
        .equ nemesis_decompress_vram,           0x00002fc8


        |-------------------------------------------------------------------
        | Parameters:
        | - d7.b: sound command
        |-------------------------------------------------------------------
        .equ sound_command,                     0x000035e8


        |-------------------------------------------------------------------
        | Fade out palette in 8 steps at 30fps
        |-------------------------------------------------------------------
        .equ palette_fade_out,                  0x000031ce


        |-------------------------------------------------------------------
        | Interpolates palette_target from palette_base at 30 fps in 8 iterations
        |
        | Parameters:
        | - d7.b: sound command
        |-------------------------------------------------------------------
        .equ palette_interpolate_full,          0x00003126


        |-------------------------------------------------------------------
        | Partially update the dynamic palette
        |
        | Parameters:
        | - a6: partial palette struct address
        |-------------------------------------------------------------------
        .equ palette_update_dynamic,            0x00002eb4


        |-------------------------------------------------------------------
        | Partially update the base palette
        |
        | Parameters:
        | - a6: partial palette struct address
        |-------------------------------------------------------------------
        .equ palette_update_base,               0x00002ed0


        |-------------------------------------------------------------------
        | Copies data from the specified source the per row to the specified target address.
        | Assumes table width of 64.
        |
        | Parameters:
        | - a6: nametable data
        | - d5.w: number of rows - 1
        | - d6.w: number of columns - 1
        | - d7.l: VDP target address set command
        |-------------------------------------------------------------------
        .equ name_table_update_rect,            0x00002d2c


        |-------------------------------------------------------------------
        | Fills the specified name table in VRAM with 0.
        | Assumes table width of 64.
        |
        | Parameters:
        | - d5.w: number of rows - 1
        | - d6.w: number of columns - 1
        | - d7.l: VDP target address set command
        |-------------------------------------------------------------------
        .equ name_table_clear_rect,             0x00002d4e


        |-------------------------------------------------------------------
        | Fills the specified name table in VRAM with the word value specified in d2.
        | Assumes table width of 64.
        |
        | Parameters:
        | - d2.w: fill value
        | - d5.w: number of rows - 1
        | - d6.w: number of columns - 1
        | - d7.l: VDP target address set command
        |-------------------------------------------------------------------
        .equ name_table_fill_rect,              0x00002d50

    .endif
