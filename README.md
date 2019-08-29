# rock-and-roll-os
Developing an OS in ASM

First steps are taken from there https://stackoverflow.com/questions/22054578/how-to-run-a-program-without-an-operating-system/32483545#32483545

as -g -o main.o main.S
ld --oformat binary -o main.img -T link.ld main.o
qemu-system-x86_64 -hda main.img
