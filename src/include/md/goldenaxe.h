/*
 * Golden Axe game general constants/variables and subroutine addresses
 */

#ifndef __GOLDEN_AXE_H__
#define __GOLDEN_AXE_H__

/**********************************************************
 * Constants
 */

#define VBLANK_UPDATE_SPRITE_ATTR               0x01
#define VBLANK_UPDATE_CONTROLLER                0x02

#define VDP_NAME_TBL_A                          0xc000
#define VDP_NAME_TBL_B                          0xe000

// Game states
#define GAME_STATE_SEGA                         0x00
#define GAME_STATE_TITLE                        0x04
#define GAME_STATE_PLAYER                       0x08
#define GAME_STATE_GAME_PLAY                    0x0c
#define GAME_STATE_DEMO                         0x10
#define GAME_STATE_PROFILE                      0x14
#define GAME_STATE_INTERMISSION                 0x18
#define GAME_STATE_CAMP                         0x1c
#define GAME_STATE_RESULT                       0x20
#define GAME_STATE_END                          0x24
#define GAME_STATE_BEGINNER_END                 0x28
#define GAME_STATE_CAST                         0x2c
#define GAME_STATE_CREDITS                      0x30
#define GAME_STATE_VS                           0x34
#define GAME_STATE_DUEL                         0x38
#define GAME_STATE_NEXT_DUEL                    0x3c
#define GAME_STATE_GAME_OVER                    0x40

// Game mode flag but numbers
#define B_GAME_MODE_BEGINNER                    2

// Song id's
#define SONG_WILDERNESS                         -127
#define SONG_TURTLE_VILLAGE                     -126
#define SONG_TOWN                               -124
#define SONG_FIENDS_PATH                        -125
#define SONG_EAGLES_HEAD                        -122
#define SONG_DUNGEON                            -123
#define SONG_BOSS                               -122
#define SONG_DEATH_ADDER                        -123
#define SONG_DEATH_BRINGER                      -121
#define SONG_ENDING                             -115
#define SONG_GAME_OVER                          -120
#define SONG_TITLE                              -119
#define SONG_PLAYER_SELECT                      -119
#define SONG_CAMP                               -117
#define SONG_INTERMISSION                       -116
#define SONG_CREDITS                            -114
#define SOUND_STOP                              -118
#define SOUND_FADE_OUT                          -32

#define SOUND_EFFECT_DOOR                       -85

/**********************************************************
 * VRAM allocation
 */

// Reserved for game over and continue signs etc
#define GAME_PLAY_VRAM_SAFE_MIN                 0x1900  // Used by level 6 tyris magic, tiles between SAFE_MIN and RESERVED_MIN must be restored using the map's tile restore list
#define GAME_PLAY_VRAM_RESERVED_MIN             0x27c0
#define GAME_PLAY_VRAM_RESERVED_MAX             0x3200
#define GAME_PLAY_VRAM_SAFE_TILE_MIN            (GAME_PLAY_VRAM_SAFE_MIN/32)
#define GAME_PLAY_VRAM_RESERVED_TILE_MIN        (GAME_PLAY_VRAM_RESERVED_MIN/32)
#define GAME_PLAY_VRAM_RESERVED_TILE_MAX        (GAME_PLAY_VRAM_RESERVED_MAX/32)

#define GAME_PLAY_VRAM_DYNAMIC_TOP              0x9800
#define GAME_PLAY_VRAM_DYNAMIC_TOP_TILE         (GAME_PLAY_VRAM_DYNAMIC_TOP/32)

/**********************************************************
 * Variables
 */

#define entity_player_1                         0xffffd000
#define entity_player_2                         0xffffd080

#define game_mode_flags                         0xffffc104  // .b
#define requested_game_state                    0xffffc170  // .w
#define current_game_state                      0xffffc172  // .w

#define current_level                           0xfffffe2c  // .w
#define demo_index                              0xfffffe08  // .b

#define vblank_update_flags                     0xffffc183  // .b
#define vblank_update_palette_flag              0xffffc17c  // .b

#define vdp_reg_mode1                           0xffffc114  // .w in register set command format
#define vdp_reg_mode2                           0xffffc116  // .w in register set command format
#define vdp_vertical_scroll_plane_a             0xffffc218  // .w
#define vdp_horizontal_scroll_plane_a           0xffffc21a  // .w
#define vdp_vertical_scroll_plane_b             0xffffc21c  // .w
#define vdp_horizontal_scroll_plane_b           0xffffc21e  // .w

#define ctrl_player_1                           0xffffc176  // .b
#define ctrl_player_1_changed                   0xffffc177  // .b
#define ctrl_player_2                           0xffffc178  // .b
#define ctrl_player_2_changed                   0xffffc179  // .b

#define palette_base                            0xffffc000
#define palette_target                          0xffffc080

#define vertical_scroll_increment               0xffffc204  // .l 16.16 fixed point
#define horizontal_scroll_increment             0xffffc208  // .l 16.16 fixed point
#define vertical_scroll                         0xffffc20c  // .l 16.16 fixed point in map coordinates
#define horizontal_scroll                       0xffffc210  // .l 16.16 fixed point in map coordinates
#define vertical_scroll_min                     0xffffc224  // .w
#define vertical_scroll_max                     0xffffc226  // .w
#define horizontal_scroll_max                   0xffffc228  // .w

#define font_tile_offset                        0xffffc110  // .w

#define last_song_id                            0xffffc12c  // .b

/**********************************************************
 * Original golden axe sub routines
 */

#define audio_init                              0x000034bc
#define vblank_int_handler                      0x00000cf6

#define vdp_reset                               0x00000df6
#define vdp_disable_display                     0x00002dca
#define vdp_enable_display                      0x00002dc2
#define vdp_clear_palette                       0x00002eec

#define vdp_clear_name_table                    0x00002c98  // Address set command in d7
#define vdp_clear_name_table_a                  0x00002c88
#define vdp_clear_name_table_b                  0x00002c92

#define vdp_set_mode_h40                        0x00002dda
#define vdp_set_mode_h32                        0x00002de8

#define screen_transition_from_dark             0x00003690
#define screen_transition_to_dark               0x000036d8


/*
 * Animation sequencer (one of many implementations though)
 *
 * Parameters:
 * - d0: animation id
 */
#define update_animation                        0x00008814


/*
 * Sets the animation properties to frame one of the specified animation (ready to be started)
 *
 * Parameters:
 * - d0: animation id
 */
#define setup_animation                         0x00008894


/*
 * Loads the specified animation frame properties (again one of many implementations)
 */
#define load_pre_load_animation_frame           0x0000b7da


/*
 * Advance the animation one tick
 */
#define update_pre_load_animation                0x0000b794


/*
 * Decompresses directly to the VDP data port so the target address must be set before calling.
 *
 * Parameters:
 * - a0: compressed data address
 */
#define nemesis_decompress_vram                 0x00002fc8


/*
 * Parameters:
 * - d7.b: song id
 */
#define play_music                              0x000035e8


/*
 * Parameters:
 * - d7.b: sound effect id
 */
#define play_sound_effect                       0x0000361c


/*
 * Fade out palette in 8 steps at 30fps
 */
#define palette_fade_out                        0x000031ce


/*
 * Interpolates palette_target from palette_base at 30 fps in 8 iterations
 *
 * Parameters:
 * - d7.b: sound command
 */
#define palette_interpolate_full                0x00003126


/*
 * Partially update the dynamic palette
 *
 * Parameters:
 * - a6: partial palette struct address
 */
#define palette_update_dynamic_commit           0x00002eb4
#define palette_update_dynamic                  0x00002eba


/*
 * Partially update the base palette
 *
 * Parameters:
 * - a6: partial palette struct address
 */
#define palette_update_base_commit              0x00002ed0
#define palette_update_base                     0x00002ed6


/*
 * Copies data from the specified source the per row to the specified target address.
 * Assumes table width of 64.
 *
 * Parameters:
 * - a6: nametable data
 * - d5.w: number of rows - 1
 * - d6.w: number of columns - 1
 * - d7.l: VDP target address set command
 */
#define name_table_update_rect                  0x00002d2c


/*
 * Same as name_table_update_rect but supports crossing the horizontal plane boundary
 */
#define name_table_update_rect_safe             0x00002d72


/*
 * Fills the specified name table in VRAM with 0.
 * Assumes table width of 64.
 *
 * Parameters:
 * - d5.w: number of rows - 1
 * - d6.w: number of columns - 1
 * - d7.l: VDP target address set command
 */
#define name_table_clear_rect                   0x00002d4e


/*
 * Fills the specified name table in VRAM with the word value specified in d2.
 * Assumes table width of 64.
 *
 * Parameters:
 * - d2.w: fill value
 * - d5.w: number of rows - 1
 * - d6.w: number of columns - 1
 * - d7.l: VDP target address set command
 */
#define name_table_fill_rect                    0x00002d50

#endif
