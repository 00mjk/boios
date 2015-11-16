@echo off
rm R:\boios\*.o
rm R:\boios\*.bin
rm R:\boios\image.iso
mkdir R:\boios\
copy image.iso R:\boios\image.iso
for %%x in (*.c) do gcc -std=gnu11 -ffreestanding -Wno-implicit-function-declaration -Wall -O3 -fstrength-reduce -fno-omit-frame-pointer -nostdinc -fno-builtin -c -o R:\boios\%%x.o %%x || goto end
fasm boot.asm R:\boios\boot.obj || goto end
ld -T NUL -o R:\boios\main.tmp --section-start .boot=0x7c00 -Ttext 0xf000 R:\boios\boot.obj R:\boios\*.o || goto end
objcopy -O binary R:\boios\main.tmp R:\boios\boot.bin || goto end
miso R:\boios\image.iso -py -a R:\boios\boot.bin || goto end
:end
exit /b %ERRORLEVEL%