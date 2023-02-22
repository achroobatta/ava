#COPY FILE FROM DISK2 TO STORAGE LOCATION
param
(
    [Parameter(Mandatory=$true)]
    [String]$rgname,
    [Parameter(Mandatory=$true)]
    [string]$deststorageacctname,
    [Parameter(Mandatory=$true)]
    [string]$ContainerName,
    [Parameter(Mandatory=$true)]
    [string]$sourceunzippath
)
function copy_fromlocal()
{
        $uploadstorage=Get-AzStorageAccount -ResourceGroupName $rgname -Name $deststorageacctname
        $storcontext=$uploadstorage.Context
        Get-ChildItem -Path $sourceunzippath -File -Recurse | Set-AzStorageBlobContent -Container $ContainerName -Context $storcontext
}
try
{
    if (-not(Test-Path -Path $sourceunzippath))
    {
        write-output "Source Directory required"
        return $False;
    }
    elseif (!(Get-AzResourceGroup -Name $rgname -ErrorAction SilentlyContinue))
    {
        write-output "Resource Group does not exists"
        return $False;
    }
    elseif (!(Get-AzStorageAccount -ResourceGroupName $rgname -Name $deststorageacctname -ErrorAction SilentlyContinue))
    {
        write-output "Correct Storage Account required"
        return $False;
    }
    elseif (!(Get-AzRmStorageContainer -ResourceGroupName $rgname -StorageAccountName $deststorageacctname -Name $ContainerName -ErrorAction SilentlyContinue))
    {
        write-output "Container Name does not exists"
        return $False;
    }
    else
    {
        copy_fromlocal($rgname, $deststorageacctname, $ContainerName, $sourceunzippath)
        write-output "Successfully copied the file"
    }
}
catch
{
    write-output "Cannot copy File"
    Return $false
}