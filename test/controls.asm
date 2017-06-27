; control code

; Current controller state
; bit mappings mimic kempston
; 0	- right
; 1 - left
; 2 - down
; 3 - up
; 4 - fire
gControlCurVal db 0

; defined keys
; set some defaults
gControlKeyRight 	db 0
gControlKeyLeft 	db 1
gControlKeyDown 	db 2
gControlKeyUp 		db 3
gControlKeyFire 	db 4

; Read Kempston Joystick
; clobbers ABC
ReadKempston:

ld bc,31
in a,(c)
ld (gControlCurVal),a	; store values out
ret

; ROM routine to return key pressed
; E contains the key code (255 if no key is pressed)
RomKeyScan equ $028E

; wait for a key to be pressed
; key pressed returned in A
WaitForKey:
	call RomKeyScan
	ld a,e
	cp 255
	halt
	jr WaitForKey	; loop back if no key is pressed
	ret

; Mr. Jones' keyboard test routine.
; A contains the keyboard code
; Carry flag set if key isn't pressed
; clobbers abc
; https://chuntey.wordpress.com/2012/12/19/how-to-write-zx-spectrum-games-chapter-2/

TestKey:
	ld c,a              ; key to test in c.
    and 7               ; mask bits d0-d2 for row.
	inc a               ; in range 1-8.
	ld b,a              ; place in b.
	srl c               ; divide c by 8,
	srl c               ; to find position within row.
	srl c
	ld a,5              ; only 5 keys per row.
	sub c               ; subtract position.
	ld c,a              ; put in c.
	ld a,254            ; high byte of port to read.
ktest0:
	rrca                ; rotate into position.
	djnz ktest0         ; repeat until we've found relevant row.
	in a,(254)          ; read port (a=high, 254=low).
ktest1: 
	rra                 ; rotate bit out of result.
	dec c               ; loop counter.
	jp nz,ktest1        ; repeat until bit for position in carry.
	ret

; Read the keyboard controls
ReadKeys:
	ld d,(gControlCurVal)
	ld e, 1	; init bitmask
	ld hl, gControlKeyRight	; load HL with address of first key
	ld b, 5	; read 5 keys
key_loop:
	; check key pressed
		ld a, (hl)
		push bc	; preserve b (counter)
		call TestKey
		pop bc	; restore b (counter)
		jp c,skip_key
		ld a,d	; put control vals in A
		or e	; or in bitmask
		ld d,a	; put back in d
	skip_key:	
		sla e	; shift bitmask left
		inc hl	; incrmement key pointer
		djnz key_loop

	ld (gControlCurVal),a	; put result in variable
	ret
	
; Update the control values
UpdateControls:
	ld a,0
	ld (gControlCurVal),a
	;call ReadKempston
	;call ReadKeys
ret
