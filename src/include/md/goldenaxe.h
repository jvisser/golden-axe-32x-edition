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

#define VDP_ADDR_SET_NAME_TBL_A                 0x40000003  // VRAM address 0xC000
#define VDP_ADDR_SET_NAME_TBL_B                 0x60000003  // VRAM address 0xE000

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

// Song id's
#define SONG_WILDERNESS                         0x81
#define SONG_TURTLE_VILLAGE                     0x82
#define SONG_TOWN                               0x84
#define SONG_FIENDS_PATH                        0x83
#define SONG_EAGLES_HEAD                        0x86        // Also boss
#define SONG_DEATH_ADDER                        0x85        // Also used for dungeon
#define SONG_DEATH_BRINGER                      0x87
#define SONG_ENDING                             0x8d
#define SONG_GAME_OVER                          0x88
#define SONG_TITLE                              0x89        // Also for player select
#define SONG_CAMP                               0x8b
#define SONG_INTERMISSION                       0x8c
#define SONG_CREDITS                            0x8e

// Entity struct offsets
#define ENTITY_STATE                            0x42
#define ENTITY_X                                0x1c


/**********************************************************
 * VRAM allocation
 */

// Reserved for magic effects etc... not going to remap those...
#define GAME_PLAY_VRAM_RESERVED_MIN             0x27c0
#define GAME_PLAY_VRAM_RESERVED_MAX             0x3200
#define GAME_PLAY_VRAM_RESERVED_TILE_MIN        0x13e
#define GAME_PLAY_VRAM_RESERVED_TILE_MAX        0x190


/**********************************************************
 * Variables
 */

#define entity_player_1                         0xffffd000
#define entity_player_2                         0xffffd080

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


/**********************************************************
 * Original golden axe sub routines
 */

#define audio_init                              0x000034bc
#define vblank_int_handler                      0x00000cf6

#define vdp_reset                               0x00000df6
#define vdp_disable_display                     0x00002dca
#define vdp_enable_display                      0x00002dc2
#define vdp_clear_palette                       0x00002eec

#define screen_transition_from_dark             0x00003690
#define screen_transition_to_dark               0x000036d8

#define map_load_entity_data                    0x000138fe
#define update_active_entities                  0x0000b954


/*
 * Decompresses directly to the VDP data port so the target address must be set before calling.
 *
 * Parameters:
 * - a0: compressed data address
 */
#define nemesis_decompress_vram                 0x00002fc8


/*
 * Parameters:
 * - d7.b: sound command
 */
#define sound_command                           0x000035e8


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
