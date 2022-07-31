/*
 * Demo/attract mode patches
 */

#include "md.h"
#include "patch.h"


    /**********************************************************
     * Disable demo ending transition like the arcade version
     */
    patch_start 0x001980
        nop
        nop
    patch_end


    .section .rodata

    .balign 2


    /**********************************************************
     * Demo configuration
     *
     * Demo is stored as follows
     *  - level_number.b
     *  - map_offset.b
     *  - player_character.b
     *  - magic_flask_count.b
     */
    patch_start 0x001a7a
        /* Demo 1: Ax */
        .dc.b       0       /* Wilderness */
        .dc.b       0x28    /* Demo map offset */
        .dc.b       0       /* Ax */
        .dc.b       4       /* Flask count */
        /* Demo 2: Tyris */
        .dc.b       0       /* Wilderness */
        .dc.b       0x28    /* Demo map offset */
        .dc.b       1       /* Tyris */
        .dc.b       4       /* Flask count */
        /* Demo 2: Gilius */
        .dc.b       0       /* Wilderness */
        .dc.b       0x28    /* Demo map offset */
        .dc.b       2       /* Gilius */
        .dc.b       1       /* Flask count */
    patch_end


    /**********************************************************
     * Input commands
     *
     * Inputs are stored in the following format
     *  - repeat_count.b
     *  - controller_input.b
     */

    /* Patch controller input pointers. It seems they prepared for 2 player inputs but never implemented it? */
    patch_start 0x001a86
        /* Demo 1: Ax */
        .dc.l   demo_controller_data
        .dc.l   demo_controller_data
        /* Demo 2: Tyris */
        .dc.l   demo_controller_data
        .dc.l   demo_controller_data
        /* Demo 3: Gilius */
        .dc.l   demo_controller_data
        .dc.l   demo_controller_data
    patch_end

    demo_controller_data:
        /* Walk right */
        .dc.b   72
        .dc.b   CTRL_RIGHT

        /* Use magic */
        .dc.b   1
        .dc.b   CTRL_A

        /* Wait until magic done */
        .dc.b   255
        .dc.b   0

        /* End of input/demo */
        .dc.b   0
