set TEMP_DIR=C:\Temp
if not exist "%TEMP_DIR%" mkdir %TEMP_DIR%

powershell -Command Invoke-WebRequest https://github.com/jrsoftware/issrc/releases/download/is-6_7_3/innosetup-6.7.3.exe -OutFile %TEMP_DIR%/innosetup.exe
if errorlevel 1 exit /b %errorlevel%

rem https://jrsoftware.org/ishelp/index.php?topic=setupcmdline
%TEMP_DIR%/innosetup.exe /SP- /VERYSILENT /ALLUSERS /SUPPRESSMSGBOXES
if errorlevel 1 exit /b %errorlevel%
