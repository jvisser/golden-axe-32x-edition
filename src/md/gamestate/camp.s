/*
 * Camp site screen patches
 */

#include "goldenaxe.h"
#include "patch.h"
#include "marscomm.h"


    /**********************************************************
     * Select night palette
     */
    patch_start 0x0029d2
        jsr     game_state_handler_camp_init.l
        nop
    patch_end

    game_state_handler_camp_init:

        // Reset view and request night palette
        mars_comm_call_start
        mars_comm_p1 MARS_COMM_SLAVE,   MARS_COMM_CMD_MAP_PALETTE,  #0x0003
        mars_comm_p2 MARS_COMM_MASTER,  MARS_COMM_CMD_MAP_RESET,    vertical_scroll, horizontal_scroll
        mars_comm_call_end

        jsr     vdp_enable_display
        jsr     mars_comm_display_enable
        jmp     screen_transition_from_dark
