#
# Script for creating a certificate to test Ouisync msix packages.
#
# The output is two files, the private.pfx file is for signing the packages
# and the public.cer file is for users to install into their Windows OS to
# allow them to install the .msix bundle.
#
# Here it what it does:
#   * Creates a new temporary certificate inside `Cert:\CurrentUser\My`.
#     It can be accessed through GUI using `certmgr.msc` under `Personal`.
#   * Exports the certificate into .pfx and .cer files.
#   * Deletes the temporary certificate.
#
# The .pfx file is the one containing a private key for signing. The .cer file
# is public.
#
param ($certPassword, $outputDir)

if (-not (Test-Path $outputDir)) {
    throw "Path $outputDir does not exist"
}

$ErrorActionPreference = 'Stop'

$certDir = "Cert:\CurrentUser\My"

# From https://learn.microsoft.com/en-us/windows/msix/package/create-certificate-package-signing
#
# > the "Subject" in the certificate must match the "Publisher" section in your app's manifest.
#
# The manifest can be found inside the $msix_package/AppManifest.xml
#
# TODO: Due to historical reason Ouisync's "Publisher" is this unfriendly string. We should
# change it, but that will imply that Microsoft store will treat it as a different application
# and thus auto-updates from Ouisync previous versions will stop working.
$publisher = "CN=E3D17812-E9F1-46C8-B650-4D39786777D9"

$newCert = New-SelfSignedCertificate `
    -Type Custom `
    -KeyUsage DigitalSignature `
    -CertStoreLocation $certDir `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}") `
    -Subject $publisher `
    -FriendlyName "Ouisync P2P file syncing app"

$certLocation=$certDir + "\" + $newCert.thumbprint
$certificatePrivate="private.pfx"
$certificatePublic="public.cer"

$key = ConvertTo-SecureString -String $certPassword -Force -AsPlainText 
Export-PfxCertificate -Cert $certLocation -FilePath $outputDir\$certificatePrivate -Password $key
Export-Certificate -Cert $certLocation -FilePath $outputDir\$certificatePublic -Type CERT

Get-ChildItem -Path $certLocation | Remove-Item
