@echo off
cls
setlocal enabledelayedexpansion

:: Doko Demo Issyo PSP English Translation Project - Windows build script
:: Copyright (C) 2024 PumpkinhasaPatch <https://github.com/pumpkinhasapatch>

set "baseDir=%~dp0"
:: Change to the directory where the batch file is stored
cd /d "%baseDir%"

:: Clear folder from previous builds
rmdir /S /Q build
mkdir build

set "sevenzip=tools\7-Zip\7z.exe"
set "atlas=tools\Atlas\Atlas.exe"
set "bpar=tools\bpar\bpar_cosmo.com"
set "gimconv=tools\GimConv\GimConv.exe"
set "pngquant=tools\pngquant\pngquant.exe"
set "databp=build\PSP_GAME\USRDIR\data\DATA.BP"

title Doko Demo Issyo PSP Patcher

echo Doko Demo Issyo PSP Patcher (Windows build script)
echo (c) PumpkinhasaPatch 2024
ver
echo.
echo Updates to this tool and more information available at:
echo https://github.com/pumpkinhasapatch/dokodemo-psp-english
echo.

:: MD5 hash from an original Doko Demo Issyo PSP ISO http://redump.org/disc/39834/
set expectedhash=a7d8ff8050ac0d1fd6b0d5970eecbd8d

:: Locate ISO and verify checksum
set "gameiso="
for %%f in ("*.iso") do (
    echo Checking %%f...
    for /f %%h in ('certutil -hashfile "%%f" MD5 ^| find /i /v "certutil" ^| find /i /v "hash"') do set "filehash=%%h"
    echo !filehash!

    if "!expectedhash!"=="!filehash!" (
        echo Checksum is correct
        set "gameiso=%%f"
    )
    echo.
)

if "!gameiso!"=="" (
    if exist "*.iso" (
        echo An ISO file was found but the checksum is incorrect.
        echo You may have the wrong game or a modified ISO that was already run through the patcher.
        echo Make sure !file! is a original, unmodified copy of Doko Demo Issyo for PSP.
        echo Other games like Doko Demo Issyo: Rettsu Gakkou or Doko Demo Issyo for PS1 are not supported.
        echo.
        set /P "yn=Continue anyway? (may cause errors) [y/n] "
        if /i "!yn!" neq "y" goto End
        set "gameiso=!file!"
        echo.
    ) else (
        echo This build script requires an original, unmodified copy of Doko Demo Issyo for PSP.
        echo Place your game ISO in the project folder, then run the build script again.
        timeout /T 10
        explorer !cd!
        goto End
    )
)

:: Extract game ISO to build folder with 7-Zip
"!sevenzip!" x -o"build" "!gameiso!"

:: Write build date to game title
echo #SETTARGETFILE("build/PSP_GAME/PARAM.SFO")^

#VAR(Table, TABLE)^

#ADDTBL("shiftjis.tbl", Table)^

#ACTIVETBL(Table)^

#FIXEDLENGTH(128,0)^

#JMP($158)^

Doko Demo Issyo PSP English Fan Translation (build %date% %time:~0,5%)^<END^>>patches\param.txt

:: Apply Atlas text patches to BOOT.BIN and .KSC files
echo Patch game files
%atlas% build\PSP_GAME\SYSDIR\BOOT.BIN patches\boot.txt > nul
%atlas% build\PSP_GAME\PARAM.SFO patches\param.txt > nul

:: Replace game artwork that appears on the XMB/PPSSPP menu
copy ICON0.png build\PSP_GAME\ICON0.PNG
copy PIC0.png build\PSP_GAME\PIC0.PNG
:: Animated game icon made with PSMF Stream Composer Suite
copy ICON1.PMF build\PSP_GAME\ICON1.PMF

:: Replace EBOOT.BIN with BOOT.BIN so the game always loads our modified BOOT.BIN
copy /Y build\PSP_GAME\SYSDIR\BOOT.BIN build\PSP_GAME\SYSDIR\EBOOT.BIN

:: Use bpar to extract the original KSC files from DATA.BP
if not exist "extract" (
    mkdir "extract"
)
if not exist "extract\NEKO.KSC" (
    cd extract
    echo Extracting files from DATA.BP
    :: Extract BPM archives from DATA.BP - hide magic header warnings
    ..\%bpar% -x ..\%databp%>nul

    :: Extract KSC/DIC files from BPMs containing Pokepi text
    for %%f in (KS*.BPM) do (
        ..\%bpar% -x %%f
    )
    
    :: Clean up BPMs after extracting
    del "*.BPM"
    cd ..
)

del /S /Q insert
mkdir insert
copy /Y extract\*.KSC insert
copy /Y extract\*.DIC insert

echo Patch Pokepi text
:: The internal .KSC filenames are the type of animal in Japanese
:: TODO: This is a mess, maybe rewrite it using filename variables and a for loop?
set "pokepi_names=toro suzuki jun pierre ricky"
set "internal_names=NEKO ROBO USAGI INU KAERU"

rem build indexed arrays
set idx=0
for %%A in (%pokepi_names%) do (
  set /A idx+=1
  set "poke[!idx!]=%%A"
)
set max=%idx%

set idx=0
for %%B in (%internal_names%) do (
  set /A idx+=1
  set "int[!idx!]=%%B"
)
set max2=%idx%

if not "%max%"=="%max2%" (
  echo Error: name lists have different lengths (%max% vs %max2%) & exit /b 1
)

rem iterate by index and pair poke[i] with int[i]
for /L %%i in (1,1,%max%) do (
  set "p=!poke[%%i]!"
  set "q=!int[%%i]!"

  if exist "patches\!p!.xlsx" (
    echo Converting spreadsheet !p!.xlsx to !p!_excel.txt
    python excel_to_atlas.py "patches\!p!.xlsx" "patches\!p!_excel.txt"
    !atlas! insert\!q!.KSC "patches\!p!_excel.txt"
  )
  if exist "patches\!p!_messages.txt" (
    echo Patching !q!.KSC with !p!_messages.txt
    !atlas! insert\!q!.KSC "patches\!p!_messages.txt"
  )
  if exist "patches\!p!_diary.txt" (
    echo Patching !q!.KSC with !p!_diary.txt
    !atlas! insert\!q!.KSC "patches\!p!_diary.txt"
  )
  if exist "patches\!p!_dialogue.txt" (
    echo Patching !q!.KSC with !p!_dialogue.txt
    !atlas! insert\!q!.KSC "patches\!p!_dialogue.txt"
  )
  if exist "patches\!p!_dictionary.txt" (
    echo Patching !q!.DIC with !p!_dictionary.txt
    !atlas! insert\!q!.DIC "patches\!p!_dictionary.txt"
  )
)

:: TODO: Add USAGI, INU, KAERU, ROBO and DIC files
:: Use a list so we don't have to repeat so much code
echo Inserting text files...
cd insert
for %%f in (*) do (
    echo Inserting "%%f"...
    ..\%bpar% id ..\%databp% %%~nxf
    :: "Archive corrupt" error
    if errorlevel 2 (
        echo Failed to inject file
        pause
        goto End
    )
)
cd ..

:: Delete converted image files
del /S /Q textures\*.GIM>nul
del /S /Q textures\*-fs8.png>nul
del textures\md5.txt

echo Converting .png textures to .GIM format
for /R textures %%f in (*.png) do (
    rem Remove the base directory part from the full path to get the relative path
    set "relPath=%%f"
    set "relPath=.!relPath:%cd%\textures=!"
    for /f %%h in ('certutil -hashfile "%%f" MD5 ^| find /i /v "certutil" ^| find /i /v "hash"') do set "filehash=%%h"
    echo hashed file !relPath! !filehash!
    echo !relPath! !filehash!>>textures\md5.txt

    rem Use pngquant to convert all images to 8-bit alpha
    rem Use option -bpp4 -N to save all GIMs with image_format = index4 and pixel_order = normal
    "%pngquant%" 16 "%%f"
    "%gimconv%" "%%~dpnf-fs8.png" -o "%%~nf.GIM" -bpp4 -N
)

:: Insert modified .GIM image files back into DATA.BP
echo Inserting GIM textures...
cd textures
for /R %%f in (*.GIM) do (
    rem Remove the base directory part from the full path to get the relative path
    set "relPath=%%f"
    set "relPath=.!relPath:%cd%=!"
    echo Inserting "!relPath!"...
    ..\%bpar% id "..\%databp%" "!relPath!"
    rem "Archive corrupt" error
    if errorlevel 2 (
        echo Failed to inject file
        pause
        goto End
    )
)
cd ..

:: Delete converted image files
del /S /Q textures\*.GIM>nul
del /S /Q textures\*-fs8.png>nul

echo Patching finished. Have fun!
:: If PPSSPP is installed in the default folder, try to start the game
if exist "C:\Program Files\PPSSPP\PPSSPPWindows.exe" "C:\Program Files\PPSSPP\PPSSPPWindows.exe" "%cd%\build"

:End
endlocal
exit /b
