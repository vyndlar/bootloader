# Bootloader written in x86-64 Assembly

This project showcases a bootloader written in x86-64 assembly. It boots, displays text, and uses BIOS-level system calls to manage bare-metal CPU registers.

## Finished Result

![Finished Result](booted.png)
This is a screenshot of the program booted in a virtual machine. It is running `boot.flp`

## Compilation and use
First, compile the assembly into a binary
``` shell
$ nasm -f bin boot.asm -o boot.bin
```

Then, move that binary onto a floppydisk. Floppydisks are used due to their ease and compatibility

``` shell
$ dd if=boot.bin of=boot.flp bs=512 
```

To run this, you'll need a virtual machine. I'm using VirtualBox. Set the `boot.flp` as a storage device and move the floppy disk to be the first boot option.

