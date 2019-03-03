@ECHO OFF
SETLOCAL

REM *** ATTENTION: delims char and token order depend upon regional settings in control panel
FOR /F "tokens=2-4 delims=/ " %%i in ("%DATE%") DO (SET month=%%i& SET day=%%j& SET year=%%k)
FOR /F "tokens=1-3 delims=:." %%l in ("%TIME%") DO (SET hour=%%l& SET minute=%%m& SET second=%%n)
SET stamp=%year%%month%%day%T%hour%%minute%%second%
SET stamp=%stamp: =0%

rem START /ABOVENORMAL PowerShell...
rem START /WAIT PowerShell...
rem START PowerShell -NoExit ...
START PowerShell -NoLogo -ExecutionPolicy RemoteSigned -NoProfile -Command "<#%stamp%#> .\Test-InvalidSPOFileFolderToCSV-TEST-Verbose.ps1