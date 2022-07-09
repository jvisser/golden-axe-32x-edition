#ifndef __COMMAND_H__
#define __COMMAND_H__


typedef void (*md_command_handler)();

typedef struct
{
    md_command_handler process;
    md_command_handler post_process;
} md_command;


#endif
