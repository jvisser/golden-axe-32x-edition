/*
 * RV workarounds... see https://github.com/viciious/32XDK/wiki/Bugs-and-quirks#about-rom-read-when-rv1
 */

#include "patch.h"


    patch_start 0x00106a
        jmp.l   _fix_1070
    patch_end

    patch_start 0x00206a
        jmp.l   _fix_2070
    patch_end

    // 0x003070 is in nemesis to RAM decompression routine that is unused...


    _fix_1070:
        move.w  #0x8f80, (0xc00004)
        bclr    #6, (0xffffc200).w
        jmp     0x001078


    _fix_2070:
        jsr     0x0020a8
        move.l  #0x4caa0003, %d7
        jmp     0x002074
