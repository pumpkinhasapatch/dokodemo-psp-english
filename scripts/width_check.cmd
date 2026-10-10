@echo off
setlocal enabledelayedexpansion

rem Define the maximum width allowed
set "maxWidth=200"  rem Adjust this value as desired

rem Set input string
set "inputString=Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

rem Load character widths from external file
set "widths="
for /f "usebackq delims=" %%l in ("char_widths.txt") do (
    set "widths=!widths! %%l"
)

rem Initialize total width and last space index
set "totalWidth=0"
set "lastSpaceIndex=-1"

:processString
rem Process the input string
for /L %%i in (0,1,255) do (
    set "char=!inputString:~%%i,1!"
    if "!char!"=="" (
        goto endLoop
    )

    set "charWidth=1"  rem default width

    rem Get the character width from the loaded widths
    for %%j in (!widths!) do (
        for /f "tokens=1,2 delims==" %%a in ("%%j") do (
            if /I "!char!"=="%%a" (
                set "charWidth=%%b"
            )
        )
    )

    rem Add character width to total
    set /a totalWidth+=charWidth

    rem Track the last space index for replacement
    if "!char!"==" " (
        set "lastSpaceIndex=%%i"
    )

    rem Check if totalWidth exceeds maxWidth
    if !totalWidth! gtr %maxWidth% (
        if !lastSpaceIndex! neq -1 (
            set sLongString=!inputString!
            call :Substring %sLongString% 0 !lastSpaceIndex! inputString
            echo %inputString%
            set "totalWidth=0"  rem Reset totalWidth after replacement
        )
    )
)

:endLoop
echo Resulting String: !inputString!
goto :eof


REM ### Substring(sLongString, iStart, iCharCount): sSubStrResult
REM ### =========================================================
REM ### Example:
REM ###   set sLongString=MyVeryLongString
REM ###   call :Substring %sLongString% 2 8 sSubStrResult
REM ###   echo %sSubStrResult%
REM ### Output: VeryLong
REM ### Michael Hutter / Dez 2023
:Substring
SET sLongStr=%1
SET iFirstChar=%2
SET iCharCount=%3
CALL SET sSubStr=%%sLongStr:~%iFirstChar%,%iCharCount%%%
set %4=%sSubStr%
goto :eof

:eof
