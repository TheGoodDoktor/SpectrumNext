; SPRTEST2 source
org $8000

; enable sprite rendering on screen and in border
LD BC,$243B	; register number
LD A,$15		; sprite register
OUT (C),A
LD BC,$253B	; register value
LD A,$03
OUT (C),A

; setup sprite state structures
; a set of random positions and velocities
LD HL,sprite_states
LD B,$40	; setup 64 sprites
LD DE,$0000	; point to the start of ROM, random number gen?

setup_loop:

PUSH BC
HALT	; wait for vblank
LD A,R
LD C,A
LD A,(DE)
INC DE
XOR C
XOR L
AND $3F		; clamp into range (0-63)
ADD A,$18
LD (HL),A	; write sprite state byte 0 (x position)
INC HL
LD B,A

delay1:
DJNZ delay1

LD A,R
LD C,A
LD A,(DE)
INC DE
XOR C
XOR L
AND $7F		; clamp into range (0-127)
ADD A,$18
LD (HL),A	; write sprite state byte 1 (y position)
INC HL
LD (HL),$01 ; write sprite state byte 2 (?? unused?)
INC HL
POP BC
PUSH BC
PUSH AF
LD A,B
AND $0F
ADD A,A
ADD A,A
ADD A,A
ADD A,A
INC A
LD (HL),A ; write sprite state byte 3 (?? unused?)
POP AF
INC HL
LD B,A

delay2:
DJNZ delay2

; xvelocity is -4 > 3
LD A,R
AND $07		; clamp to 0-7
SUB $04		; sub 4
LD (HL),A ; write sprite state byte 4 (x velocity)
INC HL
LD B,A

delay3:
DJNZ delay3

; xvelocity is -4 > 3
LD A,R
AND $07		; clamp to 0-7
SUB $04		; sub 4
LD (HL),A	; write sprite state byte 5 (y velocity)
INC HL
POP BC	; pop to get counter back
DJNZ setup_loop	; loop back to next sprite

; frame update
frame_loop:

HALT		; wait for vblank

LD BC,$303B	; select sprite 0
XOR A
OUT (C),A

LD H,$40			; update 64 sprites
LD DE,$0006			; 6 bytes per sprite
LD IX,sprite_states	; point to sprite state data
LD BC,$0057			; write to sprite attribs


sprite_loop:	; for each sprite

LD A,(IX+00)	; load x position
ADD A,(IX+04)	; add x vel
LD (IX+00),A	; write back

; X bounce behaviour
CP $08			; compare x pos to 8
JR C,bounce_x
CP $84			; compare xpos to 132
JR C,move_y

bounce_x:
; negate x velocity
LD A,(IX+04)
CPL	; invert all bits of A
INC A
LD (IX+04),A

move_y:
LD A,(IX+01)	; load y pos
ADD A,(IX+05)	; add y vel
LD (IX+01),A	; write back

; Y bounce behaviour
CP $08
JR C,bounce_y
CP $A8
JR C,write_sprite_attrib

bounce_y:
; negate 7 velocity
LD A,(IX+05)
CPL
INC A
LD (IX+05),A

write_sprite_attrib:
LD A,(IX+00)
ADD A,A		; multiply x pos by 2
OUT (C),A	; xpos
LD A,(IX+01)
OUT (C),A	; ypos
LD A,$00
ADC A,$00
OUT (C),A	; xpos MSB
LD A,$C0
SUB H		; subtract pattern number
OUT (C),A	; pattern & visibility
ADD IX,DE	; point IX to next sprite
DEC H
JR NZ,sprite_loop

; check for keypress
LD A,$7F
IN A,($FE)
RRA
JP C,frame_loop
XOR A
RET

sprite_states:	; 64 * 6 bytes
REPT 64
db 0	; x position
db 0	; y position
db 0
db 0
db 0	; x vel
db 0	; y vel
ENDM 