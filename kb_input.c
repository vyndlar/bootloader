#include <stdint.h>

#include "vars.h"

/* Get the 8-bit data byte read from a specified hardware port */
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
    __asm__ volatile ("inb %1 %0" : "=a"(result) : "d"(port));
    return result;
}

static const char scancode_chart[] = {
0,   27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
  '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
    0,  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',
    0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/',   0,
  '*',    0, ' '
};
