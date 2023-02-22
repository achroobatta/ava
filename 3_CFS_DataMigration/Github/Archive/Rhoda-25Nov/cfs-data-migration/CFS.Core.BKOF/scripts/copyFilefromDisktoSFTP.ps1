#copy zip file from Disk3 to SFTP location
param
(
    [Parameter(Mandatory=$true)]
    [String]$rgname,
    [Parameter(Mandatory=$true)]
    [string]$sftpstoracctname,
    [Parameter(Mandatory=$true)]
    [string]$sftpcontainerName,
    [Parameter(Mandatory=$true)]
    [string]$sourcezippath
)
function copy_tosftploc ()
{
        $uploadstorage=Get-AzStorageAccount -ResourceGroupName $rgname -Name $sftpstoracctname
        $storcontext=$uploadstorage.Context
        Get-ChildItem -Path $sourcezippath -File -Recurse | Set-AzStorageBlobContent -Container $sftpcontainerName -Context $storcontext
}
try
{
    if (-not(Test-Path -Path $sourcezippath))
    {
        write-output "Source Directory required"
        return $False;
    }
    elseif (!(Get-AzResourceGroup -Name $rgname -ErrorAction SilentlyContinue))
    {
        write-output "Resource Group does not exists"
        return $False;
    }
    elseif (!(Get-AzStorageAccount -ResourceGroupName $rgname -Name $sftpstoracctname -ErrorAction SilentlyContinue))
    {
        write-output "Correct Storage Account required"
        return $False;
    }
    elseif (!(Get-AzRmStorageContainer -ResourceGroupName $rgname -StorageAccountName $sftpstoracctname -Name $sftpcontainerName -ErrorAction SilentlyContinue))
    {
        write-output "Container Name does not exists"
        return $False;
    }
    else
    {
        copy_tosftploc($rgname, $sftpstoracctname, $sftpcontainerName, $sourcezippath)
        write-output "Successfully copied the file"
    }
}
catch
{
    write-output "Cannot copy File"
    Return = $false
}