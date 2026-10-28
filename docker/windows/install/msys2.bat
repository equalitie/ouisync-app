set MSYS2_URL="https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe"

set TEMP_DIR=C:\Temp
if not exist "%TEMP_DIR%" mkdir %TEMP_DIR%

powershell -Command [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ^
    Invoke-WebRequest -UseBasicParsing -uri "%MSYS2_URL%" -OutFile %TEMP_DIR%\msys2.exe
if errorlevel 1 exit /b %errorlevel%

%TEMP_DIR%\msys2.exe -y -oC:\
if errorlevel 1 exit /b %errorlevel%

powershell -Command Remove-Item %TEMP_DIR%\msys2.exe
if errorlevel 1 exit /b %errorlevel%

C:\msys64\usr\bin\bash.exe -lc 'pacman --noconfirm -Syuu'
if errorlevel 1 exit /b %errorlevel%

C:\msys64\usr\bin\bash.exe -lc 'pacman --noconfirm -Scc'
if errorlevel 1 exit /b %errorlevel%

C:\msys64\usr\bin\bash.exe -lc 'pacman --noconfirm -S rsync'
if errorlevel 1 exit /b %errorlevel%

set "PATH=C:\msys64\usr\bin;C:\msys64\mingw64\bin;%PATH%"
setx PATH "%PATH%" /M
