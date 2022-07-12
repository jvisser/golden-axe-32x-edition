/*
 * Palette support functions
 */

#ifndef __PALETTE_H__
#define __PALETTE_H__

#include "types.h"


#define PAL_BASE    0x00
#define PAL_TARGET  0x01


// Fill (partial) palette with a single color
extern void pal_fill(u32 palette_id, u32 offset, u32 count, u16 color);

// Fill (partial) palette with the specified colors
extern void pal_replace(u32 palette_id, u16 *colors, u32 offset, u32 count);

// Transition palette by step_size towards the target palette
// Returns non zero if changes have been made
extern u32 pal_transition_step(u32 step_size);

// Commit the current palette to CRAM
extern void pal_commit(void);


#endif
