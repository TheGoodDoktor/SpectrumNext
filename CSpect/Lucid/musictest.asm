
InitMusic

	call MusicdrvInit
	call InitInterrupts
ret

MusicdrvInit 	EQU 49152
MusicdrvUpdate 	EQU 49335

include "interrupts.asm"

org 49152
incbin "Ama_0_1.bin"