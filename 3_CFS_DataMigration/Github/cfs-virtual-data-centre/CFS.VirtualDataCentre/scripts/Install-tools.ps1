<#
.SYNOPSIS
Install apps with Winget through Intune or SCCM.
Can be used standalone.
.DESCRIPTION
Allow to run Winget in System Context to install your apps.
https://github.com/Romanitho/Winget-Install
.PARAMETER AppID
Forward Winget App ID to install
.PARAMETER Uninstall
To uninstall app. Works with AppID
.EXAMPLE
.\winget-install.ps1 -AppID Git.Git
.EXAMPLE
.\winget-install.ps1 -AppID 7zip.7zip -Uninstall
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)] [String] $AppID,
    [Parameter(Mandatory=$False)] [Switch] $Uninstall
)


<# FUNCTIONS #>


#Get WinGet Location Function
function Get-WingetCmd {
    #Get WinGet Location in User context
    $WingetCmd = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($WingetCmd){
        $Script:winget = $WingetCmd.Source
    }
    #Get WinGet Location in System context (WinGet < 1.17)
    elseif (Test-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\AppInstallerCLI.exe"){
        $Script:winget = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\AppInstallerCLI.exe" | Select-Object -ExpandProperty Path
    }
    #Get WinGet Location in System context (WinGet > 1.17)
    elseif (Test-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"){
        $Script:winget = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe" | Select-Object -ExpandProperty Path
    }
    else{
        "Winget not installed !"
        break
    }
    "Using following Winget Cmd: $winget"
}

#Check if app is installed
function Confirm-Install ($AppID){
    #Get "Winget List AppID"
    $InstalledApp = & $winget list --Id $AppID --accept-source-agreements | Out-String

    #Return if AppID existe in the list
    if ($InstalledApp -match [regex]::Escape($AppID)){
        return $true
    }
    else{
        return $false
    }
}

#Check if App exists in Winget Repository
function Confirm-Exist ($AppID){
    #Check is app exists in the winget repository
    $WingetApp = & $winget show --Id $AppID --accept-source-agreements | Out-String

    #Return if AppID exists
    if ($WingetApp -match [regex]::Escape($AppID)){
        "$AppID exists on Winget Repository."
        return $true
    }
    else{
        "$AppID does not exist on Winget Repository! Check spelling."
        return $false
    }
}

#Install function
function Install-App ($AppID){
    $IsInstalled = Confirm-Install $AppID
    if (!($IsInstalled)){
        #Install App
        "Installing $AppID..."
        & $winget install -e --id $AppID --silent --accept-package-agreements --accept-source-agreements
        #Check if install is ok
        $IsInstalled = Confirm-Install $AppID
        if ($IsInstalled){
            "$AppID successfully installed."
        }
        else{
            "$AppID installation failed!"
        }
    }
    else{
        "$AppID is already installed."
    }
}

#Uninstall function
function Uninstall-App ($AppID){
    $IsInstalled = Confirm-Install $AppID
    if ($IsInstalled){
        #Install App
        "Uninstalling $AppID..."
        & $winget uninstall -e --id $AppID --silent --accept-source-agreements
        #Check if install is ok
        $IsInstalled = Confirm-Install $AppID
        if (!($IsInstalled)){
            "$AppID successfully uninstalled."
        }
        else{
            "$AppID uninstall failed!"
        }
    }
    else{
        "$AppID is not installed."
    }
}


<# MAIN #>

"####         Winget Install          ####`n"

"Original `$ErrorActionPreference='$($ErrorActionPreference)'"
$ErrorActionPreference="Stop"
"New `$ErrorActionPreference='$($ErrorActionPreference)'"

#Run WingetCmd Function
Get-WingetCmd

#Run install or uninstall for an app

$Exists = Confirm-Exist $AppID
if ($Exists){
    #Install or Uninstall command
    if ($Uninstall){
        Uninstall-App $AppID
    }
    else{
        Install-App $AppID
    }
}
