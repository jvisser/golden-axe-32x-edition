|--------------------------------------------------------------------
| Global resources
|--------------------------------------------------------------------

    .global img_sega_logo
    .global img_dungeon_background

    .global pat_amazon


    |--------------------------------------------------------------------
    | SH2 sub program binary
    |--------------------------------------------------------------------
    .section    sh2
        .incbin "mars.bin"


    |--------------------------------------------------------------------
    | Game assets
    |--------------------------------------------------------------------
    .section    .rodata
    .align      2

    img_sega_logo:              .incbin "img/sega.img"
    img_dungeon_background:     .incbin "img/bgdungeon.img"
    pat_amazon:                 .incbin "amazon.pat"                | Decompressed amazon tiledata
