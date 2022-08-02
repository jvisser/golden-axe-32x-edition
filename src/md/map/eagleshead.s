/*
 * Eagles's head patches
 */

#include "goldenaxe.h"
#include "map.h"
#include "entity.h"
#include "md.h"
#include "patch.h"


    .section .rodata

    .balign 2

    /**********************************************************
     * Map definition
     */
    patch_start 0x0015bc
        .dc.l   eagles_head_map_definition  // Patch map table entry
    patch_end

    eagles_head_map_definition:
        /* Palette list */
        .dc.l   hud_player_palette
        .dc.l   0

        /* Nemesis tile data list */
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   0

        /* Tile map data */
        .dc.l   map_eagles_head_foreground_blocks
        .dc.l   map_eagles_head_foreground_map

        /* Map dimensions */
        .dc.w   map_eagles_head_block_height
        .dc.w   map_eagles_head_block_width

        /* Initial scroll positions in blocks */
        .dc.w   4       // Vertical
        .dc.w   0       // Horizontal

        /* Event list */
        .dc.l   eagles_head_event_list
        .dc.l   eagles_head_extended_event_data_table

        /* Height map data */
        .dc.l   map_eagles_head_height_map
        .dc.l   map_eagles_head_height_blocks

        /* Entity load list */
        .dc.l   eagles_head_entity_load_list

        /* Player starting positions */
        .dc.w   0       // Player 1 Y (Baseline relative offset)
        .dc.w   256     // Player 1 X
        .dc.w   0       // Player 2 Y (Baseline relative offset)
        .dc.w   296     // Player 2 X

        /* Music id */
        .dc.w   SONG_EAGLES_HEAD


    /**********************************************************
     * Y base line list
     */
    patch_start 0x00878e
        .dc.l   eagles_head_y_baseline   // Patch y base line table entry
    patch_end

    eagles_head_y_baseline:
        .dc.w   0x0000

        .dc.w   map_eagles_head_pixel_width
        .dc.w   208


    /**********************************************************
     * Event list
     */
    eagles_head_event_list:
        .dc.w   320
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x01

        .dc.w   952
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x02

        .dc.w   960
        .dc.b   MAP_EVENT_START_BOSS_MUSIC
        .dc.b   0x00

        .dc.w   1216
        .dc.b   MAP_EVENT_END_GAME_ON_ENEMY_DEFEAT
        .dc.b   0x00

        .dc.w   1280
        .dc.b   MAP_EVENT_NOTHING
        .dc.b   0x00

    eagles_head_extended_event_data_table:


    /**********************************************************
     * Entity load list
     */

    eagles_head_entity_load_list:
        .dc.w   -1  // Terminate
