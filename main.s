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
    mov $0x0a, %al # empty string
    int $0x10

    mov $0x07, %al # 07 stands for day
    out %al, $0x70 # requesting current date/time
    in $0x71, %al # xx-format, 19 - 2019
    mov %al, %ah
    and $0x0f, %al
    add $0x30, %al
    shr $4, %ah
    add $0x30, %ah
    mov %al, %dl
    mov %ah, %al
    mov $0x0e, %ah
    int $0x10
    mov %dl, %al
    int $0x10

    mov $0x2d, %al # тире/dash
    int $0x10

    mov $0x08, %al # 08 stands for month
    out %al, $0x70 # requesting current date/time
    in $0x71, %al # xx-format
    mov %al, %ah
    and $0x0f, %al
    add $0x30, %al
    shr $4, %ah
    add $0x30, %ah
    mov %al, %dl
    mov %ah, %al
    mov $0x0e, %ah
    int $0x10
    mov %dl, %al
    int $0x10 

    mov $0x2d, %al # тире/dash
    int $0x10

    mov $0x09, %al # 09 stands for year
    out %al, $0x70 # requesting current date/time
    in $0x71, %al # xx-format
    mov %al, %ah
    and $0x0f, %al
    add $0x30, %al
    shr $4, %ah
    add $0x30, %ah
    mov %al, %dl
    mov %ah, %al
    mov $0x0e, %ah
    int $0x10
    mov %dl, %al
    int $0x10
  
    mov $0x0a, %al # empty string
    int $0x10
 
    mov $0x04, %al # 04 stands for hours
    out %al, $0x70 # requesting current date/time
    in $0x71, %al # xx-format
    mov %al, %ah
    and $0x0f, %al
    add $0x30, %al
    shr $4, %ah
    add $0x30, %ah
    mov %al, %dl
    mov %ah, %al
    mov $0x0e, %ah
    int $0x10
    mov %dl, %al
    int $0x10

    mov $0x3a, %al # ":"
    int $0x10

    mov $0x02, %al # 02 stands for minutes
    out %al, $0x70 # requesting current date/time
    in $0x71, %al # xx-format
    mov %al, %ah
    and $0x0f, %al
    add $0x30, %al
    shr $4, %ah
    add $0x30, %ah
    mov %al, %dl
    mov %ah, %al
    mov $0x0e, %ah
    int $0x10
    mov %dl, %al
    int $0x10

    mov $0x3a, %al # ":"
    int $0x10

    mov $0, %al # 0 stands for seconds
    out %al, $0x70 # requesting current date/time
    in $0x71, %al # xx-format
    mov %al, %ah
    and $0x0f, %al
    add $0x30, %al
    shr $4, %ah
    add $0x30, %ah
    mov %al, %dl
    mov %ah, %al
    mov $0x0e, %ah
    int $0x10
    mov %dl, %al
    int $0x10


 
# PRINT_HEX <%al>
#  PRINT_NEWLINE 
    hlt # halt the system // остановить систему
msg:
    .asciz "Welcome to rock'n'roll OS!!!" # string for printing, ending with zero // строка для вывода, заканчивается нулём
