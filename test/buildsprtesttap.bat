set assembler=..\pasmo\pasmo.exe
set input=spritetest.asm
set output=spritetest.tap

%assembler% --tapbas -I ..\common -d %input% %output%

pause
