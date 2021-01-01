# rock-and-roll-os
Developing an OS in ASM / Разработка операционной системы на ассемблере

First steps are taken from there / Первые шаги взяты отсюда
https://stackoverflow.com/questions/22054578/how-to-run-a-program-without-an-operating-system/32483545#32483545

Building the system in Linux / Сборка системы в Linux

as -g -o main.o main.s

ld --oformat binary -o main.img -T link.ld main.o

qemu-system-x86_64 -hda main.img
