/*
 * Command processing main loop
 */

#include "command.h"

extern command CMD_DISPLAY;
extern command CMD_IMAGE;
extern command CMD_PALETTE;


static command* commands[] =
{
    &CMD_DISPLAY,
    &CMD_IMAGE,
    &CMD_PALETTE,
};


void command_main(volatile u16* comm_base)
{
    volatile u16* comm0 = comm_base;
    volatile u16* comm1 = comm_base + 1;
    volatile u16* param = comm_base + 4;

    while (1)
    {
        // Wait for command from the MD
        u16 command_id;
        while (!(command_id = *comm0));

        // Only need param to be volatile within this loop the value is constant when processing the command.
        command* command = commands[(command_id >> 8) - 1];

        command->process((u16*) param, command_id);

        // Send ready signal to MD
        *comm1 = command_id;

        // Wait for ACK from MD
        while (*comm0);

        // Run post command tasks
        command->post_process(command_id);
    }
}