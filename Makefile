LOAD_SEC = 0
LOAD_NUM = 1
DISK_SIZE = 48M
LOAD_IMG = hd$(DISK_SIZE).img

.PHONY: clean all

all: load-disk

bochs-start: bochsrc.$(shell uname) $(LOAD_IMG)
	bochs -f bochsrc.$(shell uname)

qemu-start: $(LOAD_IMG)
	qemu-system-i386 -drive format=raw,file=$(LOAD_IMG)

bochs-disk:
	bximage -hd=$(DISK_SIZE) -imgmode='flat' -q $(LOAD_IMG)

qemu-disk:
	qemu-img create -f raw $(LOAD_IMG) $(DISK_SIZE)

load-disk: load-mbr load-loader load-kernel
	#dd if=$(LOAD_BIN) of=$(LOAD_IMG) bs=512 count=$(LOAD_NUM) seek=$(LOAD_SEC) conv=notrunc

load-mbr: mbr.bin
	dd if=mbr.bin of=$(LOAD_IMG) bs=512 count=1 seek=0 conv=notrunc

load-loader: loader.bin
	dd if=loader.bin of=$(LOAD_IMG) bs=512 count=4 seek=2 conv=notrunc

load-kernel: kernel.bin
	dd if=kernel.bin of=$(LOAD_IMG) bs=512 count=200 seek=9 conv=notrunc
	
%.bin: boot/%.S boot/include/boot.inc
	nasm -f bin -I boot/include -o $*.bin boot/$*.S

kernel.bin: kernel/main.o lib/kernel/print.o kernel/kernel.o kernel/interrupt.o kernel/init.o device/timer.o kernel/debug.o lib/string.o lib/kernel/bitmap.o kernel/memory.o
	ld -melf_i386  -Ttext 0xc0001500 -e main -o kernel.bin $^

%.o: %.c lib/kernel lib/ kernel/ device/
	gcc -m32 -Wall -fno-builtin -W -Wstrict-prototypes -Wmissing-prototypes -I lib/kernel -I lib/ -I kernel/ -I device/ -c -o $*.o $*.c

%.o: %.S
	nasm -f elf -o $*.o $*.S

clean:
	find . -type f \( -name "*.o" -o -name "*.bin" \) -delete
