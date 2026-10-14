#include "vars.h"
#include "../input/kb_input.h"

extern uint32_t cursor_offset;

uint16_t strlenk(char *s) {
    int c = 0;
    while (*s++)
        c++;
    return c;
}

void printk(const char *str) {
    for (int i = 0; str[i] != '\0'; i++) {
        if (str[i] == '\n') {
            cursor_offset = (cursor_offset / VGA_WIDTH + 1) * VGA_WIDTH;
        } else {
            vga_buffer[cursor_offset] = (uint16_t)str[i] | (ATTR_BYTE << 8);
            cursor_offset++;
        }
    }
}

void kernel_main() {

    // Clear the screen
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        vga_buffer[i] = (ATTR_BYTE << 8) | SPACE_CHAR;
    }

    //const int *message = (uint16_t*)"Hello from the 64-bit C kernel!";

//    for (int i = 0; message[i] != '\0'; i++) {
//        vga_buffer[i] = (uint16_t)message[i] | (0x0f << 8);
//    }
    //printk(message);
    printk("Yo, welcome to the kernel!\n");


   keyboard_loop();
}
