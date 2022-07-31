/*
 * Demo map data patches
 */

#include "goldenaxe.h"
#include "map.h"
#include "md.h"
#include "patch.h"


    .section .rodata

    .balign 2

    /**********************************************************
     * Map definition
     */
    patch_start 0x0015d4
        .dc.l   demo_map_definition   /* Patch map table entry */
    patch_end

    demo_map_definition:
        /* Palette list */
        .dc.l   hud_player_palette
        .dc.l   0

        /* Nemesis tile data list */
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0x0000))
        .dc.l   nem_pat_empty
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0x0001))
        .dc.l   nem_pat_chicken_leg
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0x0001 + chicken_leg_tile_count))
        .dc.l   nem_pat_bad_brother
        .dc.l   0

        /* Tile map data */
        .dc.l   map_wilderness_foreground_blocks
        .dc.l   map_wilderness_foreground_map

        /* Map dimensions */
        .dc.w   map_wilderness_block_height
        .dc.w   map_wilderness_block_width

        /* Initial scroll positions in blocks */
        .dc.w   0       /* Vertical */
        .dc.w   0       /* Horizontal */

        /* Event list */
        .dc.l   demo_event_list

        /* Height map data */
        .dc.l   map_wilderness_height_map
        .dc.l   map_wilderness_height_blocks

        /* Entity load list */
        .dc.l   demo_entity_load_list

        /* Player starting positions */
        .dc.w   -20     /* Player 1 Y (Baseline relative offset) */
        .dc.w   256     /* Player 1 X */
        .dc.w   0       /* Player 2 Y (Baseline relative offset) */
        .dc.w   0       /* Player 2 X */

        /* Music id */
        .dc.w   SONG_WILDERNESS


    /**********************************************************
     * Event list
     */
    demo_event_list:
        .dc.w   1280
        .dc.b   MAP_EVENT_NOTHING
        .dc.b   0x00


    /**********************************************************
     * Entity load list
     */
    demo_entity_load_list:
        .dc.w   0x0500
        .dc.w   0x0000

        .dc.w   -1
