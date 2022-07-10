|--------------------------------------------------------------------
| 32X sub program commands
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
