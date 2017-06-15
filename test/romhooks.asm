; Hooks to ROM routines/data

; Clear screen
rom_cls     EQU $0D6B
; put colour in screen_clear_col
rom_cls_col	EQU $0DAF

; Set the border colour
; A : border colour
‭rom_set_border_col EQU $229B‬

; Open channel
; A : channel number:
;		2 : Upper screen
rom_opench  EQU $1601

; Print string
; DE : String pointer
; BC : String length
rom_print   EQU $203C

; Print number
; BC : Number to print (0-9999)
rom_print_num   EQU $1A1B

; These two will print numbers 0-65535
; BC : number to print
rom_print_calc_stack		EQU $2D2B
rom_print_calc_stack_top	EQU $2DE3

; Print control codes:
; 13		NEWLINE	sets print position to the beginning of the next line.
; 16,c		INK		Sets ink colour to the value of the following byte.
; 17,c		PAPER	Sets ink colour to the value of the following byte.
; 22,x,y	AT		Sets print x and y coordinates to the values specified in the following two bytes.
; 144-164	UDG Characters
; Use RST 16 to print individual characters or rom_print for strings

; BEEP
; HL : Pitch = (437500 / Frequency) - 30.125
; DE : Duration = Frequency * Seconds 
‭rom_beep EQU $03B5‬

; ROM Data

; address of font in ROM
rom_fontdata EQU $3D00

; System variables
‭
; last key pressed
last_k EQU $5C08‬

; pointer to font - 256 (32 * 8)
; Space is the first character draw which is ASCII code 32, this is why we have the (32 * 8) offset
font_ptr EQU $5C36

; pointer to start of UDG memory
udg_ptr EQU $5C7B

; what colour to clear the screen with
screen_clear_col EQU $5C8D


