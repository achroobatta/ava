$Installer7Zip = "C:\Temp\7z2201-x64.exe";
$ctx = New-AzStorageContext -StorageAccountName $storageaccount -UseConnectedAccount
Get-AzStorageBlobContent -Blob 7z2201-x64.exe -Container 7zipinstaller -Destination $Installer7Zip -Context $ctx
Start-Process -Wait -FilePath $Installer7Zip -ArgumentList "/S" -PassThru
Remove-Item $Installer7Zip;