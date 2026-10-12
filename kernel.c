#include <stdint.h>

#define VGA_BUFFER_ADDR 0xb8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define SPACE_CHAR 0x20
#define ATTR_BYTE 0x07

void kernel_main() {
    volatile uint16_t *vga_buffer = (uint16_t *)VGA_BUFFER_ADDR;

    // Clear the screen
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        vga_buffer[i] = (ATTR_BYTE << 8) | SPACE_CHAR;
    }

    const char *message = "Hello from the 64-bit C kernel!";

    for (int i = 0; message[i] != '\0'; i++) {
        vga_buffer[i] = (uint16_t)message[i] | (0x0f << 8);
    }
}
