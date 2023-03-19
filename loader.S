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
;times 60 dq 0
SELECTOR_CODE equ (0x0001 << 3) + TI_GDT + RPL0
SELECTOR_DATA equ (0x0002 << 3) + TI_GDT + RPL0
SELECTOR_VIDEO equ (0x0003 << 3) + TI_GDT + RPL0

gdt_ptr dw GDT_LIMIT
        dd GDT_BASE

loader_start:

mov sp,LOADER_BASE_ADDR

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

   mov byte [gs:0x40],'P'
   mov byte [gs:0x41],0x79

call setup_page

sgdt [gdt_ptr]
mov ebx,[gdt_ptr+2]
or dword [ebx+0x18+4],0xc0000000
add dword [gdt_ptr+2],0xc0000000
add esp,0xc0000000

mov eax,PAGE_DIR_TABLE_POS
mov cr3,eax

mov eax,cr0
or eax,0x80000000
mov cr0,eax

lgdt [gdt_ptr]

mov byte[gs:0xA0],'V'

cli

jmp $

setup_page:
  mov ecx,4096
  mov esi,0
.clear_page_dir:
  mov byte [PAGE_DIR_TABLE_POS+esi],0
  inc esi
  loop .clear_page_dir
.create_pde:
  mov eax,PAGE_DIR_TABLE_POS
  add eax,0x1000
  mov ebx,eax
  or eax,PG_US_U|PG_RW_W|PG_P
  mov [PAGE_DIR_TABLE_POS + 0x0],eax
  mov [PAGE_DIR_TABLE_POS + 0xc00],eax
  sub eax,0x1000
  mov [PAGE_DIR_TABLE_POS+4092],eax

  mov ecx,256
  mov esi,0
  mov edx,PG_US_U|PG_RW_W|PG_P
.create_pte:
  mov [ebx+esi*4],edx
  add edx,4096
  inc esi
  loop .create_pte

mov eax,PAGE_DIR_TABLE_POS
add eax,0x2000
or eax,PG_US_U|PG_RW_W|PG_P
mov ebx,PAGE_DIR_TABLE_POS
mov ecx,254
mov esi,769
.create_kernel_pde:
  mov [ebx+esi*4],eax
  inc esi
  add eax,0x1000
  loop .create_kernel_pde
  ret
