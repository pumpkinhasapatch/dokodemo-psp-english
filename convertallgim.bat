@echo off
mkdir input\output
del /Q input\output\*.png

for /r "input\" %%A in (*.GIM) do (
    "GimConv\GimConv.exe" %%A -o "output\%%~nA.png"
)

del /Q input\*.*
