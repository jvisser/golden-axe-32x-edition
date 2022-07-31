/*
 * Map event system patches
 */

#include "patch.h"
#include "marscomm.h"
#include "map.h"


    /**********************************************************
     * Patch palette transition event to run on the 32X
     */
    patch_start 0x001da8
        jmp     map_event_palette_transition
    patch_end

    map_event_palette_transition:
        move.w  #0x0100, %d0                /* Request transition */
        move.b  MAP_EVENT_DATA(%a0), %d0    /* Set target palette index */

        clr.b  MAP_EVENT_ID(%a0)            /* Unregister event immediately */

        mars_comm_call_start
        mars_comm_p1 MARS_COMM_SLAVE, MARS_COMM_CMD_MAP_PALETTE, %d0
        mars_comm_call_end
        rts
