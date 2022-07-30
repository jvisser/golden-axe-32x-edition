/*
 * Patches to disable checksum verification
 */

#include "patch.h"


    /*
     * Clear stored checksum to skip the slow verification code in the 32X initial program
     */
    patch_start 0x00018e
        .dc.l   0
    patch_end


    /*
     * Skip the original Golden Axe checksum verification code
     */
    patch_start 0x000bca
        jmp     0x000c16
    patch_end
