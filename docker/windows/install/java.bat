rem Sentry started to require JDK even for non Android builds. This requirement
rem might be removed in the future.
rem https://github.com/getsentry/sentry-dart/issues/3033#issuecomment-3140320200

set TEMP_DIR=C:\Temp
if not exist "%TEMP_DIR%" mkdir %TEMP_DIR%

powershell -Command Invoke-WebRequest https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%%2B9.1/OpenJDK17U-jdk_x64_windows_hotspot_17.0.9_9.zip -OutFile %TEMP_DIR%\jdk.zip
if errorlevel 1 exit /b %errorlevel%

powershell -Command Expand-Archive %TEMP_DIR%\jdk.zip -DestinationPath c:/jdk
if errorlevel 1 exit /b %errorlevel%

powershell -Command Move-Item -Path "C:\jdk\jdk-17.0.9+9" -Destination 'C:/Java'
if errorlevel 1 exit /b %errorlevel%

del /s /q C:\jdk
if errorlevel 1 exit /b %errorlevel%

set "JAVA_HOME=C:\Java"
setx JAVA_HOME "%JAVA_HOME%" /M

set "PATH=%JAVA_HOME%\bin;%PATH%"
setx PATH "%PATH%" /M
