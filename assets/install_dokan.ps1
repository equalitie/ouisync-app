$msi_path = $args[0]

# Write-Host "Installing Dokan

$prog="cmd.exe"

$install_driver_params=@("/C";"msiexec /i $msi_path";">C:\log_dokan_install_ouisync.txt")

$process = Start-Process -Verb runas $prog $install_driver_params -Wait -PassThru
$cmd_result = $process.ExitCode
# Write-Host "Dokan driver installation returned $cmd_result"

return $cmd_result
