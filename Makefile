boot: boot.flp
	dd if=boot.bin of=boot.flp conv=notrunc

boot.flp: boot.bin
	dd if=/dev/zero of=boot.flp bs=512 count=2880

boot.bin: boot.o kernel.o kb_input.h
	ld -n -T linker.ld -o boot.bin boot.o kernel.o --oformat binary

boot.o: boot.asm
	nasm -f elf64 boot.asm -o boot.o

kernel.o: main/kernel.c main/vars.h input/kb_input.h
	gcc -ffreestanding -m64 -mno-red-zone -mcmodel=kernel -fno-pic -fno-pie -c main/kernel.c -o kernel.o

kb_input.o: input/kb_input.h input/kb_input.h
	gcc -ffreestanding -m64 -mno-red-zone -mcmodel=kernel -fno-pic -fno-pie -c input/kb_input.c -o kb_input.o
