|--------------------------------------------------------------------
| Patch in 32X map loading code
|--------------------------------------------------------------------

    .include "goldenaxe.i"
    .include "patch.i"
    .include "marscomm.i"


    .section    sh2_map_table

    |--------------------------------------------------------------------
    | 32X map table mapped at 0x02080000 in the SH2 address space (see md.ld)
    | Content in sync with MD map table at 0x0015ac
    |--------------------------------------------------------------------
    mars_map_table:
        .dc.l   map_wilderness_mars
        .dc.l   map_turtle_village_mars
        .dc.l   map_town_mars
        .dc.l   map_fiends_path_mars
        .dc.l   map_eagles_head_mars
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0


    .text

    |-------------------------------------------------------------------
    | Patch gameplay init code to load the 32X map
    |-------------------------------------------------------------------
    patch_start 0x00139e
        jsr     mars_load_map.l
        nop
    patch_end

    mars_load_map:
        move.l  %a0, -(%sp)

        mars_comm_call_start

        | Setup map load parameters
        lea     (MARS_REG_BASE), %a0
        move.w  (vertical_scroll), %d5
        lsr.w   #4, %d5
        move.b  %d5, MARS_COMM_MASTER + MARS_COMM_P1_H(%a0)             | vertical scroll in 16px units
        move.w  (horizontal_scroll), %d5
        lsr.w   #4, %d5
        move.b  %d5, MARS_COMM_MASTER + MARS_COMM_P1_L(%a0)             | horizontal scroll in 16px units
        move.w  (current_level), MARS_COMM_MASTER + MARS_COMM_P2(%a0)   | current map index

        | TODO: Send map load command
        |mars_comm MARS_COMM_MASTER, MARS_COMM_MAP_LOAD

        | Enable 32X display only if there is a map in the map table for the current level
        lea     (mars_map_table), %a0
        move.w  (current_level), %d5
        add.w   %d5, %d5
        add.w   %d5, %d5
        tst.l   (%a0, %d5)
        beq     .no_map

        mars_comm   MARS_COMM_MASTER, MARS_COMM_CMD_DISPLAY_ENABLE
    .no_map:
        mars_comm_call_end

        move.l  (%sp)+, %a0

        andi    #0xf8ff, %sr
        jsr     vdp_enable_display
        rts
