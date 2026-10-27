rem Install the OpenSSH server

net USER ssh "Passw0rd" /ADD && net localgroup "Administrators" "ssh" /ADD
if errorlevel 1 exit /b %errorlevel%

powershell -Command New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
if errorlevel 1 exit /b %errorlevel%

rem Setup permissions for authorized_keys file
powershell -Command New-Item c:/ProgramData/ssh/administrators_authorized_keys -type file
if errorlevel 1 exit /b %errorlevel%

icacls.exe c:/ProgramData/ssh/administrators_authorized_keys /inheritance:r /grant Administrators:F /grant SYSTEM:F
if errorlevel 1 exit /b %errorlevel%

rem Start the sshd service, this creates the C:\ProgramData\ssh\sshd_config file
rem which we'll need for the next step
powershell -Command Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
if errorlevel 1 exit /b %errorlevel%

type %~dp0\id_ed25519.pub >> "C:\ProgramData\ssh\administrators_authorized_keys"
if errorlevel 1 exit /b %errorlevel%

powershell -Command Start-Service sshd
if errorlevel 1 exit /b %errorlevel%
 
rem Disallow connections using login:password credentials and stop sshd
powershell -Command "(Get-Content c:\ProgramData\ssh\sshd_config).Replace('#PasswordAuthentication yes', 'PasswordAuthentication no') |Set-Content c:\ProgramData\ssh\sshd_config"
if errorlevel 1 exit /b %errorlevel%

rem make sshd auto-start on boot
powershell -Command Set-Service -Name sshd -StartupType Automatic
if errorlevel 1 exit /b %errorlevel%
