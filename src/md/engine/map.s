/*
 * Patch in 32X map loading code
 */

#include "goldenaxe.h"
#include "mars.h"
#include "map.h"
#include "patch.h"
#include "marscomm.h"

    /**********************************************************
     * Variables
     */
    .lcomm current_entity_load_slot_descriptor_table, 4
    .lcomm current_entity_group_graphics_table, 4
    .lcomm current_entity_palette_table, 4
    .lcomm current_map_offset, 2


    /**********************************************************
     * 32X map table mapped at 0x22080000 in the SH2 address space (see md.ld)
     * Content in sync with MD map table at 0x0015ac
     */
    .section    sh2_map_table

    mars_map_table:
        .dc.l   SH2_ROM_BASE + map_wilderness_mars
        .dc.l   SH2_ROM_BASE + map_turtle_village_mars
        .dc.l   SH2_ROM_BASE + map_town_mars
        .dc.l   SH2_ROM_BASE + map_fiends_path_mars
        .dc.l   SH2_ROM_BASE + map_eagles_head_mars
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   SH2_ROM_BASE + map_wilderness_mars


    .text


    /**********************************************************
     * Patch map load code to store the offset of the loaded map
     */
    patch_start 0x0014fe
        jsr     md_load_map.l
    patch_end

    md_load_map:
        move.w  %d0, (current_map_offset)
        lea     (map_table), %a5
        rts


    /**********************************************************
     * Patch entity load code to load from the address in current_* addresses
     */
    patch_start 0x01391a
        movea.l (current_entity_load_slot_descriptor_table).l, %a2
    patch_end

    patch_start 0x013a02
        movea.l (current_entity_group_graphics_table).l, %a4
    patch_end

    patch_start 0x013a5a
        movea.l (current_entity_palette_table).l, %a6
    patch_end


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
        /* Set default addresses */
        move.l  #map_entity_load_slot_descriptor_table, (current_entity_load_slot_descriptor_table)
        move.l  #map_entity_group_graphics_table, (current_entity_group_graphics_table)
        move.l  #map_entity_palette_table, (current_entity_palette_table)

        mars_comm_call_start

        /* Setup map command load parameters */
        lea     (MARS_REG_BASE), %a0
        move.w  (vertical_scroll), %d5
        lsr.w   #4, %d5
        move.b  %d5, MARS_COMM_MASTER + MARS_COMM_P1_H(%a0)             // vertical scroll in 16px units
        move.w  (horizontal_scroll), %d5
        lsr.w   #4, %d5
        move.b  %d5, MARS_COMM_MASTER + MARS_COMM_P1_L(%a0)             // horizontal scroll in 16px units
        move.w  (current_level), MARS_COMM_MASTER + MARS_COMM_P2(%a0)   // current map index

        /* Send map load command */
        mars_comm MARS_COMM_MASTER, MARS_COMM_CMD_MAP_LOAD

        jsr     vdp_enable_display
        jsr     palette_interpolate_full

        /* Check if there is custom map override */
        lea     (mars_map_table), %a0
        move.w  (current_map_offset), %d5
        tst.l   (%a0, %d5)
        beq     .no_map

        /* Override entity data table addresses to the ones supplied by the custom map */
        lea     (map_table), %a0
        movea.l (%a0, %d5), %a0

        /* Override table addresses are prefixed to the map definition */
        move.l  -(%a0), (current_entity_load_slot_descriptor_table)
        move.l  -(%a0), (current_entity_group_graphics_table)
        move.l  -(%a0), (current_entity_palette_table)

        /* Enable 32X display only if there is a map in the map table for the current level */
        mars_comm   MARS_COMM_MASTER, MARS_COMM_CMD_DISPLAY_ENABLE

    .no_map:
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
