Подготовительный этап.

На сервере CORE
Выполнить команду в powershell 
Set-ExecutionPolicy Unrestricted

Скопировать на сервер CORE скрипт scriptCORE.ps1 
который разрешит удаленное управление сервером, переименует сервер, 
пропишет IP адреса, сменит пароль локальному администратору, перезагрузит сервер.



Основной этап.
На сервере GUI
Выполнить команду в powershell 
Set-ExecutionPolicy Unrestricted

Выполнить скрипт scriptGUI.ps1
