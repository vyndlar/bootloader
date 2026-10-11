BITS 16 ; tell assembler we're in 16 bit mode

start:
  mov ax, 07C0h ; set up 4K stack space after this bootloader
  add ax, 288   ; (4096 + 512) / 16 bytes per paragraph
  mov ss, ax
  mov sp, 4096

  mov ax, 07C0h ; set data segment to where we're loaded
  mov ds, ax

  mov si, text_string ; put string position into SI
  call print_string   ; call string print func (routine), BUT COME BACK WHEN DONE

  jmp $ ; jump here (infinite loop)

  text_string db 'Welcome to my OS!', 0

print_string: ; output string in SI to screen
  mov ah, 0Eh ; int 10h 'print char' function
  ; mov bl, 9h ; color blue

.repeat:
  lodsb       ; get char from string
  cmp al, 0
  je .done    ; if char is zero, end of string
  mov bl, 01h
  int 10h     ; otherwize print it
  jmp .repeat

.done:
  ret

  times 510-($-$$) db 0 ; Pad remainder of boot sector with 0s
  dw 0xAA55             ; the standard PC boot signature
