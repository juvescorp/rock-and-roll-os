.code16 # tells GAS to output 16-bit code / Компиляция в 16-битный код
.macro PRINT_TO_SCR # procedure for printing symbol to the screen / макрокоманда (процедура/функция) для вывода символа на экран 
  mov $0x0e, %ah # load 0e - code of a screen output BIOS function / загрузка 0e, кода функции вывода на экран BIOS
  int $0x10 # call of BIOS interrupt that will print a symbol on the screen / вызов прерывания BIOS, которое выведет символ на экран
.endm

.macro HEX_TO_STR_AND_PRINT # procedure for converting two hex digits in al to symbols and print them / процедура для преобразования в символы и вывода двух шестнадцатиричных цифр, находящихся в al 
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
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран
    mov %dl, %al # restore dl in al to print a lower-order HEX-digit on a screen / восстановить dl из al для вывода младшего шестнадцатиричного разряда на экран
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран
.endm

scan_key:
    mov $0x0,%ah # код функции int 16h. Читает буфер из клавиатуры. Ждёт нажатия клавиши, а затем возвращает результат
    # В ah будет scan-код клавиши.
    # Если клавиша символьная, то в al будет её ASCII-код, если клавиша функциональная, то в al будет 0
    int $0x16 # прерывание для работы с клавиатурой
    PRINT_TO_SCR # выводим на экран символ (соответствующий нажатой клавише)

#    cmp 0,%al # Если в al не ноль, то клавиша символьная, повторяем чтение снова
#    jne scan_key 
    cmp $0x0d,%al # Если в al 0dh (ASCII-код при нажатии клавиши Enter - символ возврата каретки, CR), то будем выводить сообщение.
    jne scan_key # Если нет, то снова считываем нажатую кнопку 
    
    mov $msg, %si # put msg address into si / Положить адрес сообшщения msg в si
print_welcome:
    lodsb # move byte from address ds:si to al and add 1 to si 
    # Считать байт по адресу DS:(E)SI в AL и добавить 1 к SI
    or %al, %al # logical OR (checking if al=0) 
    # логическое ИЛИ проверка, равен ли нулю al
    jz print_date # if zf(zero flag)=0 (means that al=0) then print date and time
    # если zf(флаг нуля)=0 (это значит, что al=0), то переходим к выводу даты и времени
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран
    jmp print_welcome # jump to "print_welcome", next step of a cycle // перейти к метке loop, на следующий шаг цикла
print_date:
    mov $0x0d, %al # Carriage return to the beginning of the string // Возврат каретки в начало строки
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран
    mov $0x0a, %al # jump to next string // переход в начало следующей строки
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран
    mov $0x07, %al # 07 stands for day // 07 - значение для запроса дня месяца
    out %al, $0x70 # requesting current date/time // запрос текущей даты/времени
    in $0x71, %al ## get date to al in xx format. 19 stands for 2019
    # Получаем дату в al в формате xx. 19 соответствует 2019.
    HEX_TO_STR_AND_PRINT
    mov $0x2d, %al # тире/dash
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран
#-----------It needs to make a procedures/functions for date output-----------
#-----------Нужно сделать процедуры/функции для вывода даты-------------------

    mov $0x08, %al # 08 stands for month // 08 - значение для запроса месяца
    out %al, $0x70 # requesting current date/time // запрос текущей даты/времени
    in $0x71, %al # Get current month in xx-format // получение текущего месяца в формате xx
    HEX_TO_STR_AND_PRINT
    mov $0x2d, %al # тире/dash
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран

    mov $0x09, %al # 09 stands for year // 09 - значение для запроса года
    out %al, $0x70 # requesting current date/time // запрос текущей даты/времени

    in $0x71, %al # Get current year in xx-format // Получение текущего года в формате xx
    HEX_TO_STR_AND_PRINT
    mov $0x0d, %al # Carriage return to the beginning of the string // Возврат каретки в начало строки
    PRINT_TO_SCR # print symbol on a screen // вывести символ на экран
    mov $0x0a, %al # empty string // пустая строка
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран
 
    mov $0x04, %al # 04 stands for hours // 04 - значение для запроса текущего часа 
    out %al, $0x70 # requesting current date/time // запрос текущей даты/времени
    in $0x71, %al #Get current year in xx-format // Получение текущего часа в формате xx
    HEX_TO_STR_AND_PRINT

    mov $0x3a, %al # ":" // colon symbol // символ двоеточия
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран

    mov $0x02, %al # 02 stands for minutes // 02 - значение для запроса текущей минуты
    out %al, $0x70 # requesting current date/time // запрос текущей даты/времени
    in $0x71, %al # Get current minute in xx-format // Получение текущей минуты в формате xx
    HEX_TO_STR_AND_PRINT

    mov $0x3a, %al # ":" // colon symbol // символ двоеточия
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран

    mov $0, %al # 0 stands for seconds // 0 - значение для запроса текущей секнды
    out %al, $0x70 # requesting current date/time // запрос текущей даты/времени
    in $0x71, %al # Get current second in xx-format // Получение текущей секунды в формате xx
    HEX_TO_STR_AND_PRINT
    
    mov 0, %cl
    mov 0, %ch
    mov $0x19, %dh
    mov $0x50, %dl
    mov $0x07, %ah
    mov $0x00, %al
    int $0x10 # Очистка экрана/прокрутка

    mov 7, %bh
    mov $0x02, %ah
    mov 0, %dl
    mov 0, %dh
    int $0x10 # Установка курсора в заданную позицию
 
# PRINT_HEX <%al>
#  PRINT_NEWLINE 
    hlt # halt the system // остановить систему
msg:
    .asciz "Welcome to rock'n'roll OS!!!" # string for printing, ending with zero // строка для вывода, заканчивается нулём
