# Utilities to manage Windows .msix package signing

## Usage

### Create certificate

Following creates `ouisync.private.pfx` and `ouisync.public.cer`.

```ps1
.\create-certificate.ps1 -certPassword <PASSWORD> -outputDir <OUTPUT_DIRECTORY>
```

### Sign .msix

Following signs the .msix package.

```ps1
.\sign-msix.ps1 -msixPath <PATH_TO_MSIX> -pfxPath <PATH_TO_PFX> -certPassword <PASSWORD>
```

Note that it requies [`SignTool`](https://go.microsoft.com/fwlink/?LinkID=698771) to be installed.

### Import certificate

Importing can be done using GUI or `powershell`.

#### Via GUI

* Double click on the `ouisync.public.cer` file
* Click on the "Install Certificate..." button
* Set "Store Location" to "Local Machine"
* Click "Yes" to approve
* Select "Place all certificates in the following store"
* Set "Certificate store" to "Trusted People"
* "Next" -> "Finish" -> Wait a second or two
* Certificate is now imported, click "Ok" to dismiss remaining windows

#### Via `powershell`

Run powershell as administrator and invoke

```ps1
Import-Certificate -CertStoreLocation "Cert:\LocalMachine\TrustedPeople" -FilePath ouisync.public.cer
```

### Removing the installed certificate

Once done testing you may remove the installed certificate by running
`certmgr.msc`, the certificates are located under "Trusted People /
Certificates".
