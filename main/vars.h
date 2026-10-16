#ifndef VARS_H_
#define VARS_H_

#include <stdint.h>

#define VGA_BUFFER_ADDR 0xb8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define SPACE_CHAR 0x20
#define ATTR_BYTE 0x07

#define vga_buffer ((volatile uint16_t *)VGA_BUFFER_ADDR)

void printk(const char *str);
uint16_t strlenk(char *s);
int strcmp(const char*s1, const char *s2);

extern char cmd_buf[256]; // The command itself
extern uint32_t cmd_inx; // The # of chars the user has typed

#endif
