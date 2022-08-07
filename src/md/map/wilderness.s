/*
 * Wilderness patches
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
    patch_start 0x0015ac
        .dc.l   wilderness_map_definition   // Patch map table entry
    patch_end

    wilderness_map_definition:
        // Palette list
        .dc.l   hud_player_palette
        .dc.l   0

        // Nemesis tile data list
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   0

        // Tile map data
        .dc.l   map_wilderness_foreground_blocks
        .dc.l   map_wilderness_foreground_map

        // Map dimensions
        .dc.w   map_wilderness_block_height
        .dc.w   map_wilderness_block_width

        // Initial scroll positions in blocks
        .dc.w   0       // Vertical
        .dc.w   4       // Horizontal

        // Event list
        .dc.l   wilderness_event_list
        .dc.l   wilderness_extended_event_data_table

        // Height map data
        .dc.l   map_wilderness_height_map
        .dc.l   map_wilderness_height_blocks

        // Entity load list
        .dc.l   wilderness_entity_load_list

        // Player starting positions
        .dc.w   0       // Player 1 Y (Baseline relative offset)
        .dc.w   112     // Player 1 X
        .dc.w   16      // Player 2 Y (Baseline relative offset)
        .dc.w   80      // Player 2 X

        // Music id
        .dc.w   SONG_WILDERNESS


    /**********************************************************
     * Patch map background tile data graphics table entry to point to empty tile data for each entry
     * This is used to reload the relevant background tiles when magic attacks that use the background plane are finished.
     */
    patch_start 0x00913c
        .dc.l   wilderness_tile_restore_list
    patch_end

    wilderness_tile_restore_list:
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   0


    /**********************************************************
     * Y base line list
     */
    patch_start 0x00877e
        .dc.l   wilderness_y_baseline   // Patch y base line table entry
    patch_end

    wilderness_y_baseline:
        .dc.w   0x0000

        .dc.w   map_wilderness_pixel_width
        .dc.w   188


    /**********************************************************
     * Event list
     */
    wilderness_event_list:
        .dc.w   320
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x01

        .dc.w   952
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x02

        .dc.w   960
        .dc.b   MAP_EVENT_CHANGE_MUSIC
        .dc.b   SONG_BOSS

        .dc.w   1216
        .dc.b   MAP_EVENT_CAMPSITE_ON_ENEMY_DEFEAT
        .dc.b   0x00

        .dc.w   1280
        .dc.b   MAP_EVENT_NOTHING
        .dc.b   0x00

    wilderness_extended_event_data_table:


    /**********************************************************
     * Entity load list
     */
    wilderness_entity_load_list:
        .dc.w   -1  // Terminate


    /**********************************************************
     * Camp site
     */

    // Camp site vertical scroll
    patch_start 0x002a86
        .dc.w   0
    patch_end

    // Camp site entity load group descriptor (thiefs)
    patch_start 0x002b1c
        .dc.l   wilderness_camp_map_entity_load_group_descriptor   // Patch table entry
    patch_end

    wilderness_camp_map_entity_load_group_descriptor:
        .dc.w   0   // Load allowed when there are active enemies?
        .dc.l   0   // Palette list
        .dc.l   0   // Nemesis tile data list
        .dc.w   1   // Number of entities
            map_entity_definition 0, ENTITY_TYPE_THIEF, 176, 96, 0x3A3, ENTITY_TYPE_THIEF_BLUE(2) | 0x8000
