#include <stdint.h>

void kernel_main() {
    volatile uint16_t *vga_buffer = (uint16_t *)0xb8000;

    const char *message = "Hello from the 64-bit C kernel!";

    for (int i = 0; message[i] != '\0'; i++) {
        vga_buffer[i] = (uint16_t)message[i] | (0x2f << 8);
    }
}
