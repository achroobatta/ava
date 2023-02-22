#copy zip file from Disk3 to SFTP location
param
(
    [Parameter(Mandatory=$true)]
    [String]$rgname,
    [Parameter(Mandatory=$true)]
    [string]$sftpstoracctname,
    [Parameter(Mandatory=$true)]
    [string]$sourcezippath,
    [Parameter(Mandatory=$true)]
    [string]$sftpcontainerName
)
function copy_tosftploc ()
{
    $uploadstorage = Get-AzStorageAccount -ResourceGroupName $rgname -Name $sftpstoracctname
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
    elseif ($sftpcontainerName -eq $null)
    {
        write-output "Provide a Container Name"
        return $False;
    }
    else
    {
        copy_tosftploc($rgname, $sftpstoracctname, $sourcezippath, $sftpcontainerName)
        write-output "Successfully Copy File From Disk to SFTP"
    }
}
catch
{
    write-output "Failed to Copy File From Disk to SFTP"
    Return = $false
}