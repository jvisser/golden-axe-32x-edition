/*
 * Palette support functions
 */

#ifndef __PALETTE_H__
#define __PALETTE_H__

#include "types.h"


#define PAL_CURRENT 0x00
#define PAL_TARGET  0x01


// Fill the specified palette with a single color
extern void pal_fill(u32 palette_id, u32 offset, u32 count, u16 color);

// Fill the specified palette with the specified colors
extern void pal_replace(u32 palette_id, u32 offset, u32 count, u16 *colors);

// Copy the specified palette to the opposing palette
extern void pal_copy(palette_id);

// Transition the current palette by step_size towards the target palette by step_size (=color value to add subtract)
// Returns non zero if changes have been made
extern u32 pal_transition_step(u32 offset, u32 count, u32 step_size);

// Commit the current palette to CRAM
extern void pal_commit(void);

// Subtract the specified color from the target palette and place the result in the current palette
extern void pal_subtract(u32 offset, u32 count, u16 color);


#endif
