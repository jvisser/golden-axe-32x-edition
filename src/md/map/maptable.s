/*
 * 32X map table
 */
 
#include "mars.h"


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

