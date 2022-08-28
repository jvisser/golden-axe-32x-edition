/*
 * All code runs from RAM
 * +--------------------+ <- 0x06000000
 * | .text              |   SDRAM base (cached)
 * +--------------------+
 * | .rodata            |
 * | .data              |
 * | .bss               |
 * +--------------------+
 * .                    .
 * .                    .
 * .                    .
 * |        __mstack    | top of stack (for Master SH2)
 * |        __sstack    | top of stack (for Slave SH2)
 * +--------------------+ <- 0x06040000
 */

MEMORY
{
    RAM (wx)                : ORIGIN = 0x06000000, LENGTH = 0x00040000
    RAM_CACHE_THROUGH (wx)  : ORIGIN = 0x26000000, LENGTH = 0x00040000
}


PROVIDE (__mstack = 0x0603ff00);
PROVIDE (__sstack = 0x06040000);


/* Default interrupt handlers if not defined anywhere else */
PROVIDE (_master_int_pwm = 0x06000008);
PROVIDE (_master_int_command = 0x06000008);
PROVIDE (_master_int_hblank = 0x06000008);
PROVIDE (_master_int_vblank = 0x06000008);

PROVIDE (_slave_int_pwm = 0x06000008);
PROVIDE (_slave_int_command = 0x06000008);
PROVIDE (_slave_int_hblank = 0x06000008);
PROVIDE (_slave_int_vblank = 0x06000008);


SECTIONS
{
    __section_offset = 0;

    .text : AT(__section_offset) SUBALIGN(4)
    {
        KEEP(*(boot))
        *(.text .text.*)
    } > RAM
    __section_offset += SIZEOF(.text);

    .data : AT(__section_offset) SUBALIGN(4)
    {
        *(.rodata .rodata.*)
        *(.data .data.*)
        *(.bss .bss.*)
    } > RAM
    __section_offset += SIZEOF(.data);

    uncached ORIGIN(RAM_CACHE_THROUGH) + __section_offset : AT(__section_offset) SUBALIGN(4)
    {
        *(uncached uncached.*)
    } > RAM_CACHE_THROUGH
    __section_offset += SIZEOF(uncached);

    __free_ram_start = ((ORIGIN(RAM) + __section_offset) + 3) & ~3;
}
