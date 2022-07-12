|--------------------------------------------------------------------
| 32X sub program commands
|--------------------------------------------------------------------

    .ifnotdef   __MARS_COMM_I__
    .equ        __MARS_COMM_I__, 1

    .include "mars.i"


    |--------------------------------------------------------------------
    | Commands
    |--------------------------------------------------------------------
    .equ MARSCOMM_MASTER,                   MARS_COMM0
    .equ MARSCOMM_SLAVE,                    MARS_COMM2


    |--------------------------------------------------------------------
    | Commands and subcommands
    |--------------------------------------------------------------------
    | Palette id used by image and palette commands
    .equ MARSCOMM_PALETTE_0,                0x00000000
    .equ MARSCOMM_PALETTE_1,                0x01000000


    .equ MARSCOMM_CMD_DISPLAY,              0x01
    | Sub commands
    .equ MARSCOMM_CMD_DISPLAY_ENABLE,       0x0000
    .equ MARSCOMM_CMD_DISPLAY_DISABLE,      0x0001
    .equ MARSCOMM_CMD_DISPLAY_SWAP,         0x0002


    .equ MARSCOMM_CMD_IMAGE,                0x02


    .equ MARSCOMM_CMD_PALETTE,              0x03
    | Sub commands
    .equ MARSCOMM_CMD_PALETTE_FILL,         0x00000000
    .equ MARSCOMM_CMD_PALETTE_LOAD,         0x10000000
    .equ MARSCOMM_CMD_PALETTE_COMMIT,       0x20000000
    .equ MARSCOMM_CMD_PALETTE_TRANSITION,   0x30000000


    |--------------------------------------------------------------------
    | Save used registers
    |--------------------------------------------------------------------
    .macro mars_comm_call_start
        move.w  %d5, -(%sp)
        move.w  %d6, -(%sp)
    .endm


    |--------------------------------------------------------------------
    | Restore registers
    |--------------------------------------------------------------------
    .macro mars_comm_call_end
        move.w  (%sp)+, %d6
        move.w  (%sp)+, %d5
    .endm


    |--------------------------------------------------------------------
    | Ensures all used registers are preserved
    |--------------------------------------------------------------------
    .macro mars_comm port, command
        move.w  #\command, %d5
        move.w  #\port, %d6
        jsr     __mars_comm
    .endm


    |--------------------------------------------------------------------
    | Send command with one word parameter
    |--------------------------------------------------------------------
    .macro mars_comm_p1 port, cmd, param
        move.w  \param, (MARS_REG_BASE + \port + 8)
        mars_comm \port, \cmd
    .endm


    |--------------------------------------------------------------------
    | Send command with two word parameters
    |--------------------------------------------------------------------
    .macro mars_comm_p2 port, cmd, param1, param2
        move.w  \param2, (MARS_REG_BASE + \port + 10)
        mars_comm_p1 \port, \cmd, \param1
    .endm


    |--------------------------------------------------------------------
    | Send command with one long parameter
    |--------------------------------------------------------------------
    .macro mars_comm_lp port, cmd, long_param
        move.l  \long_param, (MARS_REG_BASE + \port + 8)
        mars_comm \port \cmd
    .endm

    .endif
