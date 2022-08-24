/*
 * Villager entity patches
 */

#include "entity.h"
#include "patch.h"


    /**********************************************************
     * Allow speed to be configured from the map definition as a 4.12 fixed point value
     */
    patch_start 0x013882
        jsr     entity_logic_villager_set_speed.l
        nop
    patch_end

    patch_start 0x01389c
        jsr     entity_logic_villager_set_speed.l
        nop
    patch_end

    entity_logic_villager_set_speed:
        move.w  entity_map_init_data(%a0), %d0
        ext.l   %d0
        asl.l   #4, %d0     // Convert 4.12 fixed point to 16.16 fixed point
        move.l  %d0, entity_x_increment(%a0)
        rts
