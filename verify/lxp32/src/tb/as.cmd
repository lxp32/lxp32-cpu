@echo off
for  %%i in (..\firmware\test*.asm) do lxp32asm -f textio -o .\%%~ni.ram ..\firmware\%%~ni.asm
 

