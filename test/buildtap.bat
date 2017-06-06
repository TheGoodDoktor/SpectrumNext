set assembler=..\pasmo\pasmo.exe
set input=hello.asm
set output=hello.tap

%assembler% --tapbas -I ..\common -d %input% %output%

pause
