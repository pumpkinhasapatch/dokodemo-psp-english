@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
  echo Usage: %~nx0 list.txt [root_folder]
  exit /b 1
)

rem make OUT/ADDED_OUT absolute so pushd won't break them
set "OUT=%LIST%.new"
set "ADDED_LIST=%LIST%.added.txt"
set "ADDED_OUT=%ADDED_LIST%.new"
for %%O in ("%OUT%") do set "OUT_ABS=%%~fO"
for %%A in ("%ADDED_OUT%") do set "ADDED_OUT_ABS=%%~fA"

rem Resolve absolute root path (no trailing backslash)
for %%R in ("%ROOT%") do set "ROOT_ABS=%%~fR"
if "%ROOT_ABS:~-1%"=="\" set "ROOT_ABS=%ROOT_ABS:~0,-1%"

rem create/truncate outputs using absolute paths
break> "%OUT_ABS%"
break> "%ADDED_OUT_ABS%"

rem Process existing entries (handles spaces/quotes)
for /f "usebackq tokens=1* delims= " %%A in ("%LIST%") do (
  call :ProcessLine "%%~A" %%B
)

rem Walk tree under ROOT_ABS and add png files not yet recorded in OUT
pushd "%ROOT_ABS%" >nul 2>&1 || exit /b 1
for /r "." %%F in (*.png) do (
  rem %%~fF is absolute; call EnsureInList with absolute path
  call :EnsureInList "%%~fF"
)
popd >nul

move /y "%OUT%" "%LIST%" >nul
move /y "%ADDED_OUT%" "%ADDED_LIST%" >nul
endlocal
exit /b 0

:ProcessLine
rem %1 = quoted path from list (may be relative or absolute), %2 = expected hash
set "INPUT=%~1"
set "EXPECTED=%~2"

rem Resolve to absolute path for existence/hash checks
for %%F in ("%INPUT%") do set "FILE_ABS=%%~fF"

if not exist "%FILE_ABS%" (
  call :ToRelative "%FILE_ABS%" REL
  >> "%OUT%" echo "%REL%" %EXPECTED%
  exit /b 0
)

call :GetMD5 "%FILE_ABS%" COMPUTED
if "%COMPUTED%"=="" (
  call :ToRelative "%FILE_ABS%" REL
  >> "%OUT%" echo "%REL%" %EXPECTED%
  exit /b 0
)

call :ToRelative "%FILE_ABS%" REL
if /i "%COMPUTED%"=="%EXPECTED%" (
  >> "%OUT%" echo "%REL%" %EXPECTED%
) else (
  >> "%OUT%" echo "%REL%" %COMPUTED%
)
exit /b 0

:EnsureInList
rem %1 = absolute file path
set "FILE_ABS=%~1"
set "FOUND=0"
for /f "usebackq tokens=1* delims= " %%L in ("%OUT%") do (
  rem convert recorded path to absolute for comparison
  for %%X in ("%%~L") do (
    set "REC_ABS=%%~fX"
    if /i "!REC_ABS!"=="%FILE_ABS%" set "FOUND=1"
  )
)
if "%FOUND%"=="0" (
  call :GetMD5 "%FILE_ABS%" COMPUTED
  if not "%COMPUTED%"=="" (
    call :ToRelative "%FILE_ABS%" REL
    >> "%OUT%" echo "%REL%" %COMPUTED%
    >> "%ADDED_OUT%" echo "%REL%" %COMPUTED%
  )
)
exit /b 0

:GetMD5
rem %1 = file path, %2 = name of variable to set with hash
set "%~2="
for /f "skip=1 tokens=1" %%H in ('certutil -hashfile "%~1" MD5 ^| findstr /r "[0-9A-Fa-f]"') do (
  set "%~2=%%H"
  goto :gotmd5
)
:gotmd5
exit /b 0

:ToRelative
rem %1 = absolute path, sets %2 to relative path if under ROOT_ABS, else absolute
set "%~2=%~1"
set "ABS=%~1"
rem Normalize slashes (ensure backslashes)
rem If ABS starts with ROOT_ABS\ then strip prefix
set "PREF=%ROOT_ABS%\"
if /i "!ABS:~0,%PREF:~0,0%!"=="" (
  rem no-op; required to avoid delayed-expansion parsing issue
)
if /i "!ABS:~0,%PREF:~0%" NEQ "" (
  rem dummy; keep parser happy
)
rem Actual compare using substring replacement
set "REL=!ABS:%ROOT_ABS%\=!"
if not "!REL!"=="!ABS!" (
  set "%~2=!REL!"
) else (
  set "%~2=!ABS!"
)
exit /b 0
