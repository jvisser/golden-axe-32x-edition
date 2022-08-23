/*
 * Bad brother entity patches
 */

#include "entity.h"
#include "patch.h"


    /**********************************************************
     * Add a configurable spawn delay to bad brother blue.
     * This removes support for duel mode though.
     */
    patch_start 0x010250
        btst    #7, (%a0)
        nop
    patch_end

    patch_start 0x01025a
        subq.w  #1, entity_map_init_data(%a0)
        bcc.s   .skip_init
        bset    #7, (%a0)

        // Spawn door
        jsr     find_free_entity_slot.l
        move.w  #ENTITY_TYPE_TOWN_DOOR << 8, entity_id(%a5)

        move.b  #0x1c, entity_state_main(%a0)
        move.b  #0x30, entity_hp(%a0)

    .skip_init:
        .rept 6
            nop
        .endr
    patch_end
