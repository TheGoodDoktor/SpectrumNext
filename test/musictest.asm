
InitMusic

	call musicdrv_init
	call InitInterrupts
ret

musicdrv_init EQU 49152
musicdrv_update EQU 49335

include "interrupts.asm"

org 49152
incbin "Ama_0_1.bin"