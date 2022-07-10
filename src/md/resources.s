|--------------------------------------------------------------------
| Global resources
|--------------------------------------------------------------------

    .include "mars.i"
    .include "marscomm.i"


    .global img_load_sega_logo
    .global img_load_dungeon_background


    .section .rodata
    .align      2


    sega_logo_image:            .incbin "img/sega.img"
    dungeon_background_image:   .incbin "img/bgdungeon.img"


    |-------------------------------------------------------------------
    | Show sega logo
    |-------------------------------------------------------------------
    img_load_sega_logo:
        move.l  #sega_logo_image, (MARS_REG_BASE + MARS_COMM4)
        bra     img_command


    |-------------------------------------------------------------------
    | Show arcade dungeon background
    |-------------------------------------------------------------------
    img_load_dungeon_background:
        move.l  #dungeon_background_image, (MARS_REG_BASE + MARS_COMM4)


    |-------------------------------------------------------------------
    | Send image load command
    |-------------------------------------------------------------------
    img_command:
        moveq   #MARSCOMM_IMAGE, %d0
        jmp     mars_comm
