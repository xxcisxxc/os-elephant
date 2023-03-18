LOAD_SEC = 0
LOAD_NUM = 1

bochs-start: bochsrc.$(shell uname) hd60M.img
	bochs -f bochsrc.$(shell uname)

qemu-start: qemu60M.img
	qemu-system-i386 -drive format=raw,file=qemu60M.img	

bochs-disk:
	bximage -hd=$(DISK_SIZE) -imgmode='flat' -q $(DISK_NAME)

qemu-disk:
	qemu-img create -f raw $(DISK_NAME) $(DISK_SIZE)

%: %.S include/boot.inc
	nasm -f bin -I include -o $@.bin $@.S

load-disk:
	dd if=$(LOAD_BIN) of=$(LOAD_IMG) bs=512 count=$(LOAD_NUM) seek=$(LOAD_SEC) conv=notrunc
