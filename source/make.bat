@echo off
ca65.exe %1
ld65.exe -C sbc.cfg %~d1%~p1%~n1.o