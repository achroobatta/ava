try
{
    #Install 7zip
    try
    {
        $srch7zip = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*7-Zip*" }
        if ($null -ne $srch7zip)
        {
            return "7zip is already installed"
        }
        else
        {
            #install 7zip
            $get7zip = Get-ChildItem -Path "$env:USERPROFILE\softwares\7zip"
            $get7name = $get7zip.BaseName
            $get7exts = $get7zip.Extension
            $7Name = $get7name + $get7exts
            Copy-Item -Path "$env:USERPROFILE\softwares\7zip\$7Name" -Destination "C:\Temp"
            Start-Process -Wait -FilePath "$env:HOMEDRIVE\Temp\$7Name" -ArgumentList "/S" -PassThru
            Remove-Item -Path "$env:HOMEDRIVE\Temp\$7Name"
        }

        $srchtree = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Treesize*" }
        if ($null -ne $srchtree)
        {
            return "Treesize is already installed"
        }
        else
        {
            #install Treesize
            $getTreesize = Get-ChildItem -Path "$env:USERPROFILE\softwares\TreeSize"
            $getTreename = $getTreesize.BaseName
            $getTreeexts = $getTreesize.Extension
            $TreeName = $getTreename + $getTreeexts
            Copy-Item -Path "$env:USERPROFILE\softwares\TreeSize\$TreeName" -Destination "$env:HOMEDRIVE\Temp"
            Start-Process -Wait -FilePath "$env:HOMEDRIVE\Temp\$TreeName" -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES" -PassThru

            #installtion with key
            #Start-Process -Wait -FilePath "$env:HOMEDRIVE\Temp\$TreeName" -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES" -PassThru
            Remove-Item -Path "$env:HOMEDRIVE\Temp\$TreeName"
            return "Successfully installed 7zip and Treesize"
        }
    }
    catch
    {
        Write-Output "Unable to Get Installer: $_"
    }
}
catch
{
    Write-Output "Please check if 7zip and Treesize installer is in correct the Storage Account"
    Write-Error $_
}