#COPY FILE FROM DISK2 TO STORAGE LOCATION DATA LAKE
param
(
    [Parameter(Mandatory=$true)]
    [String]$commRG,
    [Parameter(Mandatory=$true)]
    [string]$destStorageAccount,
    [Parameter(Mandatory=$true)]
    [string]$destContainerName,
    [Parameter(Mandatory=$true)]
    [string]$unzipPath
)
function copy_fromlocal()
{
    $uploadstorage = Get-AzStorageAccount -ResourceGroupName $commRG -Name $destStorageAccount
    $storcontext = $uploadstorage.Context
    Get-ChildItem -Path $unzipPath -File -Recurse | Set-AzStorageBlobContent -Container $destContainerName -Context $storcontext -ErrorAction Stop -ErrorVariable $err | Out-Null
    $result = Get-AzStorageContainer -Name $destContainerName* -Context $storcontext | Get-AzStorageBlob
    if($null -ne $result)
    {
        $result | Out-Null
        return "Successfully Copy Zip (password protected file) from Storage to Disk1"
    }
    else
    {
        $result | Out-Null
        return "Copy Zip (password protected file) from Storage to Disk1 Failed"
    }
}
try
{
    copy_fromlocal($commRG, $unzipPath, $destContainerName, $destStorageAccount)
}
catch
{
    return "Cannot copy File"
}