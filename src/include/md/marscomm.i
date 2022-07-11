|--------------------------------------------------------------------
| 32X sub program commands
|--------------------------------------------------------------------

    .ifnotdef   __MARS_COMM_I__
    .equ        __MARS_COMM_I__, 1

    .include "mars.i"


    |--------------------------------------------------------------------
    | Commands
    |--------------------------------------------------------------------
    .equ MARSCOMM_DISABLE,      0x01
    .equ MARSCOMM_IMAGE,        0x02


    |--------------------------------------------------------------------
    | Ensures all used registers are preserved
    |--------------------------------------------------------------------
    .macro mars_comm_safe command
        move.w  %d0, -(%sp)
        move.w  #\command, %d0
        jsr     mars_comm
        move.w  (%sp)+, %d0
    .endm


    |--------------------------------------------------------------------
    | Send image command with the specified image
    |--------------------------------------------------------------------
    .macro mars_comm_image image
        move.l  #\image, (MARS_REG_BASE + MARS_COMM4)
        mars_comm_safe MARSCOMM_IMAGE
    .endm

    .endif
