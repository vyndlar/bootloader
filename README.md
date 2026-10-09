# Bootloader written in x86-64 Assembly

This project showcases a bootloader written in x86-64 assembly. It boots, displays text, and uses BIOS-level system calls to manage bare-metal CPU registers.

## Project Files
- `bootloader.asm`: The assembly code
- `bootloader.bin`: The binary the .asm file compiles down to
- `bootloader.flp`: A floppydisk format of the binary for easy booting

## Finished Result

![Finished Result](booted.png)
This is a screenshot of the program booted in a virtual machine. It is running `bootloader.flp`

## Compilation and use
First, compile the assembly into a binary
``` shell
$ nasm -f bin bootloader.asm -o bootloader.bin
```

Then, move that binary onto a floppydisk. Floppydisks are used due to their ease and compatibility

``` shell
$ dd if=bootloader.bin of=bootloader.flp bs=512 
```

To run this, you'll need a virtual machine. I'm using VirtualBox. Set the `bootloader.flp` as a storage device and move the floppy disk to be the first boot option.

