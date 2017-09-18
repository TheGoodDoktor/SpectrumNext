; Copied from Mike Daily's code 

                opt             sna=StartAddress:StackStart                             ; save SNA,Set PC = run point in SNA file and TOP of stack
                opt             Z80                                                     ; Set z80 mode
                opt             ZXNEXT                                                  ; enable zx next opcodes
               
StackEnd:
                ds      127
StackStart:     db      0

                org     $6100


StartAddress: