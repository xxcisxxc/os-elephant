bochs-start: bochsrc.disk hd60M.img
	bochs -f bochsrc.disk

qemu-start: qemu60M.img
	qemu-system-i386 -drive format=raw,file=qemu60M.img	

bochs-disk:
	bximage -hd=$(DISK_SIZE) -imgmode='flat' -q $(DISK_NAME)

qemu-disk:
	qemu-img create -f raw $(DISK_NAME) $(DISK_SIZE)
