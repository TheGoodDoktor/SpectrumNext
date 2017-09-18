..\snasm -map maptest.asm maptest.sna
if ERRORLEVEL 1 goto doexit

rem simple 48k model
..\CSpect.exe -s14 -map=maptest.sna.map -zxnext -mmc=.\ maptest.sna

:doexit
pause