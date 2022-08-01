/*
 * Town patches
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
    patch_start 0x0015b4
        .dc.l   town_map_definition   // Patch map table entry
    patch_end

        /* Extended map data is prefixed */
        .dc.l   town_entity_palette_table - 4           // The first entry is always ignored so offset for that
        .dc.l   town_entity_group_graphics_table - 4    // The first entry is always ignored so offset for that
        .dc.l   town_entity_load_slot_descriptor_table
    town_map_definition:
        /* Palette list */
        .dc.l   hud_player_palette
        .dc.l   0

        /* Nemesis tile data list */
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   0

        /* Tile map data */
        .dc.l   map_town_foreground_blocks
        .dc.l   map_town_foreground_map

        /* Map dimensions */
        .dc.w   map_town_block_height
        .dc.w   map_town_block_width

        /* Initial scroll positions in blocks */
        .dc.w   6       // Vertical
        .dc.w   0       // Horizontal

        /* Event list */
        .dc.l   town_event_list

        /* Height map data */
        .dc.l   map_town_height_map
        .dc.l   map_town_height_blocks

        /* Entity load list */
        .dc.l   town_entity_load_list

        /* Player starting positions */
        .dc.w   0       // Player 1 Y (Baseline relative offset)
        .dc.w   256     // Player 1 X
        .dc.w   0       // Player 2 Y (Baseline relative offset)
        .dc.w   296     // Player 2 X

        /* Music id */
        .dc.w   SONG_TOWN


    /**********************************************************
     * Y base line list
     */
    patch_start 0x008786
        .dc.l   town_y_baseline   // Patch y base line table entry
    patch_end

    town_y_baseline:
        .dc.w   0x0000

        .dc.w   map_town_pixel_width
        .dc.w   240


    /**********************************************************
     * Event list
     */
    town_event_list:
        .dc.w   320
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x01

        .dc.w   1040
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x02

        .dc.w   1048
        .dc.b   MAP_EVENT_START_BOSS_MUSIC
        .dc.b   0x00

        .dc.w   1216
        .dc.b   MAP_EVENT_CAMPSITE_ON_ENEMY_DEFEAT
        .dc.b   0x00

        .dc.w   1280
        .dc.b   MAP_EVENT_NOTHING
        .dc.b   0x00


    /**********************************************************
     * Entity load list
     */

    town_entity_load_list:
        .dc.w   1280
        .dc.w   0

        .dc.w   -1


    town_entity_group_graphics_table:


    town_entity_palette_table:


    town_entity_load_slot_descriptor_table:
