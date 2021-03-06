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
    mov $0x0,%ah # code of the function of int 16h. It reads a keyboard buffer, waits for key to be pressed and then returns the result. // код функции int 16h. Читает буфер из клавиатуры. Ждёт нажатия клавиши, а затем возвращает результат
    # ah will contain a scan-code of the key pressed // В ah будет scan-код клавиши.
    # If the key is a character key then al will contain its ASCII-code. If the key is a functional key then al will contain zero (0). // Если клавиша символьная, то в al будет её ASCII-код, если клавиша функциональная, то в al будет 0
    int $0x16 # interrupt working with the keyboard // прерывание для работы с клавиатурой
    PRINT_TO_SCR # print a symbol corresponding to the key pressed // выводим на экран символ (соответствующий нажатой клавише)

    cmp $0x0d,%al # If al contains 0dh (ASCII-code of Enter key, carriage return symbol - CR) then we'll print a message. // Если в al 0dh (ASCII-код при нажатии клавиши Enter - символ возврата каретки, CR), то будем выводить сообщение.
    jne scan_key # Если нет, то снова считываем нажатую кнопку 
    
    mov $msg, %si # put msg address into si / Положить адрес сообшщения msg в si
    mov $0x0, %ah # // Function of videomode setting/claering the screen // функция установки видеорежима/очистки экрана
    mov $0x02, %al # // Videomode 40x25, 16/8 colors, semitones, CGA/EGA, address b800, Composite monitor // видеорежим 40x25, 16/8 цветов, полутона, CGA/EGA видеоадаптер, адрес b800, монитор Composite
    int $0x10 


    mov $0x0, %bh # number of the page of the screen / номер страницы экрана
    mov $0x02, %ah # Function of moving cursor to the place specified // Функция перемещения курсора
    mov $0x15, %dl # Number of the column (from the left) // Номер столбца (начиная с левого)
    mov $0x8, %dh # Number of the row (from the top) // Номер строки (начиная с верхней)
    int $0x10 # Set cursor position //Установка курсора в заданную позицию


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
    mov $0x0, %bh # номер страницы экрана
    mov $0x02, %ah # Функция перемещения курсора
    mov $0x0, %dl # Номер столбца (начиная с левого)
    mov $0x0, %dh # Номер строки (начиная с верхней)
    int $0x10 # Установка курсора в заданную позицию

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
  
    mov $0x0, %bh # number of the screen page // номер страницы экрана
    mov $0x02, %ah # Function of cursor moving // Функция перемещения курсора
    mov $0x48, %dl # Number of the column (starting from left) // Номер столбца (начиная с левого)
    mov $0x0, %dh # Number of the row (starting from top) // Номер строки (начиная с верхней)
    int $0x10 # Move the cursor to the position specified // Установка курсора в заданную позицию


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
    
    mov $0x0, %bh # number of the page of the screen / номер страницы экрана
    mov $0x02, %ah # Function of cursor moving / Функция перемещения курсора
    mov $0x0, %dl # Номер столбца (начиная с левого) / Number of the column (from left)
    mov $0x0, %dh # Номер строки (начиная с верхней) / Number of the string (from the top)
    int $0x10 # Установка курсора в заданную позицию / Move cursor to the position specified

# Здесь будет вывод содержимого регистров // There will be a printing of the contents of the registers
# Регистры должны выводиться в нижней строке экрана (вычислить её номер) // Resisters should be printed on the bottom string of the screen (number of the string should be calculated) 



# PRINT_HEX <%al>
#  PRINT_NEWLINE 
    hlt # halt the system // остановить систему
msg:
    .asciz "Welcome to rock'n'roll OS!!!" # string for printing, ending with zero // строка для вывода, заканчивается нулём
ax_print:
    .asciz "AX=" # string "AX=" // строка "AX="
