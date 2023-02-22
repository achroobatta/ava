#SCRIPT FOR COPYING FILE FROM STORAGE ACCOUNT TO LOCAL DISK
#create by: Joshua Ira San Ramon
param
(
    [Parameter(Mandatory=$true)]
    [String]$sourceStorageAccount,
    [Parameter(Mandatory=$true)]
    [string]$localTargetDirectory,
    [Parameter(Mandatory=$true)]
    [string]$sourceLocation
)
Function copy_storage()
{
    $ctx = New-AzStorageContext -storageAccountName $sourceStorageAccount -UseConnectedAccount
    $names = @(Get-AzStorageContainer -Name $sourceLocation* -Context $ctx | Get-AzStorageBlob)
    foreach ($name in $names)
    {
        Get-AzStorageBlobContent -Blob $name.name -Container $sourceLocation -Destination $localTargetDirectory -Context $ctx -ErrorAction Stop -Force | Out-Null
    }

    $result = Get-ChildItem $localTargetDirectory
    if($null -ne $result)
    {
        return "Successfully Copy Zip (password protected file) from Storage to Disk1"
    }
    else
    {
        return "Copy Zip (password protected file) from Storage to Disk1 Failed"
    }
}
try
{
    copy_storage($sourceStorageAccount, $localTargetDirectory, $sourceLocation)
}
catch
{
    return "Copy Zip (password protected file) from Storage to Disk1 Failed"
}