/*
 * Z80 sound driver replacement
 */

#include "patch.h"


    //patch_start 0x01d2f0
    //    .dc.w   0x18fe // jr -2
    //patch_end
