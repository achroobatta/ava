param
(
    [Parameter(Mandatory=$false)]
    [string]$commRG,
    [Parameter(Mandatory=$false)]
    [string]$localTargetDirectory,
    [Parameter(Mandatory=$false)]
    [string]$keyVaultNameforSecret,
    [Parameter(Mandatory=$false)]
    [int]$taskNumber,
    [Parameter(Mandatory=$false)]
    [string]$buildId,
    [Parameter(Mandatory=$false)]
    [string]$sourceStorageAccount,
    [Parameter(Mandatory=$false)]
    [string]$srcSftpCtn,
    [Parameter(Mandatory=$false)]
    [string]$srcSftpAcctNm,
    [Parameter(Mandatory=$false)]
    [string]$srcSftpPass,
    [Parameter(Mandatory=$false)]
    [string]$srcSftpKey,
    [Parameter(Mandatory=$false)]
    [string]$CBASFTPSourcePath,
    [Parameter(Mandatory=$false)]
    [string]$subId,
    [Parameter(Mandatory=$false)]
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

function connectSFTP()
{
    try
    {
        #SSH key from Keyvault
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Getting Password/SSH key from Keyvault") >> $logFilePath
        $sshKey = Get-AzKeyVaultSecret -vaultName $keyVaultNameforSecret -name $srcSftpKey -AsPlainText
        if ($null -eq $sshKey)
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to get key from Keyvault") >> $logFilePath
            break
        }

        #Password from Keyvault
        $pass = Get-AzKeyVaultSecret -vaultName $keyVaultNameforSecret -name $srcSftpPass
        $Get_My_Scret = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass.SecretValue)
        $Enpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Get_My_Scret)
        if ($null -eq $Enpassword)
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to get password key from Keyvault") >> $logFilePath
            break
        }
    }
    catch
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to get SFTP Password") >> $logFilePath
        return "Unable to get Secret from Key Vault"
    }

    try
    {
        #Connecting to SFTP
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Connecting to SFTP") >> $logFilePath
        $string = New-Object System.Net.NetworkCredential("","$Enpassword")
        $sec = $string.SecurePassword
        $pscred = New-Object System.Management.Automation.PSCredential ($srcSftpAcctNm, $sec)

        $ctnIPs = $srcSftpCtn.Split(",")
        foreach($ctnIP in $ctnIPs)
        {
            $sftpSession = New-SFTPSession -ComputerName $ctnIP -Credential $pscred -KeyString $sshKey -AcceptKey
            if($null -eq $sftpSession)
            {
                continue
            }
            else
            {
                break
            }
        }
    }
    catch
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to Connect SFTP with Provided Credentials: $_") >> $logFilePath
        return "Unable to Connect SFTP with Provided Credentials"
    }

    try
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Getting files from SFTP to Disk") >> $logFilePath
        $sftpPath = $CBASFTPSourcePath.Split(",")
        foreach($value in $sftpPath)
        {
            Get-SFTPItem -SessionId $sftpSession.SessionId -Path $value -Destination $localTargetDirectory
        }

        <#
        #Upload file from Disk to Source Storage Account
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Uploading file from Disk to Source Storage Account") >> $logFilePath
        try
        {
            $uploadstorage = Get-AzStorageAccount -ResourceGroupName $commRG -Name $sourceStorageAccount
        }
        catch
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to get source storage") >> $logFilePath
        }
        try
        {
            $storcontext = $uploadstorage.Context
            $ContainerName = "backupcontainer" + $taskNumber + "-" + $buildId
            $sContainer = New-AzStorageContainer -Name $ContainerName -Context $storcontext
        }
        catch
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to create container") >> $logFilePath
        }

        try
        {
            $cname = $sContainer.Name
            Get-ChildItem -Path $localTargetDirectory -File -Recurse | Set-AzStorageBlobContent -Container $cname -Context $storcontext | Out-Null
        }
        catch
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Error encountered while uploading files") >> $logFilePath
        }#>

        if((Get-ChildItem -Path $localTargetDirectory))
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Succesfully Copy file from SFTP to Disk1 and Source Storage Account") >> $logFilePath
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
            return "Successfully Copy file from SFTP to Disk1 and Source Storage Account"
        }
        else
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Copy file from SFTP to Disk1 and Source Storage Account Failed") >> $logFilePath
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
            return "Copy file from SFTP to Disk1 and Source Storage Account Failed"
        }

    }
    catch
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to Copy File from SFTP to Disk1") >> $logFilePath
        return "Unable to Copy File from SFTP to Disk1"
    }
}

$logFilePath = "$PSScriptRoot\logging_copyFilefromSFTPtoDisk.txt"
try
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Start") >> $logFilePath
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Executing connectSFTP function...") >> $logFilePath

    $azctx = Get-AzContext
    if($null -eq $azctx)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"VM is not connected in Azure") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Reconnecting to azure...") >> $logFilePath
        azconnect -subId $subId -subTenantId $subTenantId | Out-Null
    }

    connectSFTP($commRG, $localTargetDirectory, $keyVaultNameforSecret, $taskNumber, $sourceStorageAccount, $computerName, $buildId, $srcSftpCtn, $srcSftpAcctNm, $srcSftpPass, $srcSftpKey, $CBASFTPSourcePath)
}
catch
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to connect to SFTP location") >> $logFilePath
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
    return "Unable to connect to SFTP location"
}