; Spectrum Next Routines

; Constants
; ---------

kRegisteryRegNumber EQU $243b
kRegisteryValue 	EQU $253b

; See: http://www.specnext.com/tbblue-io-port-system/
kRegMachineId			EQU 0
kRegVersion				EQU 1
kRegReset				EQU 2
kRegSetMachineType		EQU 3
kRegSetRAMPage			EQU 4
kRegPeripheral1			EQU 5
kRegPeripheral2			EQU 6
kRegTurboMode			EQU 7
kRegPeripheral3			EQU 8
kRegAntiBrick			EQU 10
kRegLayer2Trans			EQU 20
kRegSpriteSystem		EQU 21
kRegLayer2OffX			EQU 22
kRegLayer2OffY			EQU 23
kRegRasterLineMSB		EQU 30
kRegRasterLine			EQU 31
kRegRasterLineIntCtrl	EQU 34
kRegRasterLineIntVal	EQU 35

; sprites
kSpriteSelectPort 		EQU $303b	; select sprite/pattern
kSpritePalettePort 		EQU $0053	; port to write palette
kSpritePatternDataPort 	EQU $0055	; port to write pattern data
kSpriteAttribPort 		EQU $0057	; port to write sprite attributes (position etc.)

; audio
kAudioRegSelectPort 	EQU $fffd
kAudioRegWritePort 		EQU $bffd

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

; Macro to write val to register reg in Audio sound chip
; Clobbers ABC
SetAudioRegister MACRO reg, val
  ld a, reg
  OutPort16 kAudioRegSelectPort, a
  ld a, val
  OutPort16 kAudioRegWritePort, a
ENDM

; Functions
; ---------

; Upload a sprite pattern

; Input Registers:
; A		: pattern number 
; HL	: pointer to pattern data (16*16 bytes)
; Affects registers: A,B,C,D,HL
PROC
LOCAL upload_loop
UploadSpritePattern:

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
ENDP

; upload sprite attribs
; basically copies straight from RAM
; HL: sprite attrib pointer
; A: first sprite
; D: number of sprites
; Uses: A,B,C,D,HL
UploadSpriteAttribs:

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
