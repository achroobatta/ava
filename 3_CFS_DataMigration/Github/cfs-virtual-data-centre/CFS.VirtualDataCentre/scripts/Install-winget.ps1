"Original `$ErrorActionPreference='$($ErrorActionPreference)'"
$ErrorActionPreference="Stop"
"New `$ErrorActionPreference='$($ErrorActionPreference)'"

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$Downloadlocation = 'C:\PS'
new-item -ItemType Directory -Force -Path "$Downloadlocation"

##Download Required Packages and Dependencies

Invoke-WebRequest -Uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile "C:\PS\Microsoft.VCLibs.appx"
Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.2.10271/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile "C:\PS\WinGet.msixbundle"
Invoke-WebRequest -Uri "https://aka.ms/vs/16/release/VC_redist.x64.exe" -OutFile "C:\PS\VC_redist.x64.exe"
Invoke-WebRequest -Uri "https://aka.ms/vs/16/release/VC_redist.x86.exe" -OutFile "C:\PS\VC_redist.x86.exe"

##Install Updates, Winget and dependencies

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
Start-Process C:\PS\VC_redist.x64.exe /S -NoNewWindow -Wait -PassThru
Start-Process C:\PS\VC_redist.x86.exe /S -NoNewWindow -Wait -PassThru
Install-WindowsUpdate -KBArticleID "KB5005565" -AcceptAll
Add-AppxProvisionedPackage -PackagePath C:\PS\WinGet.msixbundle -DependencyPackagePath C:\PS\Microsoft.VCLibs.appx -SkipLicense -Online
Install-WindowsUpdate -AcceptAll -Install -AutoReboot