$ouisync_dokan_mayor = "2"
$ouisync_dokan_minor = "1"
$ouisync_dokan_patch = "0"
$minimum_ouisync_dokan_version = "2.1.0"
$full_minimum_ouisync_dokan_version = "2.1.0.1000"

$root_directory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

######################
# FUNCTIONS          #
######################

function Get-DokanVersionsInSystem {
    $dokan_driver_versions = (Get-ChildItem -Path "$env:WINDIR\system32\drivers" -Filter dokan*.sys).VersionInfo.FileVersionRaw | Sort-Object -Descending | Get-Unique

    return $dokan_driver_versions
}

function Get-IsDokanInstallRequired {
    Param(
        [String[]] $CurrentDokanVersions
    )

    # Select WHERE the version string starts with 2.* to only select version 2 of the driver.
    $dokan2_driver_version = $CurrentDokanVersions | Where-Object{$_ -like "$ouisync_dokan_mayor.*"} | Sort-Object -Descending | Select-Object -First 1
   
    if ($dokan2_driver_version.Length -eq 0) {
        # "Dokan $ouisync_dokan_mayor not found. Installation required (1)"
        return 1
    }

    if ($dokan2_driver_version -lt $minimum_ouisync_dokan_version) {
        # "Dokan $ouisync_dokan_mayor was found, but the driver is a lower version ($dokan2_driver_version) than the one used by Ouisync ($full_minimum_ouisync_dokan_version). An update is required, but we cannot do it automatically. (2)"
        return 2
    }

    # The Dokan $ouisync_dokan_mayor version is equal or grather than required by Ouisync ($minimum_ouisync_dokan_version). No action needed.
    return 0
}

# function Get-IsCurrentDokanVersionSupported {
#     Param(
#         [String] $DokanVersion
#     )

#     $version_array = $DokanVersion.replace(".", ":") -split ":"
    
#     $MAYOR = $version_array[0]
#     $MINOR = $version_array[1]
#     $PATCH = $version_array[2]

#     if ("$MAYOR.$MINOR.$PATCH" -eq $minimum_ouisync_dokan_version -or
#         $MAYOR -gt $ouisync_dokan_mayor) {
#         return $true
#     }

#     # if ($MINOR -lt $ouisync_dokan_minor) {
#     #     return $true
#     # }

#     return $false
# }

function Install-Dokan {
    Write-Host "Installing Dokan $full_minimum_ouisync_dokan_version"

    $prog="cmd.exe"

    $windir_system32_drivers_directory = "$env:WINDIR\system32\drivers"
    
    $dokan_sys_file = "$root_directory\dokan2.sys"
    $dokan_exe = "$root_directory\dokanctl.exe"
    
    $install_driver_params=@("/C";"copy $dokan_sys_file $windir_system32_drivers_directory&&$dokan_exe /i d";">C:\log_dokan_install_ouisync.txt")
    
    $process = Start-Process -Verb runas $prog $install_driver_params -Wait -PassThru
    $cmd_result = $process.ExitCode
    
    Write-Host "Dokan driver installation returned $cmd_result"
    
    return $cmd_result
}

function Get-InstallDokanConfirmation {
    $title_dokan_installation = "Dokan installation required - Ouisync"
    $message_dokan_installation = "Dokan $ouisync_dokan_mayor is missing in this device.`n`nOuisync uses Dokan $full_minimum_ouisync_dokan_version for mounting unlocked repositories as drives, than later can be seen and opened in the File Explorer.`n`nWe can try to install it for you"

    $result = [System.Windows.Forms.MessageBox]::Show($message_dokan_installation, $title_dokan_installation, [System.Windows.Forms.MessageBoxButtons]::OKCancel, [System.Windows.Forms.MessageBoxIcon]::Question, [System.Windows.Forms.MessageBoxDefaultButton]::Button1)

    if ($result -eq "Cancel") {
        return $false
    }

    return $true
}

function Install-Dokan2-WithConfirmation {
    Write-Host "Dokan $ouisync_dokan_mayor is missing. Installing Dokan $full_minimum_ouisync_dokan_version"

    $confirmation_result = Get-InstallDokanConfirmation
    if ($confirmation_result -eq $false) {
        Write-Host "Dokan installation canceled by user"
        return
    }

    $install_result = Install-Dokan
    if ($install_result -eq 0) {
        Show-AlertDialog -Title "Dokan installation - Ouisync" -Message "Dokan $full_minimum_ouisync_dokan_version installed successfully."
    } else {
        Show-AlertDialog -Title "Dokan installation - Ouisync" -Message  "Dokan $full_minimum_ouisync_dokan_version installation failed. You may need to install Dokan manually for Ouisync to work properly.`n`nMinimum required version: $minimum_ouisync_dokan_version"
    }
}

# function Get-UpgradeDokanConfirmation {
#     Param(
#         [String] $DokanVersion
#     )

#     $title_dokan_upgrade = "Dokan upgrade required - Ouisync"
#     $message_dokan_upgrade = "The Dokan version found ($DokanVersion) is lower than required by Ouisync ($minimum_ouisync_dokan_version), and some features may not worked as expected.`n`nOuisync uses Dokan for mounting unlocked repositories as drives, than later can be seen and opened in the File Explorer.`n`nWe can try to upgrade it for you"

#     Add-Type -AssemblyName System.Windows.Forms
#     $result = [System.Windows.Forms.MessageBox]::Show($message_dokan_upgrade, $title_dokan_upgrade, [System.Windows.Forms.MessageBoxButtons]::OKCancel, [System.Windows.Forms.MessageBoxIcon]::Question, [System.Windows.Forms.MessageBoxDefaultButton]::Button1)

#     if ($result -eq "Cancel") {
#         return $false
#     }

#     return $true
# }

function Show-AlertDialog {
    Param(
        [String] $Title,
        [String] $Message
    )

    [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

######################
# OPERATIONS         #
######################

$dokan_version_list = Get-DokanVersionsInSystem
Write-Host "Dokan versions found: $dokan_version_list"

if ($null -eq $dokan_version_list) {
    Install-Dokan2-WithConfirmation

    return
}

# Dokan found. Checking the version in case of requiring update.
Write-Host "Checking the Dokan version required for Ouisync..."

$installation_required = Get-IsDokanInstallRequired -CurrentDokanVersions $dokan_version_list
if ($installation_required -eq 0) {
    Write-Host "The Dokan driver version found is equal or greater than the one required by Ouisync ($minimum_ouisync_dokan_version). No action is required."

    return
}

if ($installation_required -eq 1) {
    Write-Host "Dokan $ouisync_dokan_mayor not found. Installation required."
    Install-Dokan2-WithConfirmation

    return
}

if ($installation_required -eq 2) {
    Write-Host "Dokan $ouisync_dokan_mayor was found, but the driver is a lower version than the one used by Ouisync ($full_minimum_ouisync_dokan_version). An update is required, but we cannot do it automatically."
    Show-AlertDialog -Title "Dokan installation - Ouisync" -Message "Dokan $ouisync_dokan_mayor was found, but the driver is a lower version than the one used by Ouisync ($full_minimum_ouisync_dokan_version). An update is required, but we cannot do it automatically."

    return
}
