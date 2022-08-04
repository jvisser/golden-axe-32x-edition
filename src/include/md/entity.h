/*
 * Golden Axe entity macros/constants
 */

#ifndef __ENTITY_H__
#define __ENTITY_H__

#include "md.h"


/**********************************************************
 * Entity types
 */

#define ENTITY_TYPE_NONE                                0x00
#define ENTITY_TYPE_THIEF                               0x1e
#define ENTITY_TYPE_ROPE                                0x2b
#define ENTITY_TYPE_KING                                0x2c
#define ENTITY_TYPE_QUEEN                               0x2d
#define ENTITY_TYPE_SKELETON_1                          0x2e
#define ENTITY_TYPE_SKELETON_2_FROM_HOLE                0x2f
#define ENTITY_TYPE_SKELETON_3                          0x30
#define ENTITY_TYPE_HENINGER_SILVER                     0x31
#define ENTITY_TYPE_HENINGER_PURPLE                     0x32
#define ENTITY_TYPE_HENINGER_RED                        0x33
#define ENTITY_TYPE_HENINGER_GOLD                       0x34
#define ENTITY_TYPE_HENINGER_DARK                       0x35
#define ENTITY_TYPE_HENINGER_BRONZE                     0x36
#define ENTITY_TYPE_HENINGER_GREEN                      0x37
#define ENTITY_TYPE_LONGMOAN_SILVER                     0x38
#define ENTITY_TYPE_LONGMOAN_PURPLE                     0x39
#define ENTITY_TYPE_LONGMOAN_RED                        0x3a
#define ENTITY_TYPE_LONGMOAN_GOLD                       0x3b
#define ENTITY_TYPE_LONGMOAN_DARK                       0x3c
#define ENTITY_TYPE_LONGMOAN_BRONZE                     0x3d
#define ENTITY_TYPE_LONGMOAN_GREEN                      0x3e
#define ENTITY_TYPE_BAD_BROTHER_GREEN                   0x3f
#define ENTITY_TYPE_BAD_BROTHER_BLUE                    0x40
#define ENTITY_TYPE_BAD_BROTHER_RED                     0x41
#define ENTITY_TYPE_AMAZON_1                            0x42
#define ENTITY_TYPE_AMAZON_2                            0x43
#define ENTITY_TYPE_AMAZON_3                            0x44
#define ENTITY_TYPE_AMAZON_4                            0x45
#define ENTITY_TYPE_AMAZON_5                            0x46
#define ENTITY_TYPE_BITTER_SILVER                       0x47
#define ENTITY_TYPE_BITTER_RED                          0x48
#define ENTITY_TYPE_BITTER_GOLD                         0x49
#define ENTITY_TYPE_DEATH_ADDER                         0x4a
#define ENTITY_TYPE_DEATH_BRINGER                       0x4b
#define ENTITY_TYPE_DEATH_ADDER_JR                      0x4c
#define ENTITY_TYPE_BLUE_DRAGON                         0x4d
#define ENTITY_TYPE_RED_DRAGON                          0x4e
#define ENTITY_TYPE_CHICKEN_LEG                         0x4f
#define ENTITY_TYPE_VILLAGER_1                          0x56
#define ENTITY_TYPE_VILLAGER_2                          0x57
#define ENTITY_TYPE_SKELETON_4                          0x60

#define ENTITY_TYPE_THIEF_BLUE(item_count)              (item_count)
#define ENTITY_TYPE_THIEF_GREEN(item_count)             (0x0080 | item_count)


/**********************************************************
 * Entity graphics data
 */

#define entity_nemesis_data_table                       0x00013a74

// Nemesis data table offsets
#define ENTITY_NEMESIS_OFFSET_THIEF                     0x00
#define ENTITY_NEMESIS_OFFSET_BAD_BROTHER               0x04
#define ENTITY_NEMESIS_OFFSET_DEATH ADDER               0x08
#define ENTITY_NEMESIS_OFFSET_BITTER                    0x0c
#define ENTITY_NEMESIS_OFFSET_CHICKEN_LEG               0x10
#define ENTITY_NEMESIS_OFFSET_DRAGON                    0x14
#define ENTITY_NEMESIS_OFFSET_VILLAGERS                 0x18
#define ENTITY_NEMESIS_OFFSET_KING_AND_QUEEN            0x1c
#define ENTITY_NEMESIS_OFFSET_DEATH_ADDER_SPECIAL       0x20

// Absolute nemesis data addresses
#define nem_pat_chicken_leg                             0x00040e8a
#define CHICKEN_LEG_TILE_COUNT                          176

#define nem_pat_bad_brother                             0x0007532a
#define BAD_BROTHER_TILE_COUNT                          531

#define nem_death_adder                                 0x00077d6e
#define NEM_DEATH_ADDER_TILE_COUNT                      232

#define nem_death_adder_special                         0x0005fc2a
#define NEM_DEATH_ADDER_SPECIAL_TILE_COUNT              45

#define nem_death_adder_special_explosion               0x00032c8e
#define NEM_DEATH_ADDER_SPECIAL_EXPLOSION_TILE_COUNT    81

#ifdef __ASSEMBLER__

/**********************************************************
 * Assembler macros
 */

.macro map_entity_definition slot, id, base_y, x, tile_id=0, init_value=0
    .dc.b   \slot
    .dc.b   \id
    .dc.w   \base_y
    .dc.w   (\x) + 128
    .dc.w   \tile_id        // Ignored for entity types that use DMA for animation frame updates
    .dc.w   \init_value
.endm


.macro entity_palette offset, count, palettes:vararg
    .dc.b \offset, \count - 1
    .irp palette_name, \palettes
        entity_palette_\palette_name
    .endr
.endm

/**********************************************************
 * Partial palette macros
 */

// Palette 1:5: Amazon
// Palette 2:5: Chicken leg
.macro entity_palette_yellow_3
    .irp color, 0x00cc, 0x0088, 0x0044
        .dc.w \color
    .endr
.endm

// Palette 2:8: Chicken leg
.macro entity_palette_purple_3
    .irp color, 0x0e6e, 0x0a4a, 0x0606
        .dc.w \color
    .endr
.endm

// Palette 1:8: All
.macro entity_palette_skin_4
    .irp color, 0x068c, 0x046a, 0x0248, 0x0026
        .dc.w \color
    .endr
.endm

// Palette 2:11 Dragon flame
.macro entity_palette_flame_5
    .irp color, 0x0008, 0x000e, 0x008e, 0x00ce, 0x0cee
        .dc.w \color
    .endr
.endm

// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
.macro entity_palette_silver_4
    .irp color, 0x0cc6, 0x0882, 0x0440, 0x0220
        .dc.w \color
    .endr
.endm

// Palette 1:1: Amazon
// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
.macro entity_palette_green_4
    .irp color, 0x08c4, 0x0682, 0x0460, 0x0240
        .dc.w \color
    .endr
.endm

// Palette 1:1: Amazon
.macro entity_palette_purple1_4
    .irp color, 0x0e4c, 0x0828, 0x0404, 0x0002
        .dc.w \color
    .endr
.endm

// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
.macro entity_palette_purple2_4
    .irp color, 0x0e8c, 0x0c4a, 0x0806, 0x0402
        .dc.w \color
    .endr
.endm

// Palette 1:1: Amazon
// Palette 1:1: Red dragon
.macro entity_palette_red1_4
    .irp color, 0x086e, 0x060c, 0x0208, 0x0002
        .dc.w \color
    .endr
.endm

// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
.macro entity_palette_red2_4
    .irp color, 0x066e, 0x022c, 0x0008, 0x0004
        .dc.w \color
    .endr
.endm

// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
.macro entity_palette_gold_4
    .irp color, 0x02cc, 0x0066, 0x0044, 0x0022
        .dc.w \color
    .endr
.endm

// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
// Palette 1:8: All skin
.macro entity_palette_dark_4
    .irp color, 0x0666, 0x0444, 0x0222, 0x0000
        .dc.w \color
    .endr
.endm

// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
// Palette 1:8: All skin
.macro entity_palette_bronze_4
    .irp color, 0x06A4, 0x0462, 0x0240, 0x0020
        .dc.w \color
    .endr
.endm

// Palette 2:1: Blue dragon
.macro entity_palette_blue1_4
    .irp color, 0x0ca6, 0x0864, 0x0642, 0x0220
        .dc.w \color
    .endr
.endm

// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
.macro entity_palette_blue2_4
    .irp color, 0x0a84, 0x0642, 0x0420, 0x0200
        .dc.w \color
    .endr
.endm

#endif

#endif
