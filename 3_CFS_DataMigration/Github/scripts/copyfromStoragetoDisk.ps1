#SCRIPT FOR COPYING FILE FROM STORAGE ACCOUNT TO LOCAL DISK
param
(
    [Parameter(Mandatory=$true)]
    [String]$storageaccount,
    [Parameter(Mandatory=$true)]
    [string]$localTargetDirectory,
    [Parameter(Mandatory=$true)]
    [string]$sourceContainerName
)
Function copy_storage()
{
    $ctx = New-AzStorageContext -StorageAccountName $storageaccount -UseConnectedAccount
    $names = @(Get-AzStorageContainer -Name $sourceContainerName* -Context $ctx | Get-AzStorageBlob)
    foreach ($name in $names)
    {
        Get-AzStorageBlobContent -Blob $name.name -Container $sourceContainerName -Destination $localTargetDirectory -Context $ctx
    }
}
try
{
    if (-not(Test-Path -Path $localTargetDirectory))
    {
        write-output "Target Directory required"
        return $False;
    }
    elseif ($storageaccount -eq $null)
    {
        write-output "Storage Account required"
        return $False;
    }
    else
    {
        copy_storage($storageaccount, $localTargetDirectory, $sourceContainerName)
        write-output "Successfully Copy Zip (password protected file) from Storage to Disk1"
    }
}
catch
{
    write-output "Copy Zip (password protected file) from Storage to Disk1 Failed"
    Return = $false
}