/*
 * Global resources
 */

    /**********************************************************
     * 32X SH2 sub program binary
     */
    .section    sh2
        .incbin "mars.bin"


    /**********************************************************
     * Game assets
     */
    .section    .rodata

    .altmacro

    .macro resource name, file_name
        .global \name
        .balign 2
        \name:
        .incbin \file_name
    .endm


    resource img_sega_logo,             "img/sega.img"
    resource img_death_adder,           "img/deathadder.img"
    resource img_dungeon_background,    "img/bgdungeon.img"
    resource img_title_background,      "img/bgtitle.img"

    resource pat_amazon,                "amazon.pat"                // Decompressed amazon tiledata

    resource nem_pat_empty,             "empty.pat.nem"
    resource nem_pat_water_transparent, "water.pat.nem"             // Replacement for turtle village water

    resource nem_pat_hole,              "pattern/hole.pat.nem"
    resource tmap_hole,                 "pattern/hole.tmap"


    .noaltmacro
