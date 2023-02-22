param
(
    [Parameter(Mandatory=$false)]
    $serviceAccountUser = "ADM-AD-DMT-CFS"
)

Function Trigger()
{
    param ($serviceAccountUser)
    get_nuget -serviceAccountUser $serviceAccountUser
    get_modules -serviceAccountUser $serviceAccountUser
}

function get_nuget()
{
    param ($serviceAccountUser)
    $Nugets = Get-ChildItem -Path "C:\Users\$serviceAccountUser\softwares\NuGet"
    foreach ($Nuget in $Nugets)
    {
        $getName = $Nuget.Basename
        $getexts = $Nuget.Extension
        $Name = $getName + $getexts
        Copy-Item -Path "C:\Users\$serviceAccountUser\softwares\NuGet\$Name" -Destination "C:\Temp"
        Expand-Archive -Path "C:\Temp\$Name" -DestinationPath "C:\Program Files"
        Remove-Item 'C:\Temp\*' -Recurse -Include *.zip
    }
}

function get_modules()
{
    param ($serviceAccountUser)
    $Modules = Get-ChildItem -Path "C:\Users\$serviceAccountUser\softwares\Modules"
    foreach ($Module in $Modules)
    {
        $getName = $Module.Basename
        $getexts = $Module.Extension
        $Name = $getName + $getexts
        Copy-Item -Path "C:\Users\$serviceAccountUser\softwares\Modules\$Name" -Destination "C:\Temp"
        If($getName -like "Microsoft.Graph.*")
        {
            If(-not(Test-Path -Path C:\Users\$serviceAccountUser\Documents\WindowsPowerShell\Modules))
            {
                New-Item -itemtype "Directory" -Path "C:\Users\$serviceAccountUser\Documents\WindowsPowerShell\Modules"
                Expand-Archive -Path "C:\Temp\$Name" -DestinationPath "C:\Users\$serviceAccountUser\Documents\WindowsPowerShell\Modules\$getName"
            }
            else
            {
                Expand-Archive -Path "C:\Temp\$Name" -DestinationPath "C:\Users\$serviceAccountUser\Documents\WindowsPowerShell\Modules\$getName"
            }
        }
        else
        {
            Expand-Archive -Path "C:\Temp\$Name" -DestinationPath "C:\Program Files\WindowsPowerShell\Modules\$getName"
        }
        Remove-Item 'C:\Temp\*' -Recurse -Include *.zip
    }
}

Trigger -serviceAccountUser $serviceAccountUser