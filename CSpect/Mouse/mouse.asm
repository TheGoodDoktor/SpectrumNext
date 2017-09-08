;
; Created on Sunday, 11 of June 2017 at 09:43 AM
;
; ZX Spectrum Next Framework V0.1 by Mike Dailly, 2017
;
; 
                opt             sna=StartAddress:StackStart                             ; save SNA,Set PC = run point in SNA file and TOP of stack
                opt             Z80                                                                             ; Set z80 mode
                opt             ZXNEXT
                
                include "includes.asm"


                ; IRQ is at $5c5c to 5e01
                include "irq.asm"       
               
StackEnd:
                ds      127
StackStart:     db      0

                org     $6100


StartAddress:
                di
                ld      a,VectorTable>>8
                ld      i,a                     
                im      2                       ; Setup IM2 mode
                ei
                ld      a,0
                out     ($fe),a

                call    Cls
                ld      a,7
                call    ClsATTR

                call    InitFilesystem
                

;
;       Main loop
;               
MainLoop:
                halt                            ; wait for vblanks (need to do Raster IRQs at some point)

                
                ; timing bar
                ld      a,(col)
                out     ($fe),a
                inc     a
                and     7
                ld      (col),a

                call    ReadMouse
                ld      a,(MouseX)
                ld      de,$4000
                call    PrintHex
                ld      a,(MouseY)
                ld      de,$4003
                call    PrintHex



                ; timing bar off
                ;ld      a,0
                ;out     ($fe),a

                jp      MainLoop                ; infinite loop

col             db      0


; *****************************************************************************************************************************
; includes modules
; *****************************************************************************************************************************
                include "Utils.asm"
                include "filesys.asm"


; *****************************************************************************************************************************
; File directory.....
; *****************************************************************************************************************************
SpriteFile      ;File    "game/minecraf.spr"


                ; wheres our end address?
                message "End of code =",PC
        



