/*
 * Death Adder entity patches to make him a reusable entity
 */

#include "goldenaxe.h"
#include "patch.h"


    /**********************************************************
     * Remove open door animation sequence
     */
    patch_start 0x01198c
        jmp     0x0119a8
    patch_end


    /**********************************************************
     * Remove close door animation sequence
     */
    patch_start 0x011fc2
        .rept 5
            nop
        .endr
    patch_end


    /**********************************************************
     * Update death adder palette immediately
     */
    patch_start 0x011fb6
        nop
        nop
        nop
    patch_end


    /**********************************************************
     * Remove palette transition including its 8 frame hang time
     */
    patch_start 0x0119ae
        jsr     palette_update_dynamic_commit.l
    patch_end


    /**********************************************************
     * Skip wait time for door open
     */
    patch_start 0x011f82
        jmp     0x011faa
    patch_end
