|--------------------------------------------------------------------
| Global resources
|--------------------------------------------------------------------

    .global img_sega_logo
    .global img_dungeon_background
    .global img_title_background

    .global pat_amazon


    |--------------------------------------------------------------------
    | 32X SH2 sub program binary
    |--------------------------------------------------------------------
    .section    sh2
        .incbin "mars.bin"


    |--------------------------------------------------------------------
    | 32X resource directory mapped at 0x02080000 in the SH2 address space
    |--------------------------------------------------------------------
    .section    sh2_resources


    |--------------------------------------------------------------------
    | Game assets
    |--------------------------------------------------------------------
    .section    .rodata
    .balign     2

    img_sega_logo:              .incbin "img/sega.img"
    img_dungeon_background:     .incbin "img/bgdungeon.img"
    img_title_background:       .incbin "img/bgtitle.img"           | TODO: Tiled image support for the 32X... comper can't compress images like very well

    pat_amazon:                 .incbin "amazon.pat"                | Decompressed amazon tiledata
