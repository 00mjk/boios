@echo off
taskkill /f /im qemu-system-x86_64.exe
cmd /c build.cmd || goto end2
start "vm" "G:\Program Files\qemu\qemu-system-x86_64.exe" -drive format=raw,media=cdrom,readonly,file=R:/boios/image.iso -soundhw pcspk
:end2