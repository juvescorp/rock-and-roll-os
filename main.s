.code16 # tells GAS to output 16-bit code / Компиляция в 16-битный код
    mov $msg, %si # put msg address into si / Положить адрес сообшщения msg в si
    mov $0x0e, %ah # put 0x0e into ah (function of int 10h - print a string) 
    # Положить в ah 0x0e (номер функции int 10h - вывести строку на экран)
loop:
    lodsb # move byte from address ds:si to al and add 1 to si 
    # Считать байт по адресу DS:(E)SI в AL и добавить 1 к SI
    or %al, %al # logical OR (checking if al=0) 
    # логическое ИЛИ проверка, равен ли нулю al
    jz halt # if zf(zero flag)=0 (means that al=0) then halt the system 
    # если zf(флаг нуля)=0 (это значит, что al=0), то останавливаем систему
    int $0x10 # print symbol on a screen // вывести символ на экран
    jmp loop # jump to "loop", next step of a cycle // перейти к метке loop, на следующий шаг цикла
halt:
    mov $0x0a, %al # empty string // пустая строка
    int $0x10 # print symbol on a screen //прерывание для вывода символа на экран 
    mov $0x07, %al # port 07 stands for day // 07 - порт для дня месяца
    out %al, $0x70 # requesting current date/time // запрос текущей даты/времени
    in $0x71, %al ## get date to al in xx format. 19 stands for 2019
    # Получаем дату в al в формате xx. 19 соответствует 2019.
    # Below is the explanation for preparing number for printing
    # Подготовка к выводу числа на экран показана ниже
    mov %al, %ah # save al to ah / сохраняем al в ah
    and $0x0f, %al # AL contains lower digit of the number / AL содержит младший разряд числа
    add $0x30, %al # add 30 to get an ASCII code of digit symbol for printing / добавляем 30, чтобы получить ASCII-код символа соответствующей цифры для вывода на экран
    # For example if a digit is 2 the ASCII code will be 32 / Например, если имеем цифру 2, то её ASCII-код будет 32
    shr $4, %ah # shift ah for 4 binary digits to the right / сдвигаем ah на 4 двоичных цифры вправо
    # shift is needed for converting a digit in ah to ASCII-code. For the start we need to move this digit to a lower order
    # сдвиг нужен, чтобы перевести цифру в ah в ASCII-код. Для начала нужно для обработки эту цифру перенести в младший разряд ah 
    add $0x30, %ah # add 30 to get an ASCII code of digit symbol for printing / добавляем 30, чтобы получить ASCII-код символа соответствующей цифры для вывода на экран
    mov %al, %dl # save lower-order HEX-digit to dl / сохраняем младший шестнадцатиричный разряд в dl
    mov %ah, %al # move higher-order HEX-digit to al for further printing / отправляем старший разряд в al для последующего вывода
    mov $0x0e, %ah # put 0x0e into ah (function of int 10h - print a string) 
    # Положить в ah 0x0e (номер функции int 10h - вывести строку на экран)
    int $0x10 # print symbol on a screen //прерывание для вывода символа на экран 
    mov %dl, %al # restore dl in al to print a lower-order HEX-digit on a screen / восстановить dl из al для вывода младшего шестнадцатиричного разряда на экран
    int $0x10 # print symbol on a screen //прерывание для вывода символа на экран 
    mov $0x2d, %al # тире/dash
    int $0x10 # print symbol on a screen //прерывание для вывода символа на экран 


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
