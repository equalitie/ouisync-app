set FLUTTER_VERSION=3.44.9
set FLUTTER_INSTALL_DIR=C:\flutter

git clone --filter=tree:0 -b %FLUTTER_VERSION% https://github.com/flutter/flutter.git %FLUTTER_INSTALL_DIR%
if errorlevel 1 exit /b %errorlevel%

rem Git doesn't like directories with dubious ownership
rem https://nvd.nist.gov/vuln/detail/CVE-2022-24765
git config --global --add safe.directory %FLUTTER_INSTALL_DIR%
if errorlevel 1 exit /b %errorlevel%

set "PATH=%FLUTTER_INSTALL_DIR%\bin;%FLUTTER_INSTALL_DIR%\bin\cache\dart-sdk\bin;%PATH%"
setx PATH "%PATH%" /M

call dart --disable-analytics
if errorlevel 1 exit /b %errorlevel%

call flutter config --no-analytics
if errorlevel 1 exit /b %errorlevel%

call flutter config --enable-windows-desktop
if errorlevel 1 exit /b %errorlevel%

call flutter precache --windows
if errorlevel 1 exit /b %errorlevel%

call flutter doctor -v 
if errorlevel 1 exit /b %errorlevel%
