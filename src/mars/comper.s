/*
 * Comper decompression
 */


    .global _comper_decompress


    /**********************************************************
     * Comper decompression
     *
     * Parameters:
     * - r4: Comper data address
     * - r5: Output address
     */
    _comper_decompress:
        mov     #-1, r7
        shll8   r7

        sett
    .loop:
        bf      .descriptor_ok

        mov.w   @r4+, r3        /* Read next descriptor */
        swap.w  r3, r3
        mov     #16, r2

    .descriptor_ok:
        shll    r3              /* T = token type */
        bf/s    .uncompressed
        mov.w   @r4+, r6

    .compressed:
        not     r7, r7
        mov     r6, r1
        and     r7, r1
        tst     r1, r1
        bt      .exit           /* length zero is end of stream */

        add     #1, r1          /* r1 = number of words to copy */

        shlr8   r6              /* r6 = distance */
        not     r7, r7
        or      r7, r6
        shal    r6
        add     r5, r6          /* r6 = source data addr */

    1:  mov.w   @r6+, r0
        mov.w   r0, @r5
        dt      r1
        bf/s    1b
        add     #2, r5
        bra     .loop
        dt      r2

    .uncompressed:
        mov.w   r6, @r5
        add     #2, r5
        bra     .loop
        dt      r2

    .exit:
        rts
        nop
