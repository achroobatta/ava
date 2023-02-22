param
(
    [Parameter(Mandatory=$true)]
    [string]$localTargetDirectory,
    [Parameter(Mandatory=$true)]
    [string]$keyVaultNameforSecret,
    [Parameter(Mandatory=$true)]
    [int]$taskNumber,
    [Parameter(Mandatory=$true)]
    [string]$buildId,
    [Parameter(Mandatory=$true)]
    [string]$sourceStorageAccount,
    [Parameter(Mandatory=$true)]
    [string]$srcSftpCtn,
    [Parameter(Mandatory=$true)]
    [string]$srcSftpAcctNm,
    [Parameter(Mandatory=$true)]
    [string]$srcSftpPass,
    [Parameter(Mandatory=$true)]
    [string]$srcSftpKey,
    [Parameter(Mandatory=$true)]
    [string]$CBASFTPSourcePath
)

function connectSFTP()
{
    try
    {
        #Get Password/SSH key from Keyvault
        $sshKey = Get-AzKeyVaultSecret -vaultName $keyVaultNameforSecret -name $srcSftpKey -AsPlainText
        $pass = Get-AzKeyVaultSecret -vaultName $keyVaultNameforSecret -name $srcSftpPass

        $Get_My_Scret = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass.SecretValue)
        $Enpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Get_My_Scret)
    }
    catch
    {
        return "Unable to get SFTP Password"
    }

    try
    {
        #Connecting to SFTP
        $string = New-Object System.Net.NetworkCredential("","$Enpassword")
        $sec = $string.SecurePassword
        $pscred = New-Object System.Management.Automation.PSCredential ($srcSftpAcctNm, $sec)
        $sftpSession = New-SFTPSession -ComputerName $srcSftpCtn -Credential $pscred -KeyString $sshKey -Force
    }
    catch
    {
        return "Unable to Connect SFTP with Provided Credentials"
    }

    try
    {
        $sftpPath = $CBASFTPSourcePath.Split(",")
        foreach($value in $sftpPath)
        {

            Get-SFTPItem -SessionId $sftpSession.SessionId -Path $value -Destination $localTargetDirectory

        }

        #Upload file from Disk to Source Storage Account
        $ContainerName = "backupcontainer" + $taskNumber + "-" + $buildId
        $uploadstorage = Get-AzStorageAccount -ResourceGroupName $commRG -Name $sourceStorageAccount
        $storcontext = $uploadstorage.Context
        $sContainer = New-AzStorageContainer -Name $ContainerName -Context $storcontext
        $cname = $sContainer.Name
        Get-ChildItem -Path $localTargetDirectory -File -Recurse | Set-AzStorageBlobContent -Container $cname -Context $storcontext | Out-Null
        if((Get-ChildItem -Path $localTargetDirectory))
        {
            return "Succesfully Copy file from SFTP to Disk1 and Source Storage Account"
        }
        else
        {
            return "Copy file from SFTP to Disk1 and Source Storage Account Failed"
        }

    }
    catch
    {
        return "Unable to Copy File from SFTP to Disk1"
    }
}

try
{
    connectSFTP($localTargetDirectory, $computerName, $userName, $keyVaultNameforSecret, $namePass, $taskNumber, $sftpLocalUser, $sourceStorageAccount, $computerName, $buildId, $srcSftpCtn, $srcSftpAcctNm, $srcSftpPass, $srcSftpKey, $CBASFTPSourcePath)
}
catch
{
    return "Unable to connect to SFTP location"
}