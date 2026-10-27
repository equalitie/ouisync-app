set TEMP_DIR=C:\Temp
if not exist "%TEMP_DIR%" mkdir %TEMP_DIR%

set RUST_VERSION=1.97.1
set RUST_INSTALL_DIR=%USERPROFILE%\.cargo\bin

powershell -Command Invoke-WebRequest https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe -OutFile %TEMP_DIR%\rustup-init.exe
if errorlevel 1 exit /b %errorlevel%

%TEMP_DIR%\rustup-init.exe --default-toolchain=%RUST_VERSION% -y
if errorlevel 1 exit /b %errorlevel%

set "PATH=%RUST_INSTALL_DIR%;%PATH%"
setx PATH "%PATH%" /M
