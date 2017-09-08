CSpect V0.9 ZXSpectrum emulator by Mike Dailly
(c)1998-2017 All rights reserved

Be aware...emulator is far from well tested, might crash for any reason!


Whats new
======================================================================================
V0.9
----
register 20 ($14) Global transparancy colour added (defaults to $e3)
regisrer 7 Turbo mode selection implemented. 
Fixed 28Mhz to 14,7,3.5 transition. 
ULANext mode updated to new spec  (see https://www.specnext.com/tbblue-io-port-system/)
LDIRSCALE added
LDPIRX added


V0.8
----
New Lowres layer support added (details below)
ULANext palette support added (details below)
TEST $XX opcode fixed



V0.7
----
port $0057 and  $005b are now $xx57 and $xx5b, as per the hardware
Fixed some sprite rotation and flipping
Can now save via RST $08  (see layer 2 demo)
Some additions to SNasm (savebin, savesna, can now use : to seperate asm lines etc)


V0.6
----
Swapped HLDE to DEHL to aid C compilers
ACC32 changed to A32
TEST $00 added


V0.5
----
Added in lots more new Z80 opcodes (see below)
128 SNA snapshots can now be loaded properly
Shadow screen (held in bank 7) can now be used


V0.4
----
New debugger!!!  F1 will enter/exit the debugger
Sprite shape port has changed (as per spec) from  $55 to $5B
Loading files from RST $08 require the drive to be set (or gotten) properly - as per actual machines. 
  RST $08/$89 will return the drive needed. 
  Please see the example filesystem.asm for this.
  You can also pass in '*' or '$' to set the current drive to be system or default
Basic Audio now added (beeper)
New sprite priorities using register 21. Bits 4,3,2
New Layer 2 double buffering via Reg 18,Reg 19 and bit 3 of port $123b



New Z80 opcodes on the NEXT (more to come)
======================================================================================
   swapnib           ED 23           A bits 7-4 swap with A bits 3-0
   mul               ED 30           multiply HL*DE = HLDE (no flags set)
   add  hl,a         ED 31           Add A to HL (no flags set)
   add  de,a         ED 32           Add A to DE (no flags set)
   add  bc,a         ED 33           Add A to BC (no flags set)
   add  hl,$0000     ED 34 LO HI     Add A to HL (no flags set)
   add  de,$0000     ED 35 LO HI     Add A to DE (no flags set)
   add  bc,$0000     ED 36 LO HI     Add A to BC (no flags set)
   outinb            ED 90           out (c),(hl), hl++
   ldix              ED A4           As LDI,  but if byte==A does not copy
   ldirx             ED B4           As LDIR, but if byte==A does not copy
   lddx              ED AC           As LDD,  but if byte==A does not copy, and DE is incremented
   lddrx             ED BC           As LDDR,  but if byte==A does not copy
   ldirscale         ED B6           As LDIRX,  if(hl)!=A then (de)=(hl); HL_E'+=BC'; DE+=DE'; dec BC; Loop.
   ldpirx            ED B7           (de) = ( (hl&$fff8)+(E&7) ) when != A
   fillde            ED B5           Using A fill from DE for BC bytes
   ld  hl,sp         ED 25           transfer SP to HL
   ld  a32,dehl      ED 20           transfer DEHL into A32
   ld  dehl,a32      ED 21           transfer A32 into DEHL
   ex  a32,dehl      ED 22           swap A32 with DEHL
   inc dehl          ED 37           increment 32bit DEHL
   dec dehl          ED 38           increment 32bit DEHL
   add dehl,a        ED 39           Add A to 32bit DEHL
   add dehl,bc       ED 3A           Add BC to 32bit DEHL
   add dehl,$0000    ED 3B LO HI     Add $0000 to 32bit DEHL
   sub dehl,a        ED 3C           Subtract A from 32bit DEHL
   sub dehl,bc       ED 3D           Subtract BC from 32bit DEHL
   mirror a          ED 24           mirror the bits in A     
   mirror de         ED 26           mirror the bits in DE     
   push $0000        ED 8A LO HI     push 16bit immidiate value
   popx              ED 8B           pop value and disguard
   nextreg reg,val   ED 91 reg,val   Set a NEXT register (like doing out($243b),reg then out($253b),val )
   nextreg reg,a     ED 92 reg       Set a NEXT register using A (like doing out($243b),reg then out($253b),A )
   pixeldn           ED 93           Move down a line on the ULA screen
   pixelad           ED 94           using D,E (as Y,X) calculate the ULA screen address and store in HL
   setae             ED 95           Using the lower 3 bits of E (X coordinate), set the correct bit value in A
   test $00          ED 27           And A with $XX and set all flags. A is not affected.



Command line
======================================================================================
-zxnext            =  enable Next hardware registers
-zx128             =  enable ZX Spectrum 128 mode
-s7                =  enable 7Mhz mode
-s14               =  enable 14Mhz mode
-s28               =  enable 28Mhz mode
-mmc=<dir>\        = enable RST $08 usage, must provide path to "root" dir of emulated SD card (eg  "-mmc=.\" or "-mmc="c:\test\")
-map=<path\file>   = SNASM format map file for use in the debugger. Local labels in the format "<primary>@<local>".





General Emulator Keys
======================================================================================
Escape - quit
F1 - Enter/Exit debugger
F2 - load SNA
F3 - reset
F5 - 3.5Mhz mode  	(when not in debugger)
F6 - 7Mhz mode		(when not in debugger)
F7 - 14Mhz mode		(when not in debugger)
F8 - 28Mhz mode		(when not in debugger)





Debugger Keys
======================================================================================
F1             - Exit debugger
F2             - load SNA
F3             - reset
F7             - single step
F8             - Step over (for loops calls etc)
F9             - toggle breakpoint on current line
Up             - move user bar up
Down           - move user bar down
PageUp         - Page disassembly window up
PageDown       - Page disassembly window down
SHIFT+Up       - move memory window up 16 bytes
SHIFT+Down     - move memory window down 16 bytes
SHIFT+PageUp   - Page memory window up
SHIFT+PageDown - Page memory window down

Mouse is used to toggle "switches"
HEX/DEC mode can be toggled via "switches"




Debugger Commands
======================================================================================
M <address>   Set memory window base address
BR <address>  Toggle Breakpoint
PUSH <value>  push a 16 bit value onto the stack
POP           pop the top of the stack
Registers:
   A  <value>    Set the A register
   A' <value>    Set alternate A register
   F  <value>    Set the Flags register
   F' <value>    Set alternate Flags register
   AF <value>    Set 16bit register pair value
   AF'<value>    Set 16bit register pair value
   |
   | same for all others
   |
   SP <value>    Set the stack register
   PC <value>    Set alternate program counter register




Whats working?!??!
======================================================================================
Raster line reporting via registers 30/31. No raster interrupts currently (soon)

Sprite rotate, flip and mirror working as per documented, no palettes yet
https://www.specnext.com/tbblue-io-port-system/
https://www.specnext.com/sprites/

LowRes mode (codename RadasJim)
ULANext mode
Layer 2 currently working, but be aware access/format subject to change!!!



LowRes mode
======================================================================================
Register 21 ($15) bit 7 enables the new mode. Layer priorities work as normal.
Register 50 ($32) Lowres X scroll (0-255) auto wraps
Register 51 ($32) Lowres Y scroll (0-191) auto wraps

Can not use shadow screen. Setting the shadow screen bit will switch to the standard ULA screen.
Screen is 128x96 byte-per-pixels in size. 
Top half  : 128x48 located at $4000 to $5800
Lower half: 128x48 located at $6000 to $6800


XScroll: 0-255
Being only 128 pixels in resolution, this allows the display to scroll in half pixels, at the same resolution and smoothness as Layer 2.

YScroll: 0-191
Being only 96 pixels in resolution, this allows the display to scroll in half pixels, at the same resolution and smoothness as Layer 2.




ULANext mode
======================================================================================
(W) 0x40 (64) => Palette Index
  bits 7-0 = Select the palette index to change the default colour. 
  0 to 127 indexes are to ink colours and 128 to 255 index are to papers.
  (Except full ink colour mode, that all values 0 to 255 are inks)
  Border colours are the same as paper 0 to 7, positions 128 to 135,
  even at full ink mode. 

(W) 0x41 (65) => Palette Value
  bits 7-0 = Colour for the palette index selected by the register 0x40. Format is RRRGGGBB
  After the write, the palette index is auto-incremented to the next index. 
  The changed palette remains until a Hard Reset.

(W) 0x42 (66) => Palette Format
  bits 7-0 = Number of the last ink colour entry on palette. (Reset to 15 after a Reset)
  This number can be 1, 3, 7, 15, 31, 63, 127 or 255.
  The 255 value enables the full ink colour mode and 
  all the the palette entries are inks with black paper.

(W) 0x43 (67) => Palette Control
  bits 7-1 = Reserved, must be 0
  bit 0 = Disable the standard Spectrum flash feature to enable the extra colours.

Without Palette Control bit 0 set.
Palette[0-15] = INK colours  				(0-7 normal, 8-15 =BRIGHT)
Palette[128-143] = Paper + Border colours		(0-7 normal, 8-15 =BRIGHT)


WITH Palette Control bit 0 set
Attribute byte swaps to paper/ink selection only. 
Palette Format specifies the number of colours INK will use. default is 15, so attribute if PPPPIIII
1  = PPPPPPPI
3  = PPPPPPII
7  = PPPPPIII
15 = PPPPIIII
31 = PPPIIIII
63 = PPIIIIII
127= PIIIIIII
255= IIIIIIII
Note if mode is 255, then Paper colour is 0 (in paper range, palette index 128)
Border colours always come from paper banks, palette index 128-135



Layer 2 access
======================================================================================
Register 18 = 	bank of Layer 2 front buffer
Register 19 = 	bank of Layer 2 back buffer 
Register 21 = 	sprite system.  
		bits 4,3,2 = layer order  
		000   S L U		 (sprites on top)
		001   L S U
		010   S U L
		011   L U S
		100   U S L
		101   U L S
Register $20	; Layer 2 transparency color working

port $123b
bit 0 = WRITE paging on. $0000-$3fff write access goes to selected Layer 2 page 
bit 1 = Layer 2 ON (visible)
bit 3 = Page in back buffer (reg 19)
bit 6/7= VRAM Banking selection (layer 2 uses 3 banks) (0,$40 and $c0 only)


Layer 2 xscroll
===================
ld      bc, $243B		; select the X scroll register
ld      a,22
out     (c),a
ld	a,<scrollvalue>		; 0 to 255
ld      bc, $253B
out     (c),a

Layer 2 yscroll
===================
ld      bc, $243B		; select the Y scroll register
ld      a,23
out     (c),a
ld	a,<scrollvalue>		; 0 to 191
ld      bc, $253B
out     (c),a

Layer 2: $E3	; bright magenta acts as transparent


Kempston mouse  (to be verified)
==============
Buttons  $fadf
Mouse X  $fddf    (0 to 255) *** to be verified ***
Mouse Y  $ffdf    (0 to 191) *** to be verified ***


esxDOS simulation
===================
M_GETSETDRV	-	simulated
F_OPEN		-	read mode only simulated	
F_READ		-	simulated
F_CLOSE		-	simulated
F_SEEK          -       simulated



