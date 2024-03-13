$bundle_dokan_mayor = $args[0] #"2"
$bundle_dokan_version = $args[3] #"2.1.0.1000"

######################
# FUNCTIONS          #
######################

function Get-DokanVersionsInSystem {
    $dokan_installed_version = Get-Package -Name dokan* -EA Ignore | Select-Object -ExpandProperty Version | Sort-Object -Descending | Get-Unique
    
    return $dokan_installed_version
}

function Get-IsDokanInstallRequired {
    Param(
        [String[]] $CurrentDokanVersions
    )

    $get_bundle_version_installed = @($CurrentDokanVersions) -like "$bundle_dokan_mayor.*"
    if ($get_bundle_version_installed.Length -eq 0) {
        # None of the Dokan versions installed are the mayor version we bundle. Install our bundle version.
        return 'found_different_mayor'
    }

    # The Dokan mayor version of the bundle is installed
    $installed_version = $get_bundle_version_installed[0]
    if ($installed_version -eq $bundle_dokan_version) {
        return 'found_same_version'
    }

    if ($installed_version -clt $bundle_dokan_version) {
        return 'found_older_version_mayor'
    }

    return 'found_newer_version_mayor'
}

######################
# OPERATIONS         #
######################

$dokan_version_list = Get-DokanVersionsInSystem
if ($null -eq $dokan_version_list) {
    return "not_found"
}

# Dokan found. Checking the version in case of requiring update.
$installation_required = Get-IsDokanInstallRequired -CurrentDokanVersions $dokan_version_list
return $installation_required