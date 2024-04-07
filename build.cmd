@echo off && rem setlocal enabledelayedexpansion

::if "!_log!/" == "/" (
::     set "_log=%cd%\log.txt" 
::     2>&1 call "%~f0" >>"!_log!" & exit /b
::    )else endlocal

title Doko Demo Issyo PSP Patcher

:: Fixes the use or display of Unicode UTF-8 characters with some commands
:: https://ss64.com/nt/chcp.html
chcp 65001

cls
echo Doko Demo Issyo PSP Patcher v1.0
echo (c) PumpkinhasaPatch 2024
ver
echo.
echo Updates to this tool and more information avaliable at:
echo https://GitHub.com/PumpkinhasaPatch/DokoDemo-PSP-Patcher
echo.

echo Welcome to the Doko Demo Issyo PSP Patcher.
echo This tool will help you convert an original Japanese copy of 'Doko Demo Issyo Portable' into a modified language translation for use on your PSP, Vita or emulator.
echo.

:: Try running a Linux command in WSL and see if theres an error
bash -c ""
if not ERRORLEVEL 0 (
    echo Please install a Windows Subsystem for Linux distribution.
    echo This is needed to run bpar, the game archive editing tool.
    pause
    start https://learn.microsoft.com/en-us/windows/wsl/install
    goto End
)

if not exist build\PSP_GAME\USRDIR\data\DATA.BP (
    echo Please place the original game files inside the build folder.
    echo Extract your ISO to get the PSP_GAME folder and UMD_DATA.BIN.
    mkdir build > nul
    pause
    explorer %cd%\build
    goto End
)

:: Download required tools from trusted external sources. It's better than hosting random executables in my code repository.
:: I have verified the code of each program, and linked files have to be changed here before new code will be downloaded by users.

:: curl -L to follow redirect links for some websites - https://4sysops.com/archives/how-to-use-curl-on-windows/#rtoc-4


    mkdir tools
    cd tools

    rem Sony freeware/proprietary GIM image conversion tool - http://endlessparadigm.com/forum/showthread.php?tid=5054
    curl -o GimConv.zip http://endlessparadigm.com/forum/attachment.php?aid=1008
    tar -xf GimConv.zip
    echo %errorlevel% & rem 0 if extracted successfully, 1 if failed or invalid archive data. TODO: Make an if here

    rem Atlas script language text inserter, forked and updated on GitHub - https://www.romhacking.net/utilities/224
    curl -o Atlas.zip -L https://github.com/esperknight/Atlas/releases/download/04242021/Atlas_04_24_2021.zip
    tar -xf Atlas.zip
    echo %errorlevel%

    rem Zenity Go port for Windows to show pretty menus and file select - https://help.gnome.org/users/zenity/stable
    curl -o zenity.zip -L https://github.com/ncruces/zenity/releases/download/v0.10.12/zenity_win32.zip
    tar -xf zenity.zip
    echo %errorlevel%
    cd ..


copy /Y bpar.c tools
copy /Y bpar tools
copy /Y GimConv.cfg tools

:: Add build date to BOOT.BIN Atlas script (appears when exiting to title screen)
echo This game has been modified by the Doko Demo Issyo PSP Patcher^

https://GitHub.com/PumpkinhasaPatch/DokoDemo-PSP-Patcher^

Patcher ran on %date% at %time% by %computername%> build/README.txt

:: Use bpar to extract the original KSC files from DATA.BP
if not exist "extract" (
    echo Starting bpar extract
    bash -c "./bpm-extract.sh"
)

del /S /Q insert
mkdir insert
copy extract\*.KSC insert
copy extract\*.DIC insert

:: Apply Atlas text patches to BOOT.BIN and .KSC files
echo Patch game files
tools\Atlas.exe build\PSP_GAME\SYSDIR\BOOT.BIN patches\boot.txt > nul
tools\Atlas.exe build\PSP_GAME\PARAM.SFO patches\param.txt > nul
copy patches\ICON0.png build\PSP_GAME\

:: Remove the encrypted EBOOT.BIN so the game loads our modified BOOT.BIN
if exist build\PSP_GAME\SYSDIR\EBOOT.BIN del build\PSP_GAME\SYSDIR\EBOOT.BIN

echo Patch Pokepi text
:: The internal .KSC filenames are the type of animal in Japanese
tools\Atlas.exe insert\NEKO.KSC patches\toro_messages.txt
tools\Atlas.exe insert\NEKO.KSC patches\toro_dialogue.txt
::tools\Atlas.exe insert\ROBO.KSC patches\suzuki_messages.txt
::tools\Atlas.exe insert\ROBO.KSC patches\suzuki_dialogue.txt
::tools\Atlas.exe insert\USAGI.KSC patches\jun_messages.txt
::tools\Atlas.exe insert\USAGI.KSC patches\jun_dialogue.txt
::tools\Atlas.exe insert\INU.KSC patches\pierre_messages.txt
::tools\Atlas.exe insert\INU.KSC patches\pierre_dialogue.txt
::tools\Atlas.exe insert\KAERU.KSC patches\ricky_messages.txt
::tools\Atlas.exe insert\KAERU.KSC patches\ricky_dialogue.txt

:: GimConv all .png images in ./textures/ to .GIM (MIG.00.1PSP)
:: Use 16 bits-per-pixel with Alpha transparency for smaller size
for /R textures %%f in (*.png) do tools\GimConv.exe %%f -o %%~nf.GIM

:: Clear checksum table
echo.> checksums.csv

set "filepath=build\PSP_GAME\USRDIR\data\DATA.BP"
:: Find the checksum of USRDIR/data/DATA.BP
certutil -hashfile %filepath% MD5 & rem store in checksum variable

:: TODO: If DATA.BP has changed at all since the last build,
:: clear the checksum table and reinsert everything.

:: Get the checksum of each KSC and GIM
::certutil -hashfile %filepath% MD5 & rem store in checksum variable
:: TODO: Only try to insert files that have changed to
:: save time when building over and over and
:: only making small changes to the patch files.

:: Use two >> to add as a new line instead of replacing the whole file
:: %filepath%%tab%%checksum%>> filecache.tsv
:: build/PSP_GAME/USRDIR/data/DATA.BP   0123456789abcdef


:: Insert modified .KSC text and .GIM image files back into DATA.BP
echo Starting bpar insert
bash -c "./bpm-insert.sh"

echo Patching finished. Have fun!
:: If PPSSPP is detected, start the game
:: "C:\Program Files\PPSSPP\PPSSPPWindows.exe"
%userprofile%\Documents\Portable\ppsspp_win\PPSSPPWindows64.exe "%cd%\build"

:End