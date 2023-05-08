Function Trigger()
{
    get_nuget -userProfilePath $userProfilePath -homeDrivePath $homeDrivePath
    get_modules -userProfilePath $userProfilePath -homeDrivePath $homeDrivePath
    get_modulesps -userProfilePath $userProfilePath -homeDrivePath $homeDrivePath
}

function get_nuget()
{
    $Nugets = Get-ChildItem -Path "$userProfilePath\softwares\NuGet"
    foreach ($Nuget in $Nugets)
    {
        $getName = $Nuget.Basename
        $getexts = $Nuget.Extension
        $Name = $getName + $getexts
        Copy-Item -Path "$userProfilePath\softwares\NuGet\$Name" -Destination "$homeDrivePath\Temp" -Force
        Expand-Archive -Path "$homeDrivePath\Temp\$Name" -DestinationPath "$homeDrivePath\Program Files" -Force
        Remove-Item $homeDrivePath\Temp\* -Recurse -Include *.zip -Force
    }
}

function get_modules()
{
    $Modules = Get-ChildItem -Path "$userProfilePath\softwares\Modules"
    foreach ($Module in $Modules)
    {
        $getName = $Module.Basename
        $getexts = $Module.Extension
        $Name = $getName + $getexts
        Copy-Item -Path "$userProfilePath\softwares\Modules\$Name" -Destination "$homeDrivePath\Temp" -Force
        If($getName -like "Microsoft.Graph.*")
        {
            If(-not(Test-Path -Path $userProfilePath\Documents\WindowsPowerShell\Modules))
            {
                New-Item -itemtype "Directory" -Path "$userProfilePath\Documents\WindowsPowerShell\Modules" -Force
                Expand-Archive -Path "$homeDrivePath\Temp\$Name" -DestinationPath "$userProfilePath\Documents\WindowsPowerShell\Modules\$getName" -Force
            }
            else
            {
                Expand-Archive -Path "$homeDrivePath\Temp\$Name" -DestinationPath "$userProfilePath\Documents\WindowsPowerShell\Modules\$getName" -Force
            }
        }
        else
        {
            Expand-Archive -Path "$homeDrivePath\Temp\$Name" -DestinationPath "$env:ProgramFiles\WindowsPowerShell\Modules\$getName" -Force
        }
        Remove-Item $homeDrivePath\Temp\* -Recurse -Include *.zip -Force
    }
}

function get_modulesps()
{
    $path= "$userProfilePath\softwares\ModulePowerShell"
    $ModulesPS = Get-ChildItem -Path $path
    $newPath = "$userProfilePath\softwares\ModulePowerShellZip"
    $systemPath = "$homeDrivePath\Program Files\WindowsPowerShell\Modules"

    if (!(Test-Path -path $newPath)){
        New-Item -ItemType Directory -Force -Path $newPath
    }

    foreach ($Module in $ModulesPS)
    {
        $getName = $Module.Basename
        $getexts = $Module.Extension
        Write-Output 'Name of Module: ' $getName
        Write-Output 'Current Extension: ' $getexts
        $nameFirst,$nameSecond,$ver = $getName.Split('.',3)[0,1,2]
        $textInfo = (Get-Culture).TextInfo
        $nameModuleTitleCase = $textInfo.ToTitleCase($nameFirst) + "." + $textInfo.ToTitleCase($nameSecond)
        Write-Output 'Name of Module in title case: ' $nameModuleTitleCase
        Write-Output 'Version of Module: ' $ver
        Copy-Item -Path $path\$Module -Destination $newPath\$getName.zip -Force
        Expand-Archive -Path $newPath\$getName.zip -DestinationPath $newPath\$getName -Force
        Write-Output 'System Folder for installation: ' $systemPath\$nameModuleTitleCase
        if (!(Test-Path -path $systemPath\$nameModuleTitleCase)) {
           New-Item -Path "$systemPath\$nameModuleTitleCase" -ItemType Directory -Force
        }
        Move-Item -Path $newPath\$getName -Destination  "$systemPath\$nameModuleTitleCase\$ver" -Force
    }
}
Start-Transcript -OutputDirectory $env:HOMEDRIVE\temp\logfiles

$envUserProfile = $env:USERPROFILE
Write-Output "=========================================================================="
Write-Output "$env:USERPROFILE"
Write-Output "=========================================================================="

$actualUserProfile = "C:\Users\ADM-AD-DMT-CFS"
$userProfilePath = $envUserProfile

if($envUserProfile -ne $actualUserProfile)
{
    Write-Output "=========================================================================="
    Write-Output "env:USERPROFILE Environment Variable is different from the actual value"
    Write-Output "=========================================================================="
    $userProfilePath = $actualUserProfile
}

$envHomeDrive = $env:HOMEDRIVE
$actualHomeDrive = "C:"
$homeDrivePath = $envHomeDrive

if($envHomeDrive -ne $actualHomeDrive)
{
    Write-Output "=========================================================================="
    Write-Output "env:USERPROFILE Environment Variable is different from the actual value"
    Write-Output "=========================================================================="
    $homeDrivePath = $actualHomeDrive
}

Trigger -userProfilePath $userProfilePath -homeDrivePath $homeDrivePath

Stop-Transcript