#boot: boot.bin
#	dd if=boot.bin of=boot.flp bs=512
#
#boot.bin: boot.asm
#	nasm -f bin boot.asm -o boot.bin

boot: boot.bin
	dd if=boot.bin of=boot.flp conv=notrunc

boot.flp: boot.flp:
	dd if=/dev/zero of=boot.flp bs=512 count=2880

boot.bin: boot.o kernel.o
	ld -n -T linker.ld -o boot.bin boot.o kernel.o --oformat binary

boot.o: boot.asm
	nasm -f elf64 boot.asm -o boot.o

kernel.o: kernel.c
	gcc -ffreestanding -m64 -mno-red-zone -mcmodel=kernel -fno-pic -fno-pie -c kernel.c -o kernel.o
