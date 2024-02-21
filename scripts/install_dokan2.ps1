$ouisync_dokan_mayor = "2"
$ouisync_dokan_minor = "1"
$ouisync_dokan_patch = "0"
$minimum_ouisync_dokan_version = "2.1.0"
$full_minimum_ouisync_dokan_version = "2.1.0.1000"

$root_directory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

######################
# FUNCTIONS          #
######################
    
function Get-DockanVersionInSystem {
    $dokan_version_in_system = Get-Package -Name dokan* -EA Ignore | Select-Object -ExpandProperty Version
    #TODO: Also check if dokan2.sys is in %WINDIR%/system32/drivers
    return $dokan_version_in_system
}


function Get-IsCurrentDokanVersionSupported {
    Param(
        [String] $DokanVersion
    )

    $version_array = $DokanVersion.replace(".", ":") -split ":"
    
    $MAYOR = $version_array[0]
    $MINOR = $version_array[1]
    $PATCH = $version_array[2]

    if ("$MAYOR.$MINOR.$PATCH" -eq $minimum_ouisync_dokan_version -or
        $MAYOR -gt $ouisync_dokan_mayor) {
        return $true
    }

    # if ($MINOR -lt $ouisync_dokan_minor) {
    #     return $true
    # }

    return $false
}

function Install-Dokan {
    Write-Host "Installing Dokan $full_minimum_ouisync_dokan_version"

    $prog="cmd.exe"

    $windir_system32_drivers_directory = "$env:WINDIR\system32\drivers"

    $dokan_sys_file = "$root_directory\dokan2.sys"
    $dokan_exe = "$root_directory\dokanctl.exe"
    
    $install_driver_params=@("/C";"copy $dokan_sys_file $windir_system32_drivers_directory&&$dokan_exe /i d";" >c:\temp\result_driver.txt")
    
    Start-Process -Verb runas $prog $install_driver_params

    return $true
}

function Get-InstallDokanConfirmation {
    $title_dokan_installation = "Dokan installation required - Ouisync"
    $message_dokan_installation = "Dokan is missing in this device.`n`nOuisync uses Dokan $full_minimum_ouisync_dokan_version for mounting unlocked repositories as drives, than later can be seen and opened in the File Explorer.`n`nWe can try to install it for you"

    Add-Type -AssemblyName System.Windows.Forms
    $result = [System.Windows.Forms.MessageBox]::Show($message_dokan_installation, $title_dokan_installation, [System.Windows.Forms.MessageBoxButtons]::OKCancel, [System.Windows.Forms.MessageBoxIcon]::Question, [System.Windows.Forms.MessageBoxDefaultButton]::Button1)

    if ($result -eq "Cancel") {
        return $false
    }

    return $true
}

function Get-UpgradeDokanConfirmation {
    $title_dokan_upgrade = "Dokan upgrade required - Ouisync"
    $message_dokan_upgrade = "The Dokan version found ($dokan_version) is lower than required by Ouisync ($minimum_ouisync_dokan_version), and some features may not worked as expected.`n`nOuisync uses Dokan for mounting unlocked repositories as drives, than later can be seen and opened in the File Explorer.`n`nWe can try to upgrade it for you"

    Add-Type -AssemblyName System.Windows.Forms
    $result = [System.Windows.Forms.MessageBox]::Show($message_dokan_upgrade, $title_dokan_upgrade, [System.Windows.Forms.MessageBoxButtons]::OKCancel, [System.Windows.Forms.MessageBoxIcon]::Question, [System.Windows.Forms.MessageBoxDefaultButton]::Button1)

    if ($result -eq "Cancel") {
        return $false
    }

    return $true
}

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

$dokan_version = Get-DockanVersionInSystem
if ($null -eq $dokan_version) {
    Write-Host "Dokan is missing. Installing Dokan $full_minimum_ouisync_dokan_version"

    $install_dokan_result = Get-InstallDokanConfirmation
    if ($install_dokan_result -eq $false) {
        Write-Host "Dokan installation canceled by user"
        return
    }

    $dokan_install_result = Install-Dokan
    if ($dokan_install_result) {
        Show-AlertDialog -Title "Dokan installation - Ouisync" -Message "Dokan $full_minimum_ouisync_dokan_version installed successfully."
    } else {
        Show-AlertDialog -Title "Dokan installation - Ouisync" -Message  "Dokan $full_minimum_ouisync_dokan_version installation failed. You may need to install Dokan manually for Ouisync to work properly.`n`nMinimum required version: $minimum_ouisync_dokan_version"
    }

    return
}

# Dokan installation found. Checking the version in case of requiring update.
Write-Host "Dokan version $dokan_version found"

$supported = Get-IsCurrentDokanVersionSupported -DokanVersion $dokan_version
if ($supported) {
    Write-Host "The Dokan minimum required version for Ouisync is $minimum_ouisync_dokan_version.`n`nNo update is required (Current version: $dokan_version)"
    return
} 

Write-Host "The current version of Dokan ($DokanVersion) is lower than the minimum required for Ouisync ($minimum_ouisync_dokan_version).`n`nAn upgrade may be needed."

$upgrade_dokan_result = Get-UpgradeDokanConfirmation
if ($upgrade_dokan_result -eq $false) {
    Write-Host "Dokan upgrade canceled by user"
    return
}

$dokan_upgrade_result = Install-Dokan
if ($dokan_upgrade_result) {
    Show-AlertDialog -Title "Dokan upgrade - Ouisync" -Message "Dokan upgraded successfully.`n`nWas $dokan_version; Current: $minimum_ouisync_dokan_version"
} else {
    Show-AlertDialog -Title "Dokan upgrade - Ouisync" -Message "Dokan upgrade failed. You may need to upgrade Dokan to version $minimum_ouisync_dokan_version manually for Ouisync to work properly."
}