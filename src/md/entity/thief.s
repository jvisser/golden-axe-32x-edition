/*
 * Thief entity patches
 */

#include "entity.h"
#include "patch.h"


    /**********************************************************
     * Always drop item towards the player
     */
    patch_start 0x00ae0c
        jsr     entity_logic_thief_drop_item.l
        nop
        nop
    patch_end

    entity_logic_thief_drop_item:
        move.l  entity_interacting_entity(%a0), %a1
        move.w  entity_x(%a0), %d1
        cmp.w   entity_x(%a1), %d1
        ble     .direction_ok
        neg.l   %d0
    .direction_ok:
        rts
