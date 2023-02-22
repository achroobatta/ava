Function Trigger()
{
    get_nuget
    get_modules
    get_modulesps
}

function get_nuget()
{
    $Nugets = Get-ChildItem -Path "$env:USERPROFILE\softwares\NuGet"
    foreach ($Nuget in $Nugets)
    {
        $getName = $Nuget.Basename
        $getexts = $Nuget.Extension
        $Name = $getName + $getexts
        Copy-Item -Path "$env:USERPROFILE\softwares\NuGet\$Name" -Destination "C:\Temp"
        Expand-Archive -Path "C:\Temp\$Name" -DestinationPath "C:\Program Files"
        Remove-Item 'C:\Temp\*' -Recurse -Include *.zip
    }
}

function get_modules()
{
    $Modules = Get-ChildItem -Path "$env:USERPROFILE\softwares\Modules"
    foreach ($Module in $Modules)
    {
        $getName = $Module.Basename
        $getexts = $Module.Extension
        $Name = $getName + $getexts
        Copy-Item -Path "$env:USERPROFILE\softwares\Modules\$Name" -Destination "C:\Temp"
        If($getName -like "Microsoft.Graph.*")
        {
            If(-not(Test-Path -Path $env:USERPROFILE\Documents\WindowsPowerShell\Modules))
            {
                New-Item -itemtype "Directory" -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
                Expand-Archive -Path "C:\Temp\$Name" -DestinationPath "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$getName"
            }
            else
            {
                Expand-Archive -Path "C:\Temp\$Name" -DestinationPath "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$getName"
            }
        }
        else
        {
            Expand-Archive -Path "$env:HOMEDRIVE\Temp\$Name" -DestinationPath "$env:ProgramFiles\WindowsPowerShell\Modules\$getName"
        }
        Remove-Item '$env:HOMEDRIVE\Temp\*' -Recurse -Include *.zip
    }
}

function get_modulesps()
{
    $path= "$env:USERPROFILE\softwares\ModulePowerShell"
    $ModulesPS = Get-ChildItem -Path $path
    $newPath = "$env:USERPROFILE\softwares\ModulePowerShellZip"
    $systemPath = "C:\Program Files\WindowsPowerShell\Modules"

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
        Move-Item -Path $newPath\$getName -Destination  "$systemPath\$nameModuleTitleCase\$ver"
    }
}

Trigger
