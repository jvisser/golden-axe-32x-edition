|--------------------------------------------------------------------
| 32X 68k startup code
|--------------------------------------------------------------------

    .include "md.i"
    .include "mars.i"
    .include "patch.i"


    |-------------------------------------------------------------------
    | Disable the nemesis decompression to RAM subroutine.
    | We use the freed up RAM (about 15k!) for our .data/.bss sections
    |-------------------------------------------------------------------
    patch_start 0x002fda
        rts
    patch_end


    |-------------------------------------------------------------------
    | Disable the original game's clear RAM code.
    | We don't want our .data/.bss sections to be erased later on
    |-------------------------------------------------------------------
    patch_start 0x000c1c
        bra     0x000c26
    patch_end

    patch_start 0x000b28
        bra     0x000b2e
    patch_end


    |-------------------------------------------------------------------
    | 68k cold reset vector
    |-------------------------------------------------------------------
    patch_start 0x000000
        .dc.l   __stack
        .dc.l   0x0003f0
    patch_end


    |-------------------------------------------------------------------
    | 68k hot reset vector
    |-------------------------------------------------------------------
    patch_start 0x000200
        jmp     (MARS_ROM_BANK0 + user_entry_point).l
    patch_end


    |-------------------------------------------------------------------
    | 32X Header
    |-------------------------------------------------------------------
    patch_start 0x0003c0
        .ascii  "Golden Axe 32X  "              | Module name (16 chars)
        .dc.l   0x00010000                      | Version
        .dc.l   _sh2                            | ROM source offset
        .dc.l   0                               | SDRAM destination offset
        .dc.l   _sh2_size                       | Size
        .dc.l   0x06000000                      | Master SH2 initial address
        .dc.l   0x06000004                      | Slave SH2 initial address
        .dc.l   0x05ffff00                      | Master SH2 VBR
        .dc.l   0x05ffff14                      | Slave SH2 VBR
    patch_end


    |-------------------------------------------------------------------
    | Initial program by Sega
    |
    | See the 32X Hardware Manual:
    | - Page 83: Security
    | - Page 95: For the source code of the initial program.
    |-------------------------------------------------------------------
    patch_start 0x0003f0
        .incbin "ip.bin"
    patch_end


    |-------------------------------------------------------------------
    | User code start
    | RV=0, PC=0x880800, SR=0x27xx
    |-------------------------------------------------------------------
    patch_start 0x000800
        user_entry_point:
            | Carry set means an error occured in the initial program
            bcc     mars_ok
            bra     .

        mars_ok:
            lea     (MARS_REG_BASE), %a6

            bsr     mars_ready_wait

            | Copy bootstrap program to RAM and run
            lea     (MARS_ROM_BANK0 + init_boot_strap_end), %a0
            move.w  #((init_boot_strap_end - init_boot_strap) / 2) - 1, %d0
        1:  move.w  -(%a0), -(%sp)
            dbf     %d0, 1b
            jmp     (%sp)


        |-------------------------------------------------------------------
        | Wait for the 32X self test to complete without errors
        |
        | See the 32X Hardware Manual:
        | - page 69: Communication Port.
        | - page 80: Boot ROM
        | - page 89: Master boot ROM source code
        |-------------------------------------------------------------------
        mars_ready_wait:
        1:  cmp.l   #M_OK, MARS_COMM0(%a6)      | Wait for Master SH2 ready signal from master boot ROM
            bne     1b
        1:  cmp.l   #S_OK, MARS_COMM2(%a6)      | Wait for Slave SH2 ready signal from slave boot ROM
            bne     1b
            rts


        |-------------------------------------------------------------------
        | Restore MD mode and jump to the initialization code in ROM
        |-------------------------------------------------------------------
        init_boot_strap:
            | Switch RV to 1 to restore the Mega Drive 68k memory map.
            | The vector table is still mapped to the 32X vector ROM making the vectors point to undefined memory locations.
            | As such the program can not depend on any interrupts or exceptions.
            bset    #0, MARS_DMAC + 1(%a6)

            | Jump to init code in ROM
            jmp     init.w                      | Need to force abs short or else it gets optimized to a relative branch
        init_boot_strap_end:


        |-------------------------------------------------------------------
        | Program specific initialization code
        |-------------------------------------------------------------------
        init:
            | 32X sub program handshake
            jsr     __mars_comm_init

            | Clear RAM
            lea     (RAM_START), %a0
            move.w  #(RAM_SIZE / 4) - 1, %d0
            moveq   #0, %d1
        1:  move.l  %d1, (%a0)+
            dbf     %d0, 1b

            | Copy initialized data to RAM
            lea     (_data_source), %a0
            lea     (_data), %a1
            move.w  #_data_size_w - 1, %d0
        1:  move.w  (%a0)+, (%a1)+
            dbf     %d0, 1b

            | Jump to the original reset vector
            lea     (0xfffd00), %sp
            jmp     0x000abe

    patch_end
