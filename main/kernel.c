#include "vars.h"
#include "../input/kb_input.h"

extern uint32_t cursor_offset;

int strcmp(const char *s1, const char *s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    return *(unsigned char *)s1 - *(unsigned char *)s2;
}

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

//    printk("Yo, welcome to the kernel!\n");

    print_prompt();
    keyboard_loop();
}
