/*
 * Player character patches
 */

#include "goldenaxe.h"
#include "patch.h"


    /**********************************************************
     * Patch initial auto walk animation to only occur if the current/starting player position is offscreen to the left
     */
    patch_start 0x0014bc
        jsr     players_init
    patch_end

    players_init:
        lea     (entity_player_1), %a0
        bsr     init_player_auto_walk
        lea     (entity_player_2), %a0
        bsr     init_player_auto_walk
        rts

    init_player_auto_walk:
        /* Check if the current player state is auto walk */
        cmp.b   #0x68, ENTITY_STATE(%a0)
        bne     .exit

        /* Auto walk if outside of the left horizontal screen boundary */
        cmp.w   #0x80, ENTITY_X(%a0)
        bcs     .exit

        /* Skip auto walk */
        clr.b   ENTITY_STATE(%a0)

    .exit:
        rts
