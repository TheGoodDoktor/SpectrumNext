; control code

; Current controller state
; bit mappings mimic kempston
; 0	- right
; 1 - left
; 2 - down
; 3 - up
; 4 - fire
control_cur_val db 0

; defined keys
control_key_right 	db 0
control_key_left 	db 0
control_key_down 	db 0
control_key_up 		db 0
control_key_fire 	db 0

; Read Kempston Joystick
; clobbers ABC
ReadKempston:

ld bc,31
in a,(c)
ld (control_cur_val),a	; store values out

ret

; ROM routine to return key pressed
rom_key_scan equ $028E

; Mr. Jones' keyboard test routine.
ktest:
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