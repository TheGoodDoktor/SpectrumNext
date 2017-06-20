set assembler=..\pasmo\pasmo.exe
set input=maptest.asm
set output=maptest.tap

%assembler% --tapbas -I ..\common -d %input% %output%

pause
