LOAD_SEC = 0
LOAD_NUM = 1
LOAD_IMG = hd60M.img

bochs-start: bochsrc.$(shell uname) hd60M.img
	bochs -f bochsrc.$(shell uname)

qemu-start: qemu60M.img
	qemu-system-i386 -drive format=raw,file=qemu60M.img	

bochs-disk:
	bximage -hd=$(DISK_SIZE) -imgmode='flat' -q $(DISK_NAME)

qemu-disk:
	qemu-img create -f raw $(DISK_NAME) $(DISK_SIZE)

load-disk: mbr.bin loader.bin kernel.bin
	#dd if=$(LOAD_BIN) of=$(LOAD_IMG) bs=512 count=$(LOAD_NUM) seek=$(LOAD_SEC) conv=notrunc
	dd if=mbr.bin of=$(LOAD_IMG) bs=512 count=1 seek=0 conv=notrunc
	dd if=loader.bin of=$(LOAD_IMG) bs=512 count=4 seek=2 conv=notrunc
	dd if=kernel.bin of=$(LOAD_IMG) bs=512 count=200 seek=9 conv=notrunc

%.bin: %.S include/boot.inc
	nasm -f bin -I include -o $*.bin $*.S

kernel.bin: kernel/main.c lib/kernel/print.S
	gcc -m32 -I lib/kernel/ -c -o main.o kernel/main.c
	nasm -f elf -o print.o lib/kernel/print.S
	ld -melf_i386  -Ttext 0xc0001500 -e main -o kernel.bin main.o print.o
