/* The linker script forces the bootloader code to be placed at first memory location 0x7c00
 this is to make sure that 0xaa55 lands at offset 510 */


/* The entry point of the binary (start is the label at the beginning of the assembly boot.asm) */
ENTRY(start)

SECTIONS
{
    /* The dot is the location counter, tracks the memory addresses during linking (this starts at 0x7c00) */
    . = 0x7c00;

    /* Starts the .text section of the boot.o to be placed first at the offset 0x7c00 */
    /* *(.text) means all other input files (like kernel.o) */
    .text : {
        boot.o(.text)
        *(.text)
    }

    /* Read only data such as variables and string literals */
    .rodata : {
        *(.data)
    }

    /* The section for global and static variables that have non-zero initial values */
    .data : {
          *(.data)
    }

    /* Uninitialized static variables */
    /* *(COMMON) Collects all uninitialized global vars that the compiler said were C 'common blocks' */
    .bss : {
        *(.bss)
        *(COMMON)
    }
}
