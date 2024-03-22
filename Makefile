#!Makefile
#
# --------------------------------------------------------
#
#    hurlex 这个小内核的 Makefile
#    默认使用的C语言编译器是 GCC、汇编语言编译器是 nasm
#
# --------------------------------------------------------
#

# patsubst 处理所有在 C_SOURCES 字列中的字（一列文件名），如果它的 结尾是 '.c'，就用 '.o' 把 '.c' 取代
C_SOURCES = $(shell find . -name "*.c")
C_OBJECTS = $(patsubst %.c, %.o, $(C_SOURCES))
S_SOURCES = $(shell find . -name "*.s")
S_OBJECTS = $(patsubst %.s, %.o, $(S_SOURCES))

CC = gcc
LD = ld
ASM = nasm

C_FLAGS = -c -Wall -m32 -ggdb -gstabs+ -nostdinc -fno-builtin -fno-stack-protector -I include
LD_FLAGS = -T scripts/kernel.ld -m elf_i386 -nostdlib
ASM_FLAGS = -f elf -g -F stabs

all: $(S_OBJECTS) $(C_OBJECTS) link update_image

# The automatic variable `$<' is just the first prerequisite
.c.o:
	@echo 编译代码文件 $< ...
	$(CC) $(C_FLAGS) $< -o $@

.s.o:
	@echo 编译汇编文件 $< ...
	$(ASM) $(ASM_FLAGS) $<

link:
	@echo 链接内核文件...
	$(LD) $(LD_FLAGS) $(S_OBJECTS) $(C_OBJECTS) -o boos_kernel

.PHONY:clean
clean:
	$(RM) $(S_OBJECTS) $(C_OBJECTS) boos_kernel

.PHONY:update_image
update_image:
	mount floppy.img /mnt
	cp boos_kernel /mnt/hx_kernel
	sleep 1
	umount /mnt

.PHONY:mount_image
mount_image:
	mount floppy.img /mnt

.PHONY:umount_image
umount_image:
	umount /mnt

.PHONY:qemu
qemu:
	qemu-system-i386 -fda floppy.img -boot a	
	#add '-nographic' option if using server of linux distro, such as fedora-server,or "gtk initialization failed" error will occur.

.PHONY:bochs
bochs:
	bochs -f scripts/bochsrc.txt

.PHONY:debug
debug:
	qemu -S -s -fda floppy.img -boot a &
	sleep 1
	cgdb -x scripts/gdbinit

.PHONY:dockerall
dockerall:
	docker run --privileged --rm -it -w /root -v .:/root boos make all