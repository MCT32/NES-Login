..\tools\cc65\bin\ca65 main.s -g -o main.o
..\tools\cc65\bin\ld65 -o auth.nes -C linker.cfg main.o -m main.map.txt -Ln main.labels.txt --dbgfile auth.nes.dbg
pause
