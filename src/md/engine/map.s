/*
 * Patch in 32X map loading code
 */

#include "goldenaxe.h"
#include "mars.h"
#include "md.h"
#include "map.h"
#include "patch.h"
#include "marscomm.h"


    .comm map_extended_event_data_table, 4


    /*
     * Load graphics data in the following format (same as used by the map definition):
     * repeat:
     * - palette_address.l          (0=EOL)
     * repeat:
     * - vram_addr_set_command.l    (0=EOL)
     * - nemesis_data_address.l
     *
     * Parameters:
     * - a3: address of graphics lists
     *
     * Uses: d0,d1,d7,a0,a1,a3,a6
     */
    map_load_graphics:
        // Load palettes
    1:  move.l  (%a3)+, %d7
        beq     .no_palette
        movea.l %d7, %a6
        jsr     palette_update_dynamic
        movea.l %d7, %a6
        jsr     palette_update_base
        bra     1b
    .no_palette:
        bset    #0, (vblank_update_palette_flag)


    /*
     * Load graphics data in the following format (same as used by the map definition):
     * repeat:
     * - vram_addr_set_command.l    (0=EOL)
     * - nemesis_data_address.l
     *
     * Parameters:
     * - a3: address nemesis data list
     *
     * Uses: d0,d1,d7,a0,a1,a3,a6
     */
    map_load_tiles:
        // Load tile data
    1:  move.l  (%a3)+, %d7
        beq     .no_tile_data

        move.l  %d7, (VDP_CTRL)
        movea.l (%a3)+, %a0
        jsr     nemesis_decompress_vram
        bra     1b
    .no_tile_data:

        moveq   #0, %d7
        rts


    /**********************************************************
     * Patch background tile restore code after magic to use the same format as used by the map definition
     */
    patch_start 0x008d6a
        movea.l %a0, %a3
        jsr     map_load_tiles.l
        .rept 4
            nop
        .endr
    patch_end


    /**********************************************************
     * Patch map load code to store extended event data table address
     */
    patch_start 0x001560
        jsr     md_load_map.l
    patch_end

    md_load_map:
        move.w  (%a5)+, %d1
        move.l  (%a5)+, (next_event_trigger)
        move.l  (%a5)+, (map_extended_event_data_table)
        rts


    /**********************************************************
     * Patch entity trigger load code to load entity load slot descriptor address directly from entity load list.
     * Instead of from a global lookup table
     */
    patch_start 0x013914
        .rept 6
            nop
        .endr
        movea.l (%a6)+, %a2
        move.l  %a6, (next_entity_load_trigger).w
    patch_end


    /**********************************************************
     * Patch map entity spawn code to load the graphics in the same (more flexible) format as used by the map definition
     * Instead of from multiple global lookup tables
     */
    patch_start 0x01396a
        tst.w   (%a3)           // .load_allowed_with_active_enemies changed to word for alignment reasons
    patch_end

    patch_start 0x013982
        jsr     map_load_entity_graphics.l
    patch_end

    map_load_entity_graphics:
        addq.l  #2, %a3
        jmp     map_load_graphics


    /**********************************************************
     * Patch gameplay init code to load the 32X map
     */
    patch_start 0x00139e
        jsr     mars_load_map.l
        nop
        nop
        nop
    patch_end

    mars_load_map:
        mars_comm_call_start

        // Setup map command load parameters
        lea     (MARS_REG_BASE), %a0
        move.w  (vertical_scroll), %d5
        lsr.w   #4, %d5
        move.b  %d5, MARS_COMM_MASTER + MARS_COMM_P1_H(%a0)             // vertical scroll in 16px units
        move.w  (horizontal_scroll), %d5
        lsr.w   #4, %d5
        move.b  %d5, MARS_COMM_MASTER + MARS_COMM_P1_L(%a0)             // horizontal scroll in 16px units
        move.w  (current_level), MARS_COMM_MASTER + MARS_COMM_P2(%a0)   // current map index

        // Send map load command
        mars_comm MARS_COMM_MASTER, MARS_COMM_CMD_MAP_LOAD

        jsr     vdp_enable_display
        jsr     palette_interpolate_full

        mars_comm   MARS_COMM_MASTER, MARS_COMM_CMD_DISPLAY_ENABLE
        mars_comm_call_end

        andi    #0xf8ff, %sr
        rts


    /**********************************************************
     * Patch map scroll routine to scroll on the 32X also
     */
    patch_start 0x000f6a
        jmp     mars_scroll_map.l
    patch_end

    mars_scroll_map:
        mars_comm_call_start
        mars_comm_p2 MARS_COMM_MASTER, MARS_COMM_CMD_MAP_SCROLL, vertical_scroll, horizontal_scroll
        mars_comm_call_end

        tst.w   %d7
        beq     .exit
        pea     0x000f70    // Resume original code after return

    .exit:
        rts
