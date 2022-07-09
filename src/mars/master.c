#include "mars.h"
#include "command.h"

// Master commands
extern md_command CMD_DISABLE;
extern md_command CMD_IMAGE;

static md_command* commands[] =
{
    &CMD_DISABLE,
    &CMD_IMAGE,
};


static void init()
{
    // Wait for the SH2 to gain access to the VDP
    while ((MARS_SYS_INTMSK & MARS_SYS_INTMSK_FM) == 0);

    // Signal ready to the m68k side
    MARS_COMM0L = 0;
}


void master(void)
{
    init();

    while (1)
    {
        // Wait for command from the MD
        u16 commandId;
        while (!(commandId = MARS_COMM0));

        // Handle command
        md_command* command = commands[commandId - 1];
        command->process();

        // Send ready signal to MD
        MARS_COMM1 = commandId;

        // Wait for ACK from MD
        while (MARS_COMM0);

        // Run post command tasks
        command->post_process();
    }
}
