#copy zip file from Disk3 to SFTP location
param
(
    [Parameter(Mandatory=$true)]
    [String]$commRG,
    [Parameter(Mandatory=$true)]
    [string]$destStorageAccount,
    [Parameter(Mandatory=$true)]
    [string]$zipPath,
    [Parameter(Mandatory=$true)]
    [string]$destContainerName
)
function copy_tosftploc ()
{
    $uploadstorage = Get-AzStorageAccount -ResourceGroupName $commRG -Name $destStorageAccount
    $storcontext=$uploadstorage.Context
    Get-ChildItem -Path $zipPath -File -Recurse | Set-AzStorageBlobContent -Container $destContainerName -Context $storcontext -ErrorAction Stop -ErrorVariable $err | Out-Null
    if($null -eq $err)
    {
        return "Successfully Copy Zip from Disk2 to SFTP Storage"
    }
    else
    {
        return "Failed to Copy Zip from Disk2 to SFTP Storage"
    }
}
try
{
    copy_tosftploc($commRG, $zipPath, $destContainerName, $destStorageAccount)
}
catch
{
    return "Failed to Copy File From Disk to SFTP Please check input parameters"
}