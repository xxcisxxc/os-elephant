LOAD_SEC = 0
LOAD_NUM = 1
DISK_SIZE = 48M
LOAD_IMG = hd$(DISK_SIZE).img

bochs-start: bochsrc.$(shell uname) $(LOAD_IMG)
	bochs -f bochsrc.$(shell uname)

#qemu-start: qemu60M.img
#	qemu-system-i386 -drive format=raw,file=qemu60M.img	

bochs-disk:
	bximage -hd=$(DISK_SIZE) -imgmode='flat' -q $(LOAD_IMG)

#qemu-disk:
#	qemu-img create -f raw $(LOAD_IMG) $(DISK_SIZE)

load-disk: mbr.bin loader.bin kernel.bin
	#dd if=$(LOAD_BIN) of=$(LOAD_IMG) bs=512 count=$(LOAD_NUM) seek=$(LOAD_SEC) conv=notrunc
	dd if=mbr.bin of=$(LOAD_IMG) bs=512 count=1 seek=0 conv=notrunc
	dd if=loader.bin of=$(LOAD_IMG) bs=512 count=4 seek=2 conv=notrunc
	dd if=kernel.bin of=$(LOAD_IMG) bs=512 count=200 seek=9 conv=notrunc

%.bin: %.S include/boot.inc
	nasm -f bin -I include -o $*.bin $*.S

kernel.bin: kernel/main.o lib/kernel/print.o kernel/kernel.o kernel/interrupt.o kernel/init.o
	ld -melf_i386  -Ttext 0xc0001500 -e main -o kernel.bin $^

%.o: %.c lib/kernel lib/ kernel/
	gcc -m32 -I lib/kernel -I lib/ -I kernel/ -c -fno-builtin -o $*.o $*.c

%.o: %.S
	nasm -f elf -o $*.o $*.S
