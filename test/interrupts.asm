
; Function to Initialise interrupts
InitInterrupts:
	di
	ld a,$FE
	ld i,a
	im 2
	ei
ret

; interrupt service routine
org $E8E8
InterruptRoutine:
	push af
	push bc
	push hl
	push de
	push ix
	; call music?
	call MusicdrvUpdate
	rst 56	; ROM routine to read keys etc.
	pop ix
	pop de
	pop hl
	pop bc
	pop af
	ei	; re-enable interrrupts
	reti	
	ret	; not sure why this is here - was in example

; interrupt pointer table
org $FE00
REPT 257
db $E8
ENDM
