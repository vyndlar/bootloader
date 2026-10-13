//#include <stdint.h>

#include "../main/vars.h"

// Get the 8-bit data byte read from a specified hardware port
static inline uint8_t inb(uint16_t port) {
    uint8_t result;

    /* set '=a' so that the value stored in AL goes directly to the result variable
     * Equivalent to this nasm:
     * mov dx, [port]
     * in al, dx
     * mov [result], al
     *
     * Note: GCC uses AT&T assembly syntax: `instruction source, destination` syntax
     * */
    __asm__ volatile ("inb %1, %0" : "=a"(result) : "d"(port));
    //printk((uint16_t*)result);
    return result;
}

// when typing, the system reads each letter as a PS/2 Sancode
// This table maps each to its respective ASCII Counterpart
static const char scancode_chart[] = {
0,   27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
  '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
    0,  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',
    0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/',   0,
  '*',    0, ' '
};


// volatile uint16_t *vga_buffer = (uint16_t *)VGA_BUFFER_ADDR;
uint32_t cursor_offset = 0;


// writes a single char to the frame
void print_char(char c) {
    if (c == '\n') {
        cursor_offset = (cursor_offset / VGA_WIDTH + 1) * VGA_WIDTH;

    } else if (c == '\b' && cursor_offset > 0) {
        cursor_offset--;
        vga_buffer[cursor_offset] = (uint16_t)' ' | (ATTR_BYTE << 8); // adds a ' ' in place of the previous character
        cursor_offset--;
    } else if (c != 0) {
        vga_buffer[cursor_offset] = (uint16_t)c | (ATTR_BYTE << 8);
    }
}

void keyboard_loop(void) {
    while (1) {
        // Read status port 0x64
        // Bit 0 indicates if the output buffer contains data
        if(inb(0x64) & 0x01) {
            // The 8-byte scancode is stored in port 0x60:
            uint8_t scancode = inb(0x60);

            /* Only print character when the character is pressed, not released:
             *      Make codes vs break codes:
             *          - Make codes are sent when a key is pressed down (bit 7 = 0)
             *              - Scancode range: 0x00 thru 0x7f
             *          - Break codes are sent when a key is released (bit 7 = 1)
             *              - Scancode range: 0x80 thru 0x9e
             *   */

            // If bit 7 of scancode is 1, expression = 0x80
            // Else, = 0x00
            if (!(scancode & 0x80)) { // 0x80 = 0b1000_0000 targets only highest bit (bit 7) of 8-bit byte
                if (scancode < sizeof(scancode_chart)) {
                    char ascii = scancode_chart[scancode]; // Get the ASCII char
                    if (ascii != 0) {
                        print_char(ascii);
                        cursor_offset++;
                    }
                }
            }

        }
    }
}
