/*
 * Command structure used to handle commands received from the MD.
 */

#ifndef __COMMAND_H__
#define __COMMAND_H__

#include "types.h"


typedef void (*md_command_handler)(u16* param_base);
typedef void (*md_command_post_handler)();

typedef struct
{
    md_command_handler      process;         // All procesing that requires ROM access must be done here!
    md_command_post_handler post_process;
} md_command;


extern void command_main(volatile u16* comm_base);


#endif
