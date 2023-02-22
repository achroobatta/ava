#UNZIP FILE USING STORED KEY/S IN keyVaultNameforSecret
param
(
    [Parameter(Mandatory=$true)]
    [String]$keyVaultNameforSecret,
    [Parameter(Mandatory=$true)]
    [string]$secretName,
    [Parameter(Mandatory=$true)]
    [string]$localzippath,
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


Function get-secret()
{
    $azctx = Get-AzContext
    if($null -eq $azctx)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"VM is not connected in Azure") >> $logFilePath
        break
    }
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unzipping File using stored keys in key vault") >> $logFilePath

    $sourcePath = Get-ChildItem -Path $localzippath
    $secret = Get-AzKeyVaultSecret -VaultName $keyVaultNameforSecret -Name $secretName -AsPlainText
    if ($null -eq $secret)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to get secret from key vault") >> $logFilePath
    }

    try
    {
        foreach($sPath in $sourcePath)
        {
            $uPath = ("$unzipPath\" + $sPath.BaseName).Replace(" ","_")
            & ${env:ProgramFiles}\7-Zip\7z.exe x $sPath.FullName "-o$($uPath)" -y -p"$secret" | Out-Null
        }
    }
    catch
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable process to unzipped file") >> $logFilePath
    }

    if((Get-ChildItem -Path $unzipPath))
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully Unzip and extract to Disk2") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
        return "Successfully Unzip and extract to Disk2"
    }
    else
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unzip and extract to Disk2 Failed") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
        return "Unzip and extract to Disk2 Failed"
    }
}

$logFilePath = "$PSScriptRoot\logging_UnzipusingKeyVaultSecret.txt"

try
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Start") >> $logFilePath
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Executing get-secret function...") >> $logFilePath

    $azctx = Get-AzContext
    if($null -eq $azctx)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"VM is not connected in Azure") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Reconnecting to azure...") >> $logFilePath
        azconnect -subId $subId -subTenantId $subTenantId | Out-Null
    }

    get-secret($keyVaultNameforSecret,$secretName,$localzippath,$unzipPath)
}
catch
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unzip and extract to Disk2 Failed") >> $logFilePath
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
    return "Unzip and extract to Disk2 Failed"
}