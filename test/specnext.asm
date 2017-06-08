; Spectrum Next Routines

; Constants
; ---------

kRegisteryRegNumber EQU $243b
kRegisteryValue 	EQU $253b

; See: http://www.specnext.com/tbblue-io-port-system/
kRegMachineId		EQU 0
kRegVersion			EQU 1
kRegReset			EQU 2
kRegSetMachineType	EQU 3
kRegSetRAMPage		EQU 4
kRegSprite 			EQU 21

; sprites
kSpriteSelectPort 		EQU $303b	; select sprite/pattern
kSpritePalettePort 		EQU $0053	; port to write palette
kSpritePatternDataPort 	EQU $0055	; port to write pattern data
kSpriteAttribPort 		EQU $0057	; port to write sprite attributes (position etc.)

; audio
kAYRegSelectPort 	EQU $fffd
kAYRegWritePort 	EQU $bffd

; Macros

; Macro to write to 16-bit port number by using bc register
; Clobbers B, C
OutPort16 MACRO port, val
  ld bc, port
  out (c), val
ENDM

; Macro to read from 16-bit port number using bc into a
; Clobbers BC, returns in A
InPort16 MACRO port
  ld bc, port
  in a,(c)
ENDM

; Set one of the Next registers
; clobbers ABC
SetNextRegister MACRO reg, val
	ld a, reg
	OutPort16 kRegisteryRegNumber, a	
	ld a, val
	OutPort16 kRegisteryValue, a
ENDM

; select which sprite to use
; clobbers ABC
SelectSprite MACRO spriteNo
	ld a, spriteNo
	OutPort16 kSpriteSelectPort, a
ENDM

; Macro to write val to register reg in AY sound chip
; Clobbers ABC
SetAYRegister MACRO reg, val
  ld a, reg
  OutPort16 kAYRegSelectPort, a
  ld a, val
  OutPort16 kAYRegWritePort, a
ENDM

; Functions
; ---------

; Upload a sprite pattern

; Input Registers:
; A		: pattern number 
; HL	: pointer to pattern data (16*16 bytes)
; Affects registers: A,B,C,D,HL
upload_sprite_pattern:

; set pattern register
OutPort16 kSpriteSelectPort, a

; upload data
ld bc, kSpritePatternDataPort	; pattern data output port
ld d,0			; set counter to 0 for 256 iterations
upload_loop:
	ld a,(hl)	; copy sprite byte to A
	out (c),a	; output to port
	inc hl		; inc sprite pointer
	dec d		; decrement counter
	jr nz, upload_loop	; loop back if not zero

ret

; upload sprite attribs
; basically copies straight from RAM
; HL: sprite attrib pointer
; A: first sprite
; D: number of sprites
; Uses: A,B,C,D,HL
upload_sprite_attribs:

ld bc, kSpriteSelectPort
out (c),a

ld bc, kSpriteAttribPort
attrib_loop:
	ld a,(hl)	; copy sprite attrib byte 0 to A
	out (c),a	; output to port
	inc hl		; inc sprite attrib pointer
	ld a,(hl)	; copy sprite attrib byte 1 to A
	out (c),a	; output to port
	inc hl		; inc sprite attrib pointer
	ld a,(hl)	; copy sprite attrib byte 2 to A
	out (c),a	; output to port
	inc hl		; inc sprite attrib pointer
	ld a,(hl)	; copy sprite attrib byte 3 to A
	out (c),a	; output to port
	inc hl		; inc sprite attrib pointer

	dec d		; decrement counter
	jr nz, attrib_loop	; loop back if not zero

ret

; declare sprite work area in RAM
; store 16 sprites
sprite_attribs:
REPT 16
	db 0	; X position (bits 0-7)
	db 0	; Y position
	db 0	; bits: 0: X MSB, 1: Rotate, 2: Y mirror, 3: X mirror, 4-7: Palette offset 
	db 0	; bits: 0-5: pattern index, 6: Reserverd, 7: Visible flag
ENDM

; sprite test area
sprite_data:
incbin "tree.spr"

sprite_test:

	; upload data to sprite pattern 2 - works
	ld a, 2
	ld hl, sprite_data
	call upload_sprite_pattern
	
	halt
	
	; select sprite - works
	SelectSprite 0
	ld h,$4

	; setup sprite attributes
	ld bc, kSpriteAttribPort
testlp:	
	;ld a, d	; co-ordinate
	ld a, 20
	add a, h
	out(c), a	; x
	out(c), a	; y
	ld a,0		; no palette offset, rotate or flip
	out(c), a	
	ld a,$c0	; pattern 2 - visible
	sub h
	out(c), a	
	
	dec h
	jr nz, testlp
	
	; Set all sprites to be visible	- works
	SetNextRegister kRegSprite, 3

ret
