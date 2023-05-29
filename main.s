.code16 # tells GAS to output 16-bit code / Компиляция в 16-битный код

.macro PRINT_TO_SCR # procedure for printing symbol to the screen / макрокоманда (процедура/функция) для вывода символа на экран 
  mov $0x0e, %ah # load 0e - code of a screen output BIOS function / загрузка 0e, кода функции вывода на экран BIOS
  int $0x10 # call of BIOS interrupt that will print a symbol on the screen / вызов прерывания BIOS, которое выведет символ на экран
.endm

.macro PRINT_TO_SCR_VIDEOMEM coordinates,symbol # procedure for printing a symbol on the screen through videomemory / процедура для вывода символа на экран через видеопамять
  push %es # Save ES in stack / Сохранить значение регистра ES в стеке
  mov $0xB800,%ax # Сегмент видеопамяти для видеорежима 2 - B800 // Videomemory segment for videomode 2 is B800
  mov \coordinates,%di # координаты для вывода текста DI=160*y+2*x // coordinates for text output DI=160*y+2*x 
  mov %ax,%es #  Запись адреса сегмента видеопамяти в сегментный регистр es // Move address of videomemory segment to the segremt register es
  mov \symbol,%al
  mov %al,%es:(%di) # видеопамять / videomemory # print symbol on a screen // вывести символ на экран
  pop %es # Turn back ES from stack / Вернуть значение ES из стека
.endm

#.macro DEC_FOR_OUTPUT
#    add $0x30, %al
#.endm

#.macro HEX_A_F_FOR_OUTPUT
#    add $0x37, %al
#.endm

.macro HEX_TO_STR_AND_PRINT # procedure for converting two hex digits in al to symbols and print them / процедура для преобразования в символы и вывода двух шестнадцатиричных цифр, находящихся в al 
    # Below is the explanation for preparing number for printing
    # Подготовка к выводу числа на экран показана ниже
    mov %al, %ah # save al to ah / сохраняем al в ah
    and $0x0f, %al # AL contains lower digit of the number / AL содержит младший разряд числа
    cmp $0x0a, %al # Check if AL is higher or equal than A(10) / Проверяем значение в AL: больше/равно A(10) или нет
    jae 1f # If higher or equal than process as a hex / Если больше или равно, то обрабатываем, как шестнадцатиричное
    # Otherwise - as a decimal / Иначе - как десятичное 
    add $0x30, %al # add 30 to get an ASCII code of digit symbol for printing / добавляем 30, чтобы получить ASCII-код символа соответствующей цифры для вывода на экран
    # For example if a digit is 2 the ASCII code will be 32 / Например, если имеем цифру 2, то её ASCII-код будет 32
    jmp 2f # jump to preparation for output / переход к подготовке вывода
1:
    add $0x37,%al # add 37 to get and ASCII code of HEX digit symbol (A..F) for printing / добавляем 37, чтобы получить ASCII-код шестнадцатиричной цифры-символа для вывода на экран  
    # Preparing digits for output / Подготовка к выводу цифр
2:
    shr $4, %ah # shift ah for 4 binary digits to the right / сдвигаем ah на 4 двоичных цифры вправо
    # shift is needed for converting a digit in ah to ASCII-code. For the start we need to move this digit to a lower order
    # сдвиг нужен, чтобы перевести цифру в ah в ASCII-код. Для начала нужно для обработки эту цифру перенести в младший разряд ah 
    cmp $0x0a, %ah # Check if AH is higher or equal than A(10) / Проверяем значение в AH: больше/равно A(10) или нет
    jae 3f # If higher or equal than process as a hex / Если больше или равно, то обрабатываем, как шестнадцатиричное
    add $0x30, %ah # add 30 to get an ASCII code of digit symbol for printing / добавляем 30, чтобы получить ASCII-код символа соответствующей цифры для вывода на экран
    jmp 4f  # jump to preparation for output / переход к подготовке вывода
3:
    add $0x37,%ah  # add 37 to get and ASCII code of HEX digit symbol (A..F) for printing / добавляем 37, чтобы получить ASCII-код шестнадцатиричной цифры-символа для вывода на экран  
    # Preparing digits for output / Подготовка к выводу цифр
4:
    mov %al, %dl # save lower-order HEX-digit to dl / сохраняем младший шестнадцатиричный разряд в dl
    mov %ah, %al # move higher-order HEX-digit to al for further printing / отправляем старший разряд в al для последующего вывода
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран
    mov %dl, %al # restore dl in al to print a lower-order HEX-digit on a screen / восстановить dl из al для вывода младшего шестнадцатиричного разряда на экран
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран
.endm

# string printing function is needed / Нужна функция вывода строки

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
    mov $0x02, %al # // Videomode 80x25, 16/8 colors, semitones, CGA/EGA, address b800, Composite monitor // видеорежим 80x25, 16/8 цветов, полутона, CGA/EGA видеоадаптер, адрес b800, монитор Composite
    int $0x10 # Set videomode / Установка видеорежима 

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
    mov $0x0, %bh # номер страницы экрана / number of page of the screen
    mov $0x02, %ah # Функция перемещения курсора / function of moving cursor to the coordinates 
    mov $0x0, %dl # Номер столбца (начиная с левого) / number of the column (from the left)
    mov $0x0, %dh # Номер строки (начиная с верхней) / number of the row (from the top)
    int $0x10 # Установка курсора в заданную позицию / Set cursor position

    mov $0x07, %al # 07 stands for day // 07 - значение для запроса дня месяца
    out %al, $0x70 # requesting current date/time // запрос текущей даты/времени
    in $0x71, %al ## get date to al in xx format. 19 stands for 2019
    # Получаем дату в al в формате xx. 19 соответствует 2019.
    HEX_TO_STR_AND_PRINT # Convert two HEX digits in AL into symbols and print // Преобразовать две цифры в AL в символы и вывести на экран
    mov $0x2d, %al # тире/dash
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран
#-----------It needs to make a procedures/functions for date output-----------
#-----------Нужно сделать процедуры/функции для вывода даты-------------------

    mov $0x08, %al # 08 stands for month // 08 - значение для запроса месяца
    out %al, $0x70 # requesting current date/time // запрос текущей даты/времени
    in $0x71, %al # Get current month in xx-format // получение текущего месяца в формате xx
    HEX_TO_STR_AND_PRINT # Convert two HEX digits in AL into symbols and print // Преобразовать две цифры в AL в символы и вывести на экран
    mov $0x2d, %al # тире/dash
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран

    mov $0x09, %al # 09 stands for year // 09 - значение для запроса года
    out %al, $0x70 # requesting current date/time // запрос текущей даты/времени

    in $0x71, %al # Get current year in xx-format // Получение текущего года в формате xx
    HEX_TO_STR_AND_PRINT # Convert two HEX digits in AL into symbols and print // Преобразовать две цифры в AL в символы и вывести на экран
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
    HEX_TO_STR_AND_PRINT # Convert two HEX digits in AL into symbols and print // Преобразовать две цифры в AL в символы и вывести на экран


    mov $0x3a, %al # ":" // colon symbol // символ двоеточия
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран

    mov $0x02, %al # 02 stands for minutes // 02 - значение для запроса текущей минуты
    out %al, $0x70 # requesting current date/time // запрос текущей даты/времени
    in $0x71, %al # Get current minute in xx-format // Получение текущей минуты в формате xx
    HEX_TO_STR_AND_PRINT # Convert two HEX digits in AL into symbols and print // Преобразовать две цифры в AL в символы и вывести на экран


    mov $0x3a, %al # ":" // colon symbol // символ двоеточия
    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран

    mov $0, %al # 0 stands for seconds // 0 - значение для запроса текущей секнды
    out %al, $0x70 # requesting current date/time // запрос текущей даты/времени
    in $0x71, %al # Get current second in xx-format // Получение текущей секунды в формате xx
    HEX_TO_STR_AND_PRINT # Convert two HEX digits in AL into symbols and print // Преобразовать две цифры в AL в символы и вывести на экран

    
    mov $0x0, %bh # number of the page of the screen / номер страницы экрана
    mov $0x02, %ah # Function of cursor moving / Функция перемещения курсора
    mov $0x0, %dl # Номер столбца (начиная с левого) / Number of the column (from left)
    mov $0x18, %dh # Номер строки (начиная с верхней) / Number of the string (from the top)
    int $0x10 # Установка курсора в заданную позицию / Move cursor to the position specified


 #   There will be a string directly recorded to videomemory // Здесь будет прямая запись строки в видеопамять
    mov $msg, %si # put msg address into si / Положить адрес сообшщения msg в si
    push %es # сохранить в стеке значение сегментного регистра es // save the value of the segment register in stack
    mov $0xB800,%ax # Сегмент видеопамяти для видеорежима 2 - B800 // Videomemory segment for videomode 2 is B800
    mov %ax,%es #  Запись адреса сегмента видеопамяти в сегментный регистр es // Move address of videomemory segment to the segremt register es
    mov $0xA0,%di # координаты для вывода текста DI=160*y+2*x // coordinates for text output DI=160*y+2*x 
print_welcome2:
    lodsb # move byte (symbol) from address ds:si to al and add 1 to si 
    # Считать байт (символ) по адресу DS:(E)SI в AL и добавить 1 к SI
    or %al, %al # logical OR (checking if al=0) 
    # логическое ИЛИ проверка, равен ли нулю al
    jz after_print # if zf(zero flag)=0 (means that al=0) then go next
    # если zf(флаг нуля)=0 (это значит, что al=0), то переходим далее
    mov %al,%es:(%di) # видеопамять / videomemory # print symbol on a screen // вывести символ на экран
    inc %di # дважды увеличиваем дважды DI, поскольку символу отводится два байта // increment DI twice because there are two bytes assigned for symbol
    inc %di # первый байт - ASCII-код символа, второй байт - цвет; мы используем только первый // first byte - ASCII-code of symbol, second byte - color; we are using onle first
    jmp print_welcome2 # jump to "print_welcome2", next step of a cycle // перейти к метке print_welcome2, на следующий шаг цикла


after_print:
    pop %es # вернуть из стека значение сегментного регистра es // Turn back es register value from stack
    mov $0x32,%dl # В dl - координаты выводимого символа // dl contains coordinates for printed symbol 
    mov $0xB0,%bx # В bx - ASCII-код выводимого символа // bx contains ASCII-code for printed symbol
    PRINT_TO_SCR_VIDEOMEM %bx,%dl # применение функции/макрокоманды для вывода символа на экран через видеопамять // function/macro for printing a symbol on the screen through videomemory
    
# Здесь будет вывод содержимого регистров // There will be a printing of the contents of the registers
# Регистры должны выводиться в нижней строке экрана (вычислить её номер) // Resisters should be printed on the bottom string of the screen (number of the string should be calculated) 
#    mov $ax_print, %si # Load the address of "AX=" string / Загрузка адреса строки "AX="
#print_registers:
#    lodsb # move byte from address ds:si to al and add 1 to si 
#    # Считать байт по адресу DS:(E)SI в AL и добавить 1 к SI
#    PRINT_TO_SCR # int $0x10 # print symbol on a screen // вывести символ на экран
#    or %al, %al # logical OR (checking if al=0) 
#    # логическое ИЛИ, проверка, равен ли нулю al
#    jz print_ax_value # if zf(zero flag)=0 (means that al=0) then halt the system
#    # если zf(флаг нуля)=0 (это значит, что al=0), то останавливаем систему
#    jmp print_registers # jump to "print_registers", next step of a cycle // перейти к метке print_registers, на следующий шаг цикла
#print_ax_value:
#    mov $0xfffa,%ax # Testing. HEX_TO_STR_AND_PRINT not working for a..f numbers. // Тестирование ax для вывода. На цифрах от a..f не работает.
#    # need to fix HEX_TO_STR_AND_PRINT. Now it is DEC_TO_STR_AND_PRINT // Нужно поправить HEX_TO_STR_AND_PRINT. Сейчас это по факту DEC_TO_STR_AND_PRINT
#    push %ax # Save ax value (will be back later) // Сохраняем значение регистра ax, чтобы в будущем его вернуть 
#    # There will be manipulations for printing out ax value // Здесь будут манипуляции для вывода значения ax
#    mov %ah, %al # Сначала будет вывод ah, соответственно, загружаем ah в al / at first we will print out al, so we move ah into al
#    HEX_TO_STR_AND_PRINT # printing out the value in al // Вывод значения из al
#    pop %ax # Turn back the ax value // Возвращаем значение регистра ax к исходному
#    push %ax # Save ax value (will be back later) // Сохраняем значение регистра ax, чтобы в будущем его вернуть 
#    HEX_TO_STR_AND_PRINT # printing out the value in al // Вывод значения из al
#    pop %ax # Turn back the ax value // Возвращаем значение регистра ax к исходному

# PRINT_HEX <%al>
#  PRINT_NEWLINE 
halt:
    hlt # halt the system // остановить систему
msg:
    .asciz "Welcome to rock'n'roll OS!!!" # string for printing, ending with zero // строка для вывода, заканчивается нулём
ax_print:
    .asciz "AX=" # string "AX=" // строка "AX="
