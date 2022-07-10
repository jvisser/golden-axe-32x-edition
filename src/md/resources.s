|--------------------------------------------------------------------
| Global resources
|--------------------------------------------------------------------

    .global sega_logo_image
    .global dungeon_background_image

    .section .rodata
    .align      2

    sega_logo_image:            .incbin "img/sega.img"
    dungeon_background_image:   .incbin "img/bgdungeon.img"
