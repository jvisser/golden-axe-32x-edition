|--------------------------------------------------------------------
| 32X sub program commands
|
| GAS macros are way too limited :(
|--------------------------------------------------------------------

    .ifnotdef   __MARS_COMM_I__
    .equ        __MARS_COMM_I__, 1

    .include "md.i"


    |--------------------------------------------------------------------
    | Command processor
    |--------------------------------------------------------------------
    .equ MARS_COMM_MASTER,                  MARS_COMM0
    .equ MARS_COMM_SLAVE,                   MARS_COMM2


    |--------------------------------------------------------------------
    | Command parameters (relative to command processor port)
    |--------------------------------------------------------------------
    .equ MARS_COMM_P1,                      8
    .equ MARS_COMM_P1_H,                    8
    .equ MARS_COMM_P1_L,                    9
    .equ MARS_COMM_P2,                      10
    .equ MARS_COMM_P2_H,                    10
    .equ MARS_COMM_P2_L,                    11


    |--------------------------------------------------------------------
    | Commands
    |--------------------------------------------------------------------

    .equ MARS_COMM_CMD_DISPLAY_ENABLE,      0x0100
    .equ MARS_COMM_CMD_DISPLAY_DISABLE,     0x0101
    .equ MARS_COMM_CMD_DISPLAY_SWAP,        0x0102

    .equ MARS_COMM_CMD_IMAGE_PAL0,          0x0200
    .equ MARS_COMM_CMD_IMAGE_PAL1,          0x0201

    .equ MARS_COMM_CMD_PALETTE_FILL_PAL0,   0x0300
    .equ MARS_COMM_CMD_PALETTE_FILL_PAL1,   0x0301
    .equ MARS_COMM_CMD_PALETTE_LOAD_PAL0,   0x0302
    .equ MARS_COMM_CMD_PALETTE_LOAD_PAL1,   0x0303
    .equ MARS_COMM_CMD_PALETTE_COMMIT,      0x0304
    .equ MARS_COMM_CMD_PALETTE_TRANSITION,  0x0306
    .equ MARS_COMM_CMD_PALETTE_SUBTRACT,    0x0308
    .equ MARS_COMM_CMD_PALETTE_COPY_PAL0,   0x030a
    .equ MARS_COMM_CMD_PALETTE_COPY_PAL1,   0x030b

    .equ MARS_COMM_CMD_VERTICAL_SCROLL,     0x0400


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
    | Run command using immediate value
    |--------------------------------------------------------------------
    .macro mars_comm port, command
        move.w  #\command, %d5
        move.w  #\port, %d6
        jsr     __mars_comm.w
    .endm


    |--------------------------------------------------------------------
    | Run command using variable command value
    |--------------------------------------------------------------------
    .macro mars_comm_dyn_cmd port, command
        move.w  \command, %d5
        move.w  #\port, %d6
        jsr     __mars_comm.w
    .endm


    |--------------------------------------------------------------------
    | Send command with one word parameter
    |--------------------------------------------------------------------
    .macro mars_comm_p1 port, cmd, param
        move.w  \param, (MARS_REG_BASE + \port + MARS_COMM_P1)
        mars_comm \port, \cmd
    .endm


    |--------------------------------------------------------------------
    | Send command with two word parameters
    |--------------------------------------------------------------------
    .macro mars_comm_p2 port, cmd, param1, param2
        move.w  \param2, (MARS_REG_BASE + \port + MARS_COMM_P2)
        mars_comm_p1 \port, \cmd, \param1
    .endm


    |--------------------------------------------------------------------
    | Send command with one long parameter
    |--------------------------------------------------------------------
    .macro mars_comm_lp port, cmd, long_param
        move.l  \long_param, (MARS_REG_BASE + \port + MARS_COMM_P1)
        mars_comm \port \cmd
    .endm

    .endif
