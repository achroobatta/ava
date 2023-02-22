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
    [string]$unzipPath,
    [Parameter(Mandatory=$true)]
    [string]$subId,
    [Parameter(Mandatory=$true)]
    [string]$subTenantId
)

function azconnect()
{
    param ($subId, $subTenantId)

    $attempt = 1
    $result = Get-AzContext
    if($null -eq $result)
    {
        $azctx = $false
    }
    else
    {
        $azctx = $true
    }
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Connecting to Azure") >> $logFilePath
    while($attempt -le 3 -and -not $azctx)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Attempt $attempt") >> $logFilePath
        try
        {
            Connect-AzAccount -Identity -Tenant $subTenantId -Subscription $subId -Force
            $result = Get-AzContext
            if($null -ne $result)
            {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Connection with azure established") >> $logFilePath
                break
            }
        }
        catch
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed to established connection") >> $logFilePath
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Sleep for 60 Seconds") >> $logFilePath
            Start-Sleep -Seconds 60
            if($attempt -gt 2)
            {
                Start-Sleep -Seconds 60
            }
        }
        $attempt += 1
    }
    $azresult = Get-AzContext
    if($null -eq $azresult)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to established connection") >> $logFilePath
        break
    }
}

function copy_fromlocal()
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Copying file from Disk2 to storage location") >> $logFilePath

    $uploadstorage = Get-AzStorageAccount -ResourceGroupName $commRG -Name $destStorageAccount
    if ($null -eq $uploadstorage)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to get storage") >> $logFilePath
    }

    try
    {
        $storcontext = $uploadstorage.Context
        Get-ChildItem -Path $unzipPath -File -Recurse | Set-AzStorageBlobContent -Container $destContainerName -Context $storcontext -ErrorAction Stop -ErrorVariable $err | Out-Null
    }
    catch
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Error encountered while copying to storage") >> $logFilePath
    }

    $result = Get-AzStorageContainer -Name $destContainerName* -Context $storcontext | Get-AzStorageBlob
    if($null -ne $result)
    {
        $result | Out-Null
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully upload the file from Disk2 to Destination Storage Account") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
        return "Successfully upload the file from Disk2 to Destination Storage Account"
    }
    else
    {
        $result | Out-Null
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Copy from Disk2 to Destination Storage account Failed") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
        return "Copy from Disk2 to Destination Storage account Failed"
    }
}

$logFilePath = "$PSScriptRoot\logging_copyFilefromLocaltoStorage.txt"

try
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Start") >> $logFilePath
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Executing copy_fromlocal function...") >> $logFilePath

    $azctx = Get-AzContext
    if($null -eq $azctx)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"VM is not connected in Azure") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Reconnecting to azure...") >> $logFilePath
        azconnect -subId $subId -subTenantId $subTenantId | Out-Null
    }

    copy_fromlocal($commRG, $unzipPath, $destContainerName, $destStorageAccount)
}
catch
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Cannot copy File") >> $logFilePath
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
    return "Cannot copy File"
}