@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
  echo Usage: %~nx0 list.txt [root_folder]
  exit /b 1
)

set "LIST=%~1"
set "ROOT=%~2"
if "%ROOT%"=="" set "ROOT=."
set "TMP=%LIST%.tmp"
set "ADDED_LIST=%LIST%.added.txt"    :: ADDED
set "ADDED_TMP=%ADDED_LIST%.tmp"     :: ADDED

if not exist "%LIST%" (
  > "%LIST%" (rem create empty)
)

> "%TMP%" (rem truncate tmp)
> "%ADDED_TMP%" (rem truncate added tmp)    :: ADDED

rem --- Process each line in LIST: format: "full\path\file.png" md5hash ---
for /f "usebackq tokens=1* delims= " %%A in ("%LIST%") do (
  call :ProcessLine "%%~A" %%B
)

rem --- Add any .png files under %ROOT% not in TMP ---
for /r "%ROOT%" %%F in (*.png) do (
  call :EnsureInList "%%~fF"
)

rem Replace original lists with updated temps
move /y "%TMP%" "%LIST%" >nul
move /y "%ADDED_TMP%" "%ADDED_LIST%" >nul    :: ADDED
endlocal
exit /b 0

:ProcessLine
rem %1 = quoted full path, %2 = expected hash
set "FILE=%~1"
set "EXPECTED=%~2"
if not exist "%FILE%" (
  echo MISSING: %FILE%
  >> "%TMP%" echo "%FILE%" %EXPECTED%
  exit /b 0
)
call :GetMD5 "%FILE%" COMPUTED
if "%COMPUTED%"=="" (
  echo ERROR hashing: %FILE%
  >> "%TMP%" echo "%FILE%" %EXPECTED%
  exit /b 0
)
if /i "%COMPUTED%"=="%EXPECTED%" (
  echo OK:      %FILE%
  >> "%TMP%" echo "%FILE%" %EXPECTED%
) else (
  echo UPDATED: %FILE% expected=%EXPECTED% got=%COMPUTED%
  >> "%TMP%" echo "%FILE%" %COMPUTED%
)
exit /b 0

:EnsureInList
set "FILE=%~1"
set "FOUND=0"
for /f "usebackq tokens=1* delims= " %%L in ("%TMP%") do (
  if /i "%%~L"=="%FILE%" set "FOUND=1"
)
if "%FOUND%"=="0" (
  call :GetMD5 "%FILE%" COMPUTED
  if "%COMPUTED%"=="" (
    echo ERROR hashing: %FILE%
  ) else (
    echo ADDED: %FILE% got=%COMPUTED%
    >> "%TMP%" echo "%FILE%" %COMPUTED%
    >> "%ADDED_TMP%" echo "%FILE%" %COMPUTED%    :: ADDED - record new file
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
