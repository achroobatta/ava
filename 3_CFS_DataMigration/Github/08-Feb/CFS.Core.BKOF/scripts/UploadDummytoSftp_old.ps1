##Login-AzAccount

param(
    [Parameter(Mandatory=$true)]
    [String]$sftpRg,
    [Parameter(Mandatory=$true)]
    [String]$sftpStorageAcctName,
    [Parameter(Mandatory=$true)]
    [String]$sftpContainerName

)

Connect-AzAccount -Identity

$filepath = "dummyCFS.txt"
Write-Output  'Welcome to CFS Dummy File' > $filepath

$storageAccountkey = (Get-AzStorageAccountKey -ResourceGroupName $sftpRg -Name $sftpStorageAcctName | Where-Object {$_.KeyName -eq "key1"}).Value
$ctx = New-AzStorageContext -StorageAccountName $sftpStorageAcctName -StorageAccountKey $storageAccountkey
Set-AzStorageBlobContent -File $filepath -Container $sftpContainerName -Blob $filepath -Context $ctx -Force