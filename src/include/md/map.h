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
#define MAP_EVENT_CHANGE_MUSIC                          0x2c    // Repurposed MAP_EVENT_START_BOSS_MUSIC

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


#endif
