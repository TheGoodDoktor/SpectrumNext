UDGeedNext 0.2.3
--------------

0.2.3 - 04.06.17

fixes 

- doesnt double up the file extension 
- remove sprite / clear sprite shows warning

added

- ability to export sprites as asm data

inital Released 03.06.17

Written by David Saphier, david.saphier@gmail.com
More info zxbasic.uk/tools (does not yet exist ;)
and at http://www.specnext.com/forum/

This is a simple tool that allows you to edit the SPR files that are used on the 
ZX Spectrum Next in the current spec. 

A SPR file contains sprites (max 64). Each sprite is 256 bytes in length and are store consecutively in the SPR file. 

Each pixel is a pointer to the RRRGGGBB palette with 255,0,255 being transparent. Max SPR size is 16383. 

Usage :
-------

There is a editor area and a palette area

Editor :

Click left to place a pixel, right to remove. 
Clear to Trans will clear all sprites to the transparent colour
Clear Sprite will clear all sprites to white
Show/Hide T will toggle the transparent colour on the editor for visibility

Export Sprite - saves the current sprite to current directory as "sprite.spr"
Load Sprite Sheet - Loads either a single or multi sprites store in the SPR file
Save All Sprites - will save all sprites to a SPR file

<< - Navigate back a sprite
>> - Navigate forward a sprite
Remove Sprite - Decreases the number of sprites
Add Sprite - Increases the number of sprites

The pink colour with a T is the transparent colour. 

The Basic Code panel is still a WIP - and the numbers down the side of the editor will be for future colour swabs.

bugs/improvements/suggestions welcome.

Thanks

 



