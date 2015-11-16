@echo off
cmd /c build.cmd || goto end2
rem objdump -D -b binary -mi386 -Maddr16,data16,intel R:\boios\boot.bin
objdump -D R:\boios\main.tmp
:end2