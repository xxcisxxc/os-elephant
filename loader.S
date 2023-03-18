%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR
jmp loader_start

GDT_BASE:
dd 0x00000000
dd 0x00000000

CODE_DESC:
dd 0x0000FFFF
dd DESC_CODE_HIGH4

DATA_STACK_DESC:
dd 0x0000FFFF
dd DESC_DATA_HIGH4

VIDEO_DESC:
dd 0x80000007
dd DESC_VIDEO_HIGH4

GDT_SIZE equ $-GDT_BASE
GDT_LIMIT equ GDT_SIZE-1
times 60 dq 0
SELECTOR_CODE equ (0x0001 << 3) + TI_GDT + RPL0
SELECTOR_DATA equ (0x0002 << 3) + TI_GDT + RPL0
SELECTOR_VIDEO equ (0x0003 << 3) + TI_GDT + RPL0

gdt_ptr dw GDT_LIMIT
        dd GDT_BASE

loader_start:

mov byte [gs:0x20],'2'
mov byte [gs:0x21],0xA4

mov byte [gs:0x22],' '
mov byte [gs:0x23],0xA4

mov byte [gs:0x24],'L'
mov byte [gs:0x25],0xA4   

mov byte [gs:0x26],'O'
mov byte [gs:0x27],0xA4

mov byte [gs:0x28],'A'
mov byte [gs:0x29],0xA4

mov byte [gs:0x2a],'D'
mov byte [gs:0x2b],0xA4

mov byte [gs:0x2c],'E'
mov byte [gs:0x2d],0xA4

mov byte [gs:0x2e],'R'
mov byte [gs:0x2f],0xA4

in al,0x92
or al,0000_0010B
out 0x92,al

lgdt [gdt_ptr]

mov eax,cr0
or eax,0x00000001
mov cr0,eax

jmp dword SELECTOR_CODE:p_mode_start

[bits 32]
p_mode_start:
   mov ax,SELECTOR_DATA
   mov ds,ax
   mov es,ax
   mov ss,ax
   mov esp,LOADER_STACK_TOP
   mov ax,SELECTOR_VIDEO
   mov gs,ax

   mov byte [gs:0x40],'H'
   mov byte [gs:0x41],0x79

   mov byte [gs:0x42],'e'
   mov byte [gs:0x43],0x79

   mov byte [gs:0x44],'l'
   mov byte [gs:0x45],0x79

   mov byte [gs:0x46],'l'
   mov byte [gs:0x47],0x79

   mov byte [gs:0x48],'o'
   mov byte [gs:0x49],0x79

   jmp $
