$msi_path = $args[0]

$prog="msiexec.exe"
$install_msi_params = "/i `"$msi_path`""

$process = Start-Process $prog $install_msi_params -Wait -PassThru
$cmd_result = $process.ExitCode

return $cmd_result
