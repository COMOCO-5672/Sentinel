; Sentinel OS - first boot sector
;
; BIOS loads the first 512-byte sector at physical address 0x7C00,
; then jumps here in 16-bit real mode.

[org 0x7C00]
[bits 16]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov si, message
    call print_string

halt:
    hlt
    jmp halt

print_string:
    lodsb
    test al, al
    jz .done

    cmp al, 0x0A
    jne .print_char
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A

.print_char:
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07
    int 0x10
    jmp print_string

.done:
    ret

message:
    db 'Sentinel OS', 0x0A
    db 'Hello from the boot sector.', 0x0A
    db 0

times 510 - ($ - $$) db 0
dw 0xAA55
