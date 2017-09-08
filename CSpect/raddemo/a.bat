..\snasm -map layer2.asm layer2.sna
if ERRORLEVEL 1 goto doexit

rem simple 48k model
..\CSpect.exe -s14 -map=layer2.sna.map -zxnext -mmc=.\ layer2.sna

:doexit