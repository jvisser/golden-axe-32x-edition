|--------------------------------------------------------------------
| 32X sub program communication
|--------------------------------------------------------------------

    .global mars_comm


    |-------------------------------------------------------------------
    | SH2 sub programs loaded by the 32X boot ROM. See 32X header in boot.s.
    |-------------------------------------------------------------------
    .section sh2

        | Placeholder until we have a program (or else the SH2 will loop for 4 billion iterations)
        .dc.w 0xaffe    | bra .
        .dc.w 0x0009    | nop
        .dc.w 0xaffe    | bra .
        .dc.w 0x0009    | nop


    .data       | Use the .data section to store this routine in RAM allowing RV switching
    .align  2

    |-------------------------------------------------------------------
    | Send command to the 32X sub program
    |
    | Params:
    | - d0.w: command (high bit indicated blocking call)
    |-------------------------------------------------------------------
    mars_comm:
            rts
