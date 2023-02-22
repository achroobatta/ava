#SCRIPT FOR COPYING FILE FROM STORAGE ACCOUNT TO LOCAL DISK
param
(
    [Parameter(Mandatory=$true)]
    [String]$storageaccount,
    [Parameter(Mandatory=$true)]
    [string]$stgencryptedFileName,
    [Parameter(Mandatory=$true)]
    [string]$localTargetDirectory,
    [Parameter(Mandatory=$true)]
    [string]$sourceContainerName
)
Function copy_storage()
{
    $ctx = New-AzStorageContext -StorageAccountName $storageaccount -UseConnectedAccount
    Get-AzStorageBlobContent -Blob $stgencryptedFileName -Container $sourceContainerName -Destination $localTargetDirectory -Context $ctx
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
    elseif ($stgencryptedFileName -eq $null)
    {
        write-output "Encrypted Filename required"
        return $False;
    }
    else
    {
        copy_storage($storageaccount, $stgencryptedFileName, $localTargetDirectory, $sourceContainerName)
        write-output "Successfully copy the file $EncryptedFileName"
    }
}
catch
{
    write-output "Cannot copy File"
    Return = $false
}