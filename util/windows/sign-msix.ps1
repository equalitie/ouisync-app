param ($msixPath, $pfxPath, $certPassword)
 
$ErrorActionPreference = 'Stop'
 
if (-not (Test-Path $msixPath -PathType Leaf)) {
    throw "Invalid msixPath ($msixPath)"
}
 
if (-not (Test-Path $pfxPath -PathType Leaf)) {
    throw "Invalid pfxPath ($pfxPath)"
}
 
# Importing into the machine store requires administrator rights.
$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "This script must run as an administrator (it imports the certificate into Cert:\LocalMachine\My)"
}
 
# Find the newest x64 signtool.exe under
# "C:\Program Files (x86)\Windows Kits\10\bin\<SOME_VERSION>\x64\signtool.exe"
$signtool = Get-ChildItem `
    -Path 'C:\Program Files (x86)\Windows Kits\10\bin' `
    -Filter 'signtool.exe' `
    -Recurse -Force `
    -ErrorAction SilentlyContinue `
    | Where-Object { $_.Directory.Name -eq 'x64' } `
    | Sort-Object { $_.VersionInfo.FileVersionRaw } -Descending `
    | Select-Object -First 1
 
if (-not $signtool) {
    throw "Failed to find signtool.exe"
}
 
# Import the PFX into the machine store. Machine keys are protected by the
# computer's DPAPI key, so this works in key-based SSH sessions where the
# user's own key store is unavailable.
$store = 'Cert:\LocalMachine\My'
$existingThumbprints = @(Get-ChildItem $store | ForEach-Object { $_.Thumbprint })
 
$securePassword = ConvertTo-SecureString -String $certPassword -AsPlainText -Force
$cert = Import-PfxCertificate -FilePath $pfxPath -CertStoreLocation $store -Password $securePassword `
    | Where-Object { $_.HasPrivateKey } `
    | Select-Object -First 1
 
if (-not $cert) {
    throw "No certificate with a private key found in $pfxPath"
}
 
# Only remove the certificate afterwards if this script is what installed it.
$removeAfterSigning = $existingThumbprints -notcontains $cert.Thumbprint
 
try {
    & $signtool.FullName sign /fd sha256 /sm /s My /sha1 $cert.Thumbprint $msixPath
 
    $signToolExitCode = $LASTEXITCODE
 
    if ($signToolExitCode -ne 0) {
        throw "SignTool failed with exit code $signToolExitCode"
    }
}
finally {
    if ($removeAfterSigning) {
        Remove-Item -Path "$store\$($cert.Thumbprint)" -DeleteKey
    }
}
