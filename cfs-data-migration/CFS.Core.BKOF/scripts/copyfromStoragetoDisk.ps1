#SCRIPT FOR COPYING FILE FROM STORAGE ACCOUNT TO LOCAL DISK
#create by: Joshua Ira San Ramon
param
(
    [Parameter(Mandatory=$true)]
    [String]$sourceStorageAccount,
    [Parameter(Mandatory=$true)]
    [string]$localTargetDirectory,
    [Parameter(Mandatory=$true)]
    [string]$sourceLocation,
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

Function copy_storage()
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Copying file from storage to disk") >> $logFilePath

    $ctx = New-AzStorageContext -storageAccountName $sourceStorageAccount -UseConnectedAccount

    $containers = $sourceLocation.Split(",")
    foreach($container in $containers)
    {
        $names = @(Get-AzStorageContainer -Name $container* -Context $ctx | Get-AzStorageBlob)
        if ($null -eq $names)
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to get storage blob in the container") >> $logFilePath
        }

        foreach ($name in $names)
        {
            try
            {
                Get-AzStorageBlobContent -Blob $name.name -Container $container -Destination $localTargetDirectory -Context $ctx -ErrorAction Stop -Force | Out-Null
            }
            catch
            {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to copy $($name.name) to the destination: $_") >> $logFilePath
            }
        }
    }

    $result = Get-ChildItem $localTargetDirectory
    if($null -ne $result)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully Copy Zip (password protected file) from Storage to Disk1") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
        return "Successfully Copy Zip (password protected file) from Storage to Disk1"
    }
    else
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Copy Zip (password protected file) from Storage to Disk1 Failed") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
        return "Copy Zip (password protected file) from Storage to Disk1 Failed"
    }
}
$logFilePath = "$PSScriptRoot\logging_copyfromStoragetoDisk.txt"

try
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Start") >> $logFilePath
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Executing copy_storage function...") >> $logFilePath

    $azctx = Get-AzContext
    if($null -eq $azctx)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"VM is not connected in Azure") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Reconnecting to azure...") >> $logFilePath
        azconnect -subId $subId -subTenantId $subTenantId | Out-Null
    }

    copy_storage($sourceStorageAccount, $localTargetDirectory, $sourceLocation)
}
catch
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Copy Zip (password protected file) from Storage to Disk1 Failed") >> $logFilePath
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
    return "Copy Zip (password protected file) from Storage to Disk1 Failed"
}