@echo off
:: Fixes the use of Unicode UTF-8 characters with some commands
:: https://ss64.com/nt/chcp.html
chcp 65001 > nul

title Doko Demo Issyo PSP Patcher

echo Doko Demo Issyo PSP Patcher v1.0
echo (c) PumpkinhasaPatch 2024
ver
echo.
echo Updates to this tool and more information avaliable at:
echo https://GitHub.com/PumpkinhasaPatch/DokoDemo-PSP-Patcher
echo.
certutil -hashfile Atlas.exe MD5
certutil -hashfile zenity.exe MD5

if NOT exist zenity.exe echo Could not find zenity.exe && goto Error

:: Default values
set pokepi_state=1
set pokepi_box=[X]

set system_state=1
set system_box=[X]

set numpad_state=0
set numpad_box=[-]

:: Make sure to keep "" around values if they contain spaces or CMD will get very confused
set "pokepi_label=Replace Pokepi character dialogue"
set "system_label=Replace menu and system messages"
set "numpad_label=Force English keypad word input"
set "editor_label=Edit Atlas game translation scripts"
set "start_label=Start patching the game files!"

echo Launched Zenity dialog window
echo.

zenity --info --window-icon icons\info.png ^
--text="Welcome to the Doko Demo Issyo PSP Patcher. This tool will help you convert an original Japanese copy of 'Doko Demo Issyo Portable' into a modified language translation for use on your PSP, Vita or emulator."

:SelectMenu
set "selected=1 none"
FOR /F "usebackq delims==" %%i IN (`zenity --list --window-icon icons\list.png ^
 --title="Choose game features to include" ^
 --text="Select an option and click OK to change it." ^
 "%pokepi_box% %pokepi_label%" ^
 "%system_box% %system_label%" ^
 "%numpad_box% %numpad_label%" ^
 "%editor_label%" ^
 "%start_label%"`) DO set "selected=%errorlevel% %%i"

set "windowlevel=%selected:~0,1%"
set "selected=%selected:~2%"

echo %selected%

if %windowlevel%==1 goto End
if "%selected%"=="none" goto NothingSelected
if "%selected%"=="%pokepi_box% %pokepi_label%" goto TogglePokepi
if "%selected%"=="%system_box% %system_label%" goto ToggleSystem
if "%selected%"=="%numpad_box% %numpad_label%" goto ToggleNumpad
if "%selected%"=="%editor_label%" goto StartEditor
if "%selected%"=="%start_label%" goto StartPatching

echo Unknown option selected in features list
::goto Error
goto SelectMenu

:NothingSelected
zenity --info --window-icon icons\info.png --text="Please select an option from the list to change it, then click OK."
goto SelectMenu

:TogglePokepi
IF %pokepi_state%==1 (
set pokepi_state=0
set pokepi_box=[-]
) ELSE (
set pokepi_state=1
set pokepi_box=[X]
)
goto SelectMenu

:ToggleSystem
IF %system_state%==1 (
set system_state=0
set system_box=[-]
) ELSE (
set system_state=1
set system_box=[X]
)
goto SelectMenu

:ToggleNumpad
IF %numpad_state%==1 (
set numpad_state=0
set numpad_box=[-]
) ELSE (
set numpad_state=1
set numpad_box=[X]
)
goto SelectMenu


:StartEditor
:: Scans the Atlas file and removes blank lines, //comments and #commands, and outputs only the actual text.
:: Based on https://stackoverflow.com/a/64399861
findstr /V /N "^$" "patches\data_script_000.txt" | findstr /V "^[0-9]*://" | findstr /V "^[0-9]*:#"

pause
goto SelectMenu

:StartPatching

zenity --info  --window-icon icons\info.png ^
--text="You need an original Japanese copy of Doko Demo Issyo (どこでもいっしょ) for PSP to apply the translation. Search the internet for how to get it onto your computer, or select an option below when you're ready."

set "psphelp_label=I have a real PSP and Doko Demo UMD disc"
set "patchiso_label=Game disc ISO file saved to my computer"
set "folder_label=Folder with UMD_DATA.BIN and other files"

set "selected=1 none"
FOR /F "usebackq delims==" %%i IN (`zenity --list --window-icon icons\list.png --width=500 ^
 --title="Find your Doko Demo Issyo game" ^
 --text="Where is your copy of Doko Demo Issyo?" ^
 "%psphelp_label%" ^
 "%patchiso_label%" ^
 "%folder_label%"`) DO set "selected=%errorlevel% %%i"

set "windowlevel=%selected:~0,1%"
set "selected=%selected:~2%"

echo %selected%

if %windowlevel%==1 goto SelectMenu

zenity --file-selection --window-icon icons\info.png --title="Select your original Doko Demo Issyo Portable game file"
if %errorlevel%==1 goto SelectMenu

:: certutil -hashfile input\PSP_GAME\SYSDIR\BOOT.BIN MD5
:: d9d313a164d722321f97e65df250c079

:: certutil -hashfile input\PSP_GAME\USRDIR\data\DATA.BP MD5
:: 34bf872bf53088add4bf3c51d9ce075c

zenity --question --window-icon icons\ask.png ^
--text="Are you sure you want to apply the selected [X] translation patches to the game and start the build process?"
if %errorlevel%==1 goto SelectMenu

::Put atlas patching stuff and progress bar here
zenity --info --window-icon icons\info.png ^
--text="Not implemented yet lol"

if exist "C:\Program Files\PPSSPP\PPSSPPWindows.exe" goto SelectMenu

zenity --question --window-icon icons\ask.png ^
--text="Would you like to install the free PPSSPP emulator to play Doko Demo Issyo on your modern computer or smartphone? It is an open-source program that can run PSP games and home-made software very fast!"

if %errorlevel%==0 start https://ppsspp.org
goto SelectMenu

:Error
color c0
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo /!\ Oh no! Something has caused the program to stop working. /!\
echo.
echo Please check your files or download a new copy of the patcher from
echo https://GitHub.com/PumpkinhasaPatch/DokoDemo-PSP-Patcher
echo.
echo If you still see this error after repeating the same steps, please
echo create an Issue on our GitHub page. Hopefully we can help you. :)
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pause

:End
