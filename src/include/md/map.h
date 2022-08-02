/*
 * Golden Axe map macros/constants
 */

#ifndef __MAP_H__
#define __MAP_H__

#include "md.h"


/**********************************************************
 * Map event
 */

#define MAP_EVENT_NOTHING                               0x00
#define MAP_EVENT_PALETTE_TRANSITION                    0x04
#define MAP_EVENT_CAMERA_UP_ON_HORIZONTAL_MOVEMENT      0x08
#define MAP_EVENT_VERTICAL_SCROLL_LIMITS                0x0c
#define MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT                 0x10
#define MAP_EVENT_CAMERA_TRANSITION                     0x14
#define MAP_EVENT_CAMPSITE_ON_ENEMY_DEFEAT              0x18
#define MAP_EVENT_NEXT_LEVEL_ON_ENEMY_DEFEAT            0x1c
#define MAP_EVENT_END_GAME_ON_ENEMY_DEFEAT              0x20
#define MAP_EVENT_START_WATER_ANIMATION                 0x24
#define MAP_EVENT_START_FEATHER_ANIMATION               0x28
#define MAP_EVENT_START_BOSS_MUSIC                      0x2c

// Event structure
#define MAP_EVENT_ID                                    0x00
#define MAP_EVENT_DATA                                  0x01


/**********************************************************
 * Entity graphics data (preloaded by map system)
 */

#define hud_player_palette                              0x00038492

#define map_table                                       0x000015ac
#define next_event_trigger                              0xffffc22a
#define next_entity_load_trigger                        0xffffc26e

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
#define chicken_leg_tile_count                          176

#define nem_pat_bad_brother                             0x0007532a
#define bad_brother_tile_count                          531

#endif
