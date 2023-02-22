#COPY FILE FROM DISK2 TO STORAGE LOCATION DATA LAKE
param
(
    [Parameter(Mandatory=$true)]
    [String]$rgname,
    [Parameter(Mandatory=$true)]
    [string]$deststorageacctname,
    [Parameter(Mandatory=$true)]
    [string]$unzipPath
)
function copy_fromlocal()
{
    $ContainerName = "container" + (Get-date).ToString("Mddyy-hhmm")
    $uploadstorage = Get-AzStorageAccount -ResourceGroupName $rgname -Name $deststorageacctname
    $storcontext = $uploadstorage.Context
    $dlgencontainer = New-AzStorageContainer -Name $ContainerName -Context $storcontext
    $cname = $dlgencontainer.Name
    Get-ChildItem -Path $unzipPath -File -Recurse | Set-AzStorageBlobContent -Container $cname -Context $storcontext
}
try
{
    if (-not(Test-Path -Path $unzipPath))
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
    else
    {
        copy_fromlocal($rgname, $deststorageacctname, $unzipPath)
        write-output "Successfully copied the file"
    }
}
catch
{
    write-output "Cannot copy File"
    Return $false
}