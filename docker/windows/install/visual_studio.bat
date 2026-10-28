set TEMP_DIR=C:\Temp
if not exist "%TEMP_DIR%" mkdir %TEMP_DIR%

powershell -Command Invoke-WebRequest https://aka.ms/vs/17/release/channel -OutFile %TEMP_DIR%/VisualStudio.chman
powershell -Command Invoke-WebRequest https://aka.ms/vs/17/release/vs_buildtools.exe -OutFile %TEMP_DIR%/vs_buildtools.exe

rem https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2019
rem https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2019

%TEMP_DIR%\vs_buildtools.exe --quiet --wait --norestart --nocache ^
    --channelUri C:\TEMP\VisualStudio.chman ^
    --installChannelUri C:\TEMP\VisualStudio.chman ^
    --installPath C:\BuildTools ^
    --add Microsoft.VisualStudio.Workload.VCTools ^
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 ^
    --add Microsoft.VisualStudio.Component.Windows10SDK.19041 ^
    --add Microsoft.VisualStudio.Component.VC.CMake.Project ^
    --add Microsoft.VisualStudio.Component.VC.ATL ^
    || IF "%ERRORLEVEL%"=="3010" EXIT 0
