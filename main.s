.code16 # tells GAS to output 16-bit code / Компиляция в 16-битный код
    mov $msg, %si # put msg address into si / Положить адрес сообшщения msg в si
    mov $0x0e, %ah # put 0x0e into ah (function of int 10h - print a string) 
    # Положить в ah 0x0e (номер функции int 10h - вывести строку на экран)
loop:
    lodsb # move byte from address ds:si to al and add 1 to si 
    # Считать байт по адресу DS:(E)SI в AL и добавить 1 к SI
    or %al, %al # logical or // логическое или
    jz halt # if zf(zero flag)=0 (means that al=0) then halt the system 
    # если zf(флаг нуля)=0 (это значит, что al=0), то останавливаем систему
    int $0x10 # print symbol on a screen // вывести символ на экран
    jmp loop # jump to "loop", next step of a cycle // перейти к метке loop, на следующий шаг цикла
halt: 
    hlt # halt the system // остановить систему
msg:
    .asciz "hello world" # string for printing, ending with zero // строка для вывода, заканчивается нулём
