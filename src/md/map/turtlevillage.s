/*
 * Turtle village patches
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
    patch_start 0x0015b0
        .dc.l   turtle_village_map_definition   // Patch map table entry
    patch_end

    turtle_village_map_definition:
        /* Palette list */
        .dc.l   hud_player_palette
        .dc.l   0

        /* Nemesis tile data list */
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   0

        /* Tile map data */
        .dc.l   map_turtle_village_foreground_blocks
        .dc.l   map_turtle_village_foreground_map

        /* Map dimensions */
        .dc.w   map_turtle_village_block_height
        .dc.w   map_turtle_village_block_width

        /* Initial scroll positions in blocks */
        .dc.w   0       // Vertical
        .dc.w   0       // Horizontal

        /* Event list */
        .dc.l   turtle_village_event_list
        .dc.l   turtle_village_extended_event_data_table

        /* Height map data */
        .dc.l   map_turtle_village_height_map
        .dc.l   map_turtle_village_height_blocks

        /* Entity load list */
        .dc.l   turtle_village_entity_load_list

        /* Player starting positions */
        .dc.w   0       // Player 1 Y (Baseline relative offset)
        .dc.w   248     // Player 1 X
        .dc.w   0       // Player 2 Y (Baseline relative offset)
        .dc.w   288     // Player 2 X

        /* Music id */
        .dc.w   SONG_TURTLE_VILLAGE


    /**********************************************************
     * Y base line list
     */
    patch_start 0x008782
        .dc.l   turtle_village_y_baseline   // Patch y base line table entry
    patch_end

    turtle_village_y_baseline:
        .dc.w   0x0000

        .dc.w   map_turtle_village_pixel_width
        .dc.w   128


    /**********************************************************
     * Event list
     */
    turtle_village_event_list:
        .dc.w   304
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x01

        .dc.w   992
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x02

        .dc.w   1000
        .dc.b   MAP_EVENT_START_BOSS_MUSIC
        .dc.b   0x00

        .dc.w   1216
        .dc.b   MAP_EVENT_CAMPSITE_ON_ENEMY_DEFEAT
        .dc.b   0x00

        .dc.w   1280
        .dc.b   MAP_EVENT_NOTHING
        .dc.b   0x00

    turtle_village_extended_event_data_table:


    /**********************************************************
     * Entity load list
     */

    turtle_village_entity_load_list:
        .dc.w   -1  // Terminate
