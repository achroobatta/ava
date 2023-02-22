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
    [string]$destContainerName,
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



function copy_tosftploc ()
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Copy zip file from Disk3 to SFTP location") >> $logFilePath

    $uploadstorage = Get-AzStorageAccount -ResourceGroupName $commRG -Name $destStorageAccount
    if ($null -eq $uploadstorage)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to get storage") >> $logFilePath
    }

    try
    {
        $storcontext=$uploadstorage.Context
        Get-ChildItem -Path $zipPath -File -Recurse | Set-AzStorageBlobContent -Container $destContainerName -Context $storcontext -ErrorAction Stop -ErrorVariable $err | Out-Null
    }
    catch
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Error encountered while copying file to storage") >> $logFilePath
    }

    $result = Get-AzStorageContainer -Name $destContainerName* -Context $storcontext | Get-AzStorageBlob
    if($null -ne $result)
    {
        $result | Out-Null
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully from Disk2 to Destination Storage account") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
        return "Successfully from Disk2 to Destination Storage account"
    }
    else
    {
        $result | Out-Null
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Copy from Disk2 to Destination Storage account Failed") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
        return "Copy from Disk2 to Destination Storage account Failed"
    }
}

$logFilePath = "$PSScriptRoot\logging_copyFilefromDisktoSFTP.txt"

try
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Start") >> $logFilePath
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Executing connectSFTP function...") >> $logFilePath

    #Verification if VM is still connected to azure
    $azctx = Get-AzContext
    if($null -eq $azctx)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"VM is not connected in Azure") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Reconnecting to azure...") >> $logFilePath
        azconnect -subId $subId -subTenantId $subTenantId | Out-Null
    }

    copy_tosftploc($commRG, $zipPath, $destContainerName, $destStorageAccount)
}
catch
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed to Copy File From Disk to SFTP Please check input parameters") >> $logFilePath
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
    return "Failed to Copy File From Disk to SFTP Please check input parameters"
}