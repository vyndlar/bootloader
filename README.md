# Bootloader written in x86-64 Assembly

<<<<<<< HEAD
This project showcases a bootloader written in x86-64 assembly. It boots, loads a kernel written in C, and uses BIOS-level system calls to manage bare-metal CPU registers.
=======
This project showcases a bootloader written in x86-64 assembly. It uses BIOS-level system calls and manages memory and bare-metal CPU registers to load a basic kernel written in C.
>>>>>>> kb_input

## Order of operations
1. Boot into 16-bit real mode
2. Load the kernel at memory address 0x7e00
3. Load into 32-bit Protected mode
4. Switch to 64-bit Long mode and execute kernel_main() in `kernel.c`

## Finished Result

![Finished Result](booted.png)

## Compilation and use
First, run the makefile to generate the floppydisk
``` shell
$ make boot
```

Next, run the virtual machine (qemu must be installed)
``` shell
<<<<<<< HEAD
$ qemu-system-x86_64 -drive format=raw,file=boot.flp -d int,cpu_reset -D q.log
=======
$ qemu-system-x86_64 -drive format=raw,file=boot.flp
>>>>>>> kb_input
```

