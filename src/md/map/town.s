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

    town_map_definition:
        // Palette list
        .dc.l   hud_player_palette
        .dc.l   0

        // Nemesis tile data list
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   0

        // Tile map data
        .dc.l   map_town_foreground_blocks
        .dc.l   map_town_foreground_map

        // Map dimensions
        .dc.w   map_town_block_height
        .dc.w   map_town_block_width

        // Initial scroll positions in blocks
        .dc.w   6       // Vertical
        .dc.w   0       // Horizontal

        // Event list
        .dc.l   town_event_list
        .dc.l   town_extended_event_data_table

        // Height map data
        .dc.l   map_town_height_map
        .dc.l   map_town_height_blocks

        // Entity load list
        .dc.l   town_entity_load_list

        // Player starting positions
        .dc.w   0       // Player 1 Y (Baseline relative offset)
        .dc.w   256     // Player 1 X
        .dc.w   0       // Player 2 Y (Baseline relative offset)
        .dc.w   296     // Player 2 X

        // Music id
        .dc.w   SONG_TOWN


    /**********************************************************
     * Patch map background tile data graphics table entry to point to empty tile data for each entry
     * This is used to reload the relevant background tiles when magic attacks that use the background plane are finished.
     */
    patch_start 0x009144
        .dc.l   town_tile_restore_list
    patch_end

    town_tile_restore_list:
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   0


    /**********************************************************
     * Y base line list
     */
    patch_start 0x008786
        .dc.l   town_y_baseline   // Patch y base line table entry
    patch_end

    town_y_baseline:
        .dc.w   3

        .dc.w   408
        .dc.w   240

        .dc.w   576
        .dc.w   216

        .dc.w   1248
        .dc.w   232

        .dc.w   map_town_pixel_width
        .dc.w   176


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
        .dc.b   MAP_EVENT_CHANGE_MUSIC
        .dc.b   SONG_BOSS

        .dc.w   1216
        .dc.b   MAP_EVENT_CAMPSITE_ON_ENEMY_DEFEAT
        .dc.b   0x00

        .dc.w   1280
        .dc.b   MAP_EVENT_NOTHING
        .dc.b   0x00

    town_extended_event_data_table:


    /**********************************************************
     * Entity load list
     */
    town_entity_load_list:
        .dc.w   -1  // Terminate


    /**********************************************************
     * Camp site
     */

    // Camp site vertical scroll
    patch_start 0x002a8a
        .dc.w   176 - 224/2
    patch_end

    // Camp site entity load group descriptor (thiefs)
    patch_start 0x002b24
        .dc.l   town_camp_map_entity_load_group_descriptor   // Patch table entry
    patch_end

    town_camp_map_entity_load_group_descriptor:
        .dc.w   0   // Load allowed when there are active enemies?
        .dc.l   0   // Palette list
        .dc.l   0   // Nemesis tile data list
        .dc.w   4   // Number of entities
            map_entity_definition 0, ENTITY_TYPE_THIEF, 176, 96, 0x3A3, ENTITY_TYPE_THIEF_BLUE(1) | 0x8000
            map_entity_definition 1, ENTITY_TYPE_THIEF, 184, 96, 0x3A3, ENTITY_TYPE_THIEF_GREEN(1)
            map_entity_definition 2, ENTITY_TYPE_THIEF, 192, 32, 0x3A3, ENTITY_TYPE_THIEF_BLUE(1)
            map_entity_definition 3, ENTITY_TYPE_THIEF, 176, 32, 0x3A3, ENTITY_TYPE_THIEF_GREEN(1)
