@echo off

:: Doko Demo Issyo PSP English Translation Project - Windows build script
:: Copyright (C) 2024 PumpkinhasaPatch <https://github.com/pumpkinhasapatch>

:: This program is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 3 of the License, or
:: (at your option) any later version.

:: This program is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
:: GNU General Public License for more details.

:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <https://www.gnu.org/licenses/>.

title Doko Demo Issyo PSP Patcher

cls
echo Doko Demo Issyo PSP Patcher (Windows build script)
echo (c) PumpkinhasaPatch 2024
ver
echo.
echo Updates to this tool and more information available at:
echo https://github.com/pumpkinhasapatch/dokodemo-psp-english
echo.

echo Welcome to the Doko Demo Issyo PSP Patcher.
echo This tool will help you convert an original Japanese copy of 'Doko Demo Issyo Portable' into a modified language translation for use on your PSP, Vita or emulator.
echo.

echo Checking for game files...
if not exist build\PSP_GAME\USRDIR\data\DATA.BP (
    echo Please place the original game files inside the build folder.
    echo Extract your ISO to get the PSP_GAME folder and UMD_DATA.BIN.
    mkdir build > nul
    pause
    explorer %cd%\build
    goto End
)

echo Checking Windows Subsystem for Linux...
:: Try running a Linux command in WSL and see if theres an error
bash -c ""
if not ERRORLEVEL 0 (
    echo Please install a Windows Subsystem for Linux distribution.
    echo This is needed to run bpar, the game archive editing tool.
    pause
    start https://learn.microsoft.com/en-us/windows/wsl/install
    goto End
)

:: Download required tools from trusted external sources. It's better than hosting random executables in my code repository.
:: I have verified the code of each program, and linked files have to be changed here before new code will be downloaded by users.

:: curl -L to follow redirect links for some websites - https://4sysops.com/archives/how-to-use-curl-on-windows/#rtoc-4
if not exist tools\ mkdir tools
cd tools

if not exist GimConv\GimConv.exe (
    :: Sony freeware/proprietary GIM image conversion tool - http://endlessparadigm.com/forum/showthread.php?tid=5054
    curl -o GimConv.zip http://endlessparadigm.com/forum/attachment.php?aid=1008
    if not exist GimConv\ mkdir GimConv
    cd GimConv
    tar -xf ..\GimConv.zip
    cd ..
)

if not exist Atlas\Atlas.exe (
    :: Atlas script language text inserter, forked and updated on GitHub - https://www.romhacking.net/utilities/224
    curl -o Atlas.zip -L https://github.com/stevemonaco/Atlas/releases/download/v1.12/Atlas.v1.12.zip
    tar -xf Atlas.zip
)

copy /Y ..\GimConv.cfg GimConv\
cd ..

:: Add build date to a README file inside the game.
echo This game has been modified by the Doko Demo Issyo PSP Patcher^

https://github.com/pumpkinhasapatch/dokodemo-psp-english^

Patcher ran on %date% at %time% by %computername%> build/README.txt

:: Use bpar to extract the original KSC files from DATA.BP
if not exist "extract\NEKO.KSC" (
    echo Starting bpar extract
    bash -c "./bpm-extract.sh"
)

del /S /Q insert
mkdir insert
copy /Y extract\*.KSC insert
copy /Y extract\*.DIC insert

:: Apply Atlas text patches to BOOT.BIN and .KSC files
echo Patch game files
tools\Atlas\Atlas.exe build\PSP_GAME\SYSDIR\BOOT.BIN patches\boot.txt > nul
tools\Atlas\Atlas.exe build\PSP_GAME\PARAM.SFO patches\param.txt > nul

:: Replace game artwork that appears on the XMB/PPSSPP menu
copy /Y ICON0.png build\PSP_GAME\ICON0.PNG
copy /Y PIC0.png build\PSP_GAME\PIC0.PNG

:: Remove the encrypted EBOOT.BIN so the game loads our modified BOOT.BIN
if exist build\PSP_GAME\SYSDIR\EBOOT.BIN del build\PSP_GAME\SYSDIR\EBOOT.BIN

echo Patch Pokepi text
:: The internal .KSC filenames are the type of animal in Japanese
:: TODO: This is a mess, maybe rewrite it using filename variables and a for loop?
if exist patches\toro_messages.txt tools\Atlas\Atlas.exe insert\NEKO.KSC patches\toro_messages.txt
if exist patches\toro_dialogue.txt tools\Atlas\Atlas.exe insert\NEKO.KSC patches\toro_dialogue.txt
if exist patches\suzuki_messages.txt tools\Atlas\Atlas.exe insert\ROBO.KSC patches\suzuki_messages.txt
if exist patches\suzuki_dialogue.txt tools\Atlas\Atlas.exe insert\ROBO.KSC patches\suzuki_dialogue.txt
if exist patches\jun_messages.txt tools\Atlas\Atlas.exe insert\USAGI.KSC patches\jun_messages.txt
if exist patches\jun_dialogue.txt tools\Atlas\Atlas.exe insert\USAGI.KSC patches\jun_dialogue.txt
if exist patches\pierre_messages.txt tools\Atlas\Atlas.exe insert\INU.KSC patches\pierre_messages.txt
if exist patches\pierre_dialogue.txt tools\Atlas\Atlas.exe insert\INU.KSC patches\pierre_dialogue.txt
if exist patches\ricky_messages.txt tools\Atlas\Atlas.exe insert\KAERU.KSC patches\ricky_messages.txt
if exist patches\ricky_dialogue.txt tools\Atlas\Atlas.exe insert\KAERU.KSC patches\ricky_dialogue.txt

:: GimConv all .png images in ./textures/ to .GIM (MIG.00.1PSP)
:: Use 16 bits-per-pixel with Alpha transparency for smaller size
for /R textures %%f in (*.png) do tools\GimConv\GimConv.exe %%f -o %%~nf.GIM

:: Insert modified .KSC text and .GIM image files back into DATA.BP
echo Starting bpar insert
bash -c "./bpm-insert.sh"

echo Patching finished. Have fun!
:: If PPSSPP is installed in the default folder, try to start the game
if exist "C:\Program Files\PPSSPP\PPSSPPWindows.exe" "C:\Program Files\PPSSPP\PPSSPPWindows.exe" "%cd%\build"

:End