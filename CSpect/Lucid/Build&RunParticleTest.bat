..\snasm -map particletest.asm particletest.sna
if ERRORLEVEL 1 goto doexit

rem simple 48k model
..\CSpect.exe -s14 -map=particletest.sna.map -zxnext -mmc=.\ particletest.sna

:doexit
pause