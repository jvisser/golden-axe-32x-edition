/*
 * Command structure used to handle commands received from the MD.
 */

#ifndef __COMMAND_H__
#define __COMMAND_H__


typedef void (*md_command_handler)();

typedef struct
{
    md_command_handler process;         // All procesing that requires ROM access must be done here!
    md_command_handler post_process;
} md_command;


#endif
