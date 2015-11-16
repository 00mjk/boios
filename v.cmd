@echo off
taskkill /f /im virtualbox.exe
cmd /c build.cmd || goto end2
start "vm" "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm "boios" --type gui
rem -E VBOX_GUI_DBG_ENABLED=true -E VBOX_GUI_DBG_AUTO_SHOW=true
:end2