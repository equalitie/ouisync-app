set TEMP_DIR=C:\Temp
if not exist "%TEMP_DIR%" mkdir %TEMP_DIR%

powershell -Command Invoke-WebRequest https://github.com/git-for-windows/git/releases/download/v2.55.0.windows.5/Git-2.55.0.5-64-bit.exe -OutFile %TEMP_DIR%/Git.exe
if errorlevel 1 exit /b %errorlevel%

rem Note that git-for-windows comes with Mingw64
rem For options see: https://gitforwindows.org/silent-or-unattended-installation.html
%TEMP_DIR%\Git.exe /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"
if errorlevel 1 exit /b %errorlevel%

set "PATH=C:\Program Files\Git\cmd;C:\Program Files\Git\bin;%PATH%"
setx PATH "%PATH%" /M
