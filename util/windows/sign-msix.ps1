param ($msixPath, $pfxPath, $certPassword)

if (-not (Test-Path $msixPath -PathType Leaf)) {
    throw "Invalid msixPath ($msixPath)"
}

if (-not (Test-Path $pfxPath -PathType Leaf)) {
    throw "Invalid pfxPath ($msixPath)"
}

$ErrorActionPreference = 'Stop'

# Find signtool.exe, it should be in "C:\Program Files (x86)\Windows Kits\10\bin\<SOME_VERSION>\x64\signtool.exe"
$signtool = Get-ChildItem `
    -Path 'C:\Program Files (x86)\Windows Kits\10\bin' `
    -Filter 'x64\signtool.exe' `
    -Recurse -Force `
    -ErrorAction SilentlyContinue `
    | Select-Object -First 1

if (-not $signtool) {
    throw "Failed to find signtool.exe"
}

& $signtool.FullName sign /fd sha256 /a /f $pfxPath /p $certPassword $msixPath

$signToolExitCode = $LASTEXITCODE

if ($signToolExitCode -ne 0) {
    throw "SignTool failed with exit code $signToolExitCode"
}
