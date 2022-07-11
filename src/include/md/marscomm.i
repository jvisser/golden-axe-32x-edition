|--------------------------------------------------------------------
| 32X sub program commands
|--------------------------------------------------------------------

    .ifnotdef   __MARS_COMM_I__
    .equ        __MARS_COMM_I__, 1

    .include "mars.i"


    |--------------------------------------------------------------------
    | Commands
    |--------------------------------------------------------------------
    .equ MARSCOMM_MASTER,           MARS_COMM0
    .equ MARSCOMM_SLAVE,            MARS_COMM2


    |--------------------------------------------------------------------
    | Commands
    |--------------------------------------------------------------------
    .equ MARSCOMM_CMD_DISABLE,      0x01
    .equ MARSCOMM_CMD_IMAGE,        0x02


    |--------------------------------------------------------------------
    | Ensures all used registers are preserved
    |--------------------------------------------------------------------
    .macro mars_comm_safe port, command
        move.w  %d0, -(%sp)
        move.w  %d1, -(%sp)
        move.w  #\command, %d0
        move.w  #\port, %d1
        jsr     mars_comm
        move.w  (%sp)+, %d1
        move.w  (%sp)+, %d0
    .endm


    |--------------------------------------------------------------------
    | Send command with one word parameter
    |--------------------------------------------------------------------
    .macro mars_comm_p1 port, cmd, param
        move.w  #\param, (MARS_REG_BASE + \port + 8)
        mars_comm_safe \port, \cmd
    .endm


    |--------------------------------------------------------------------
    | Send command with two word parameters
    |--------------------------------------------------------------------
    .macro mars_comm_p2 port, cmd, param1, param2
        move.w  #\param2, (MARS_REG_BASE + \port + 10)
        mars_comm_p1 \port, \cmd, \param1
    .endm


    |--------------------------------------------------------------------
    | Send command with one long parameter
    |--------------------------------------------------------------------
    .macro mars_comm_lp port, cmd, long_param
        move.l  #\long_param, (MARS_REG_BASE + \port + 8)
        mars_comm_safe \port \cmd
    .endm


    |--------------------------------------------------------------------
    | Send disable command to slave
    |--------------------------------------------------------------------
    .macro mars_comm_disable
        mars_comm_safe MARSCOMM_SLAVE, MARSCOMM_CMD_DISABLE
    .endm


    |--------------------------------------------------------------------
    | Send image command to master
    |--------------------------------------------------------------------
    .macro mars_comm_image image
        mars_comm_lp MARSCOMM_MASTER, MARSCOMM_CMD_IMAGE, \image
    .endm


    .endif
