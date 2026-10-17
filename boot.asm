;; Project Goal: Run any assembly programs on a custom OS

DEFAULT ABS
[BITS 16]

    ;; Since we're using a linker, we compile this into a .elf file
    ;; ELF means executable *linkable* format, meaning that it can be loaded at any memory address
    ;; It also means that 'org' gets disabled
    ;; When compiling this into a flat binary (.bin file), we would need to keep this line becuase there would be no linker to set it automatically
;org 0x7c00                      ; Start this code at memory address 0x7c00

    global start

start:
    cli                         ; Disable interrupts while editing stack registers
    ;; The Stack Segment register (ss) defines the 64 KB segment assigned to hold stack memory
    ;; 0x0000 is used as the physical base address of the stack (since we're in real mode, the physical address is really 0x00000)

    mov ax, 0x0000              ; You can't load values directly into segment registers, so move it into ax first (0x0000 clears it)
    mov ss, ax                  ; Then move it into ss
    mov ds, ax                  ; And ds (data segment)
    mov es, ax                  ; As well as es (extra segment)
    mov sp, 0x7c00              ; sp = stack pointer (offset), stack grows downwards
    ;; (segment * 0x10) + offset = physical memory address

    mov [boot_drive], dl

    mov ah, 0x0e
;    mov al, '1'
;    int 0x10
;
;    mov ah, 0x0e
;    mov al, '6'
;    int 0x10

    ;; READ KERNEL SECTORS FROM DISK INTO RAM
    mov ah, 0x02                ; BIOS Read sector
    mov al, 15
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [boot_drive]        ; Restore saved drive number
    mov bx, 0x7e00              ; Load kernel into memory address 0x7e00 TODO: MAY NEED TO REMOVE ES: AND KEEP ONLY BX
    int 0x13
    jc disk_error

    ;; Now we transition into 32-bit protected mode
    ;; We need to load the GDT, enable protection, do a far jump, and reload data segment register
    ;; ----------------------------------------------------------------------------------------------------------------------------------------
    ;;                                                        ALL ABOUT 32-BIT MODE
    ;;
    ;; In 32-bit mode, we no longer use (segment * 0x10) + offset to calculate physical memory
    ;; Instead, each segment register holds a selector
    ;; The selector is an index offset into the GDT
    ;; Each entry (aka descriptor) in the GDT is an 8-byte structure containing:
    ;;      1. Base address: Where the memory starts in RAM (32-bit address)
    ;;      2. Segment limit: The maximum size of the segment (up to 4 GB)
    ;;      3. Access Byte and Flags: Privilage level (rings), read/write permissions, and code execution mode (16-bit, 32-bit, or 64-bit)
    ;;
    ;; ----------------------------------------------------------------------------------------------------------------------------------------

    lgdt [gdt_descriptor]       ; Load the GDT Table descriptor

    mov eax, cr0                ; Set bit 0 (PE aka protection enable) in cr0 (control register 0)
    or eax, 0x1
    mov cr0, eax

    jmp CODE_SEG:init_32bit     ; This ensures that the registers get set up correctly for 32-bit protected mode

disk_error:                     ; print 'diskerr' if error
    mov ah, 0x06
    mov al, 0
    mov bh, 0x07
    mov cx, 0x0000
    mov dx, 0x184f
    int 0x10
    mov ah, 0x0e
    mov al, 'd'
    int 0x10
    mov ah, 0x0e
    mov al, 'i'
    int 0x10
    mov ah, 0x0e
    mov al, 's'
    int 0x10
    mov ah, 0x0e
    mov al, 'k'
    int 0x10
    mov ah, 0x0e
    mov al, 'e'
    int 0x10
    mov ah, 0x0e
    mov al, 'r'
    int 0x10
    mov ah, 0x0e
    mov al, 'r'
    int 0x10
    jmp hang

hang:
    hlt
    jmp hang

[BITS 32]
init_32bit:
    ;; Update data segment registers with 32 bit data selector
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax                  ; es = extra segment (a second ds register basically)
                                ; Handles string operations like movsb
                                ; es is loaded with the same data segment selector as ds (DATA_SEG)
    mov fs, ax                  ; Same as es
    mov gs, ax                  ; Same as es
    mov ss, ax

    ;; Update stack pointer for 32-bit space
    mov esp, 0x90000

    mov edi, pml4_table
    mov ecx, 3072               ; 12,288 bytes / 4 = 3072 dwords
    xor eax, eax
    rep stosd

    mov eax, pdpt_table
    or eax, 011b
    mov [pml4_table], eax
    mov dword [pml4_table + 4], 0

    mov eax, pd_table
    or eax, 011b
    mov [pdpt_table], eax
    mov dword [pdpt_table + 4], 0

    mov eax, 0x00000000
    or eax, 10000011b
    mov [pd_table], eax
    mov dword [pd_table + 4], 0

    ;; --- Debug Message: 'OK' to VGA memory ---
    ;; 0xf = white, 0x2 = green
    ;; Each letter is 2 bytes, starting at memory address 0xb8000
;    mov word [0xb8000], 0x2f4f  ; 0x4f = 'O' at row 0, col 0
;    mov word [0xb8002], 0x2f4b  ; 0x4b = 'K' at row 0, col 1

    ;; Now set up 64-bit Long Mode

    ;; -------------------------------------------------------------------------------------------------
    ;;                                  ALL ABOUT 64-BIT MODE
    ;; Paging: Allows memory to be quickly and efficiently accessed
    ;;             - Prevents all 2^64 bits to be loaded into memory which would crash
    ;;             - Introduces virtual memory
    ;; Registers (in this order):
    ;;  CR3 (control register 3): Holds physical base address of PML4 table
    ;;  CR4: Bit 5 (PAE aka physical address extension) set to 1 to enable 64-bit paging structures
    ;;  IA32_EFER (Extended Feature Enable Register): Bit 8 (LME aka long mode enable) set to 1
    ;;  CR0: Bit 31 (PG aka paging) set to 1
    ;; --------------------------------------------------------------------------------------------------

    ;; PML4, PDPT, and PD tables are at the end of this file in bss section
    ;; Link PML4 entry 0 to PDPT
    mov eax, pdpt_table
    or eax, 011b                ; 011b attribute flag = Present + Read/wrote
    mov [pml4_table], eax

    ;; Link PDPT entry 0 to PD
    mov eax, pd_table
    or eax, 011b
    mov [pdpt_table], eax

    ;; Set bit 7 (PS aka Huge Page bit) to map physical address 0x00000000 to 0x001FFFFF
    mov eax, 0x00000000         ; Physical start address
    or eax, 10000011b           ; Present + Writable + Huge Page (bit 7, huge page is 2MB)
    mov [pd_table], eax

    ;; Now move the base address of PML4 table into CR3
    mov eax, pml4_table
    mov cr3, eax

    ;; Enable 64-bit paging structures in CR4
    mov eax, cr4
    or eax, 1 << 5              ; Sets bit 5 to 1
    mov cr4, eax

    ;; Enable long mode in IA32_EFER MSR
    mov ecx, 0xC0000080         ; IA32_EFER MSR number
    rdmsr                       ; Load MSR into EDX:EAX
    or eax, 1 << 8              ; Set LME (Long mode enable) bit (bit 8) to 1
    wrmsr

    ;; Enable paging in CR0
    mov eax, cr0
    or eax, 1 << 31             ; Set PG bit
    mov cr0, eax

;    jmp $                       ; Infinite loop once we're in 32-bit mode
;    jmp hang
    jmp CODE_SEG_64:init_64bit

[BITS 64]
    extern kernel_main
init_64bit:
    ;; Reload data segment registers for 64-bit long mode
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov rsp, 0x90000            ; Set up 64-bit stack

    ;; LADIES AND GENTLEMEN....
    ;;
    ;;
    ;; 64-BIT LONG MODE!!!
    ;;
    ;; Now we must prepare to load the kernel :)


    mov rdi, 0x2badb002         ; Magic constand and first function argument
    mov rsi, boot_info_struct   ; Second function argument
    and rsp, -16                ; Make sure rsp is 16-byte aligned

    call kernelmain

    call kernel_main

hang_64:
    hlt
    jmp hang_64

; ------------------------------------------
; Global Descriptor Table (GDT)
; ------------------------------------------

gdt_start:                      ; The starting RAM address of the table

gdt_null:                       ; The CPU needs the first GDT index to be a null descriptor of 8 bytes
    dd 0x0                      ; dd = define doubleword (it is worth 4 bytes)
    dd 0x0                      ; dd again makes dd + dd = 8 bytes total

;;; Segments (32-bit mode)
gdt_code_32:                       ; Defines code segment from physical memory 0x00000000 to 0xFFFFFFFF (total 4 GB)
    dw 0xffff                   ; Set the lower 16-bits of the segment to 0xFFFF
    dw 0x0                      ; Base address (bits 0-15)
    db 0x0                      ; Base address (bits 16-23)

    db 10011010b                ; Acces byte: 10011010b
                                ; 1: segment is valid in RAM
                                ; 00: Ring 0 (kernel)
                                ; 1: Descriptor type - Code or segment (not system descriptor)
                                ; 1: Executable bit 1=code segment containing executable instructions
                                ; 0: Conforming bit - code can only be executed from ring 0
                                ; 1: Readable bit - allows reading
                                ; 0: Access bit - Set to 1 automatically when segment is accessed

    db 11001111b                 ; Flags + upper limit
                                ; Upper 4 bits (1100) are flags
                                ;   1: Granularity - '1' multiplies the segment limit by 4 KB pages
                                ;   1: Size - '1' = 32-bit Protected mode ('0' = 16-bit protected mode)
                                ;   0: 64-bit code segment - set to '0' for 32-bit mode ('1' = 64-bit long mode)
                                ;   0: AVL Available for software use/ignored by hardware
                                ; Lower 4 bits (1111) are bits 16-19 of the limit

    db 0x0                      ; Base address (bits 24-31), so the combined base address is 0x00000000

gdt_data:                       ; Identical to gdt_code except for the access byte
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b                ; Access Byte: Data, writable (NOT executable)
    db 11001111b
    db 0x0

gdt_code_64:
    dw 0x0000                   ; Limit is ignored in 64-bit mode
    dw 0x0000                   ; Base is also ignored
    db 0x00                     ; ()
    db 10011010b                ; Access byte (same)
    db 10100000b                ; Flags: Long mode=1 (L-bit), size=0
    db 0x00

gdt_end:                        ; Opposite of gdt_start :)

gdt_descriptor:                 ; The CPU needs a 6-byte pointer structure to pass into the ldgt instruction (line 33)
    dw gdt_end - gdt_start - 1  ; GDT Size
    dd gdt_start                ; GDT Physical memory address

    ;; Segment offsets
    CODE_SEG equ gdt_code_32 - gdt_start
    DATA_SEG equ gdt_data - gdt_start
    CODE_SEG_64 equ gdt_code_64 - gdt_start
    ;; The code segment is 8 bytes (0x08) from gdt_start
    ;; The data segment is 16 bytes (0x10) from gdt_start

;   sti                         ; Re-enable hardware interrupts

boot_drive:  db 1
    times 510 - ($ - $$) db 0   ; Ensure the file is exactly 512 bytes (calculate offset and fill empty space)
    dw 0xaa55                   ; Magic boot signature

section .bss
align 4096
pml4_table: resb 4096
pdpt_table: resb 4096
pd_table:   resb 4096
