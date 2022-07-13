/*
 * The memory map look like this:
 * +--------------------+ <- 0x00000000 (ROM)
 * | patch_*            |   Patches must .org at the exact location of the original game code to get correct relocations
 * |                    |
 * |                    |
 * |                    |
 * +--------------------+ <- 0x00080000 (ROM_EXT)
 * | .text              |   New code is added at the end of the original ROM
 * |             |      |
 * |                    |
 * +--------------------+ <- 0x00400000 (PATCH_IDX)
 * | patch_index        |   Store patch index here
 * +--------------------+
 * .                    .
 * .                    .
 * +--------------------+ <- 0xffff8200 (RAM)
 * | .data              |   Use the top part of the 0xff8000 - 0xffbc20 (~15k) dynamic RAM area which was mainly used for decompressed tile data of the amazon entity.
 * |                    |   The lower part is still used by the game credits though (up until 0xff8200).
 * |                    |   This allows us to use the absolute short addressing mode of the 68k nicely
 * |                    | initialized data goes here
 * +--------------------+
 * | .bss               |
 * +--------------------+
 * .                    .
 * .                    .
 * .                    .
 * | __stack            | top of stack
 * +--------------------+ <- 0x01000000
 */


MEMORY
{
	ROM (rx)        : ORIGIN = 0x00000000, LENGTH = 0x00080000
	ROM_EXT (rx)    : ORIGIN = 0x00080000, LENGTH = 0x00380000
	PATCH_IDX (r)   : ORIGIN = 0x00400000, LENGTH = 0x00080000
	RAM (rwx)       : ORIGIN = 0xffff8200, LENGTH = 0x00003a20
}


PROVIDE (__stack = 0x01000000);


/* LMA's correspond to the offset in the patch file not the actual runtime memory locations */
SECTIONS
{
    offset = 0;

    INCLUDE patch.ld.generated

    _text_offset = offset;
    .text : AT(_text_offset)
    {
        _text = .;

        *(.text .text.*)
        *(.rodata .rodata.*)

        . = ALIGN(4);
        _sh2 = .;
        *(sh2 sh2.*)
        . = ALIGN(4);
        _sh2_size = ABSOLUTE(. - _sh2);

    } > ROM_EXT
    _text_size = SIZEOF(.text);

    offset += _text_size;

    _data_offset = offset;
    _data_source = ADDR(.text) + SIZEOF(.text);     /* This is the actual .data LMA */
    .data : AT(_data_offset)
    {
        _data = .;

        *(.data .data.*)
    } > RAM
    _data_size = SIZEOF(.data);

    .bss :
    {
        _bss = . ;
        *(.bss .bss.*)
    } > RAM
    _bss_size = SIZEOF(.bss);

    patch_index :
    {
        KEEP(*(patch_index))
    } > PATCH_IDX
}
