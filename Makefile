boot: boot.bin
	dd if=boot.bin of=boot.flp bs=512

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin
