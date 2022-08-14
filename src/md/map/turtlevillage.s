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
        // Palette list
        .dc.l   hud_player_palette
        .dc.l   0

        // Nemesis tile data list
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   0

        // Tile map data
        .dc.l   map_turtle_village_foreground_blocks
        .dc.l   map_turtle_village_foreground_map

        // Map dimensions
        .dc.w   map_turtle_village_block_height
        .dc.w   map_turtle_village_block_width

        // Initial scroll positions in blocks
        .dc.w   0       // Vertical
        .dc.w   0       // Horizontal

        // Event list
        .dc.l   turtle_village_event_list
        .dc.l   turtle_village_extended_event_data_table

        // Height map data
        .dc.l   map_turtle_village_height_map
        .dc.l   map_turtle_village_height_blocks

        // Entity load list
        .dc.l   turtle_village_entity_load_list

        // Player starting positions
        .dc.w   0       // Player 1 Y (Baseline relative offset)
        .dc.w   248     // Player 1 X
        .dc.w   0       // Player 2 Y (Baseline relative offset)
        .dc.w   288     // Player 2 X

        // Music id
        .dc.w   SONG_TURTLE_VILLAGE


    /**********************************************************
     * Patch map background tile data graphics table entry
     * This is used to reload the relevant background tiles when magic attacks that use the background plane are finished.
     */
    patch_start 0x009140
        .dc.l   turtle_village_tile_restore_list
    patch_end

    turtle_village_tile_restore_list:
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   0


    /**********************************************************
     * Y base line list
     */
    patch_start 0x008782
        .dc.l   turtle_village_y_baseline   // Patch y base line table entry
    patch_end

    turtle_village_y_baseline:
        .dc.w   8

        .dc.w   408
        .dc.w   128

        .dc.w   448
        .dc.w   156

        .dc.w   504
        .dc.w   184

        .dc.w   560
        .dc.w   224

        .dc.w   632
        .dc.w   244

        .dc.w   912
        .dc.w   260

        .dc.w   1192
        .dc.w   232

        .dc.w   1224
        .dc.w   208

        .dc.w   map_turtle_village_pixel_width
        .dc.w   184


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
        .dc.b   MAP_EVENT_CHANGE_MUSIC
        .dc.b   SONG_BOSS

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


    /**********************************************************
     * Camp site
     */

    // Camp site vertical scroll
    patch_start 0x002a88
        .dc.w   184 + (6 * 8) - (224 / 2)
    patch_end

    // Camp site entity load group descriptor (thiefs)
    patch_start 0x002b20
        .dc.l   turtle_village_camp_map_entity_load_group_descriptor   // Patch table entry
    patch_end

    turtle_village_camp_map_entity_load_group_descriptor:
        .dc.w   0   // Load allowed when there are active enemies?
        .dc.l   0   // Palette list
        .dc.l   0   // Nemesis tile data list
        .dc.w   2   // Number of entities
            map_entity_definition 0, ENTITY_TYPE_THIEF, 176, 96, 0x3A3, ENTITY_TYPE_THIEF_BLUE(3) | 0x8000
            map_entity_definition 1, ENTITY_TYPE_THIEF, 192, 64, 0x3A3, ENTITY_TYPE_THIEF_GREEN(1)
