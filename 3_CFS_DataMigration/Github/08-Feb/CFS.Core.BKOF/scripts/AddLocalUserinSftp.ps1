param(
    [Parameter(Mandatory=$true)]
    [String]$sftpRg,
    [Parameter(Mandatory=$true)]
    [String]$sftpStorageAcctName,
    [Parameter(Mandatory=$true)]
    [String]$sftpContainerName,
    [Parameter(Mandatory=$true)]
    [String]$sftpUserName,
    [Parameter(Mandatory=$true)]
    [String]$keyVaultName,
    [Parameter(Mandatory=$true)]
    [string] $vendorPubKeySecNm
)

$logFilePath = "$env:USERPROFILE\logging_AddLocalUserinSFTP.txt"
if (Test-Path -Path $logFilePath){
    Remove-Item $logFilePath
}

###connecting to Azure###
try {
    Write-Output 'Connecting to Azure' >> $logFilePath
    $acnt = Connect-AzAccount -identity -Verbose -Force -ErrorAction Stop
        if ($null -ne $acnt){
            Write-Output $acnt >> $logFilePath
        }
    }
catch{
    Write-Output 'Unable to connect to Azure' >> $logFilePath
    return "Unable to connect to Azure"
    Break
    }

###Create Local User and attach Public Key###
Write-Output 'Start' >> $logFilePath
Write-Output '***********************************************' >> $logFilePath
Write-Output 'Retrieving Public Key Value from Key Vault secret' >> $logFilePath
$pubKey = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $vendorPubKeySecNm -AsPlainText
#$sftpUserName = $sftpContainerName+'user'

if ($null -ne $pubKey){
    Write-Output 'Successfully retrieved Public Key from Key Vault' >> $logFilePath
    Write-Output '***********************************************' >> $logFilePath
    Write-Output 'Creating Local user and attaching public key' >> $logFilePath
    $sshkey = New-AzStorageLocalUserSshPublicKey -Key $pubKey -Description "sshpulickey"
    $permissionScope = New-AzStorageLocalUserPermissionScope -Permission rl -Service blob -ResourceName $sftpContainerName
    if (($null -ne $sshkey) -and ($null -ne $permissionScope)){
    $localuser = Set-AzStorageLocalUser -ResourceGroupName $sftpRg -AccountName $sftpStorageAcctName -UserName $sftpUserName -HomeDirectory $sftpContainerName -SshAuthorizedKey $sshkey -PermissionScope $permissionScope
        if ($null -ne $localuser){
        Write-Output 'Successfully Created Local user and attached public key' >> $logFilePath
        Write-Output '***********************************************' >> $logFilePath
        }
        else
        {
        Write-Output 'Unabled to create Local user and attach public key' >> $logFilePath
        Write-Output '***********************************************' >> $logFilePath
        }
    }
    else
    {
    Write-Output 'Key or Permission Scope is empty' >> $logFilePath
    }
}
else
{
    Write-Output 'Unable to retrieve Public Key from Key Vault' >> $logFilePath
}

###create and attach SSH Password. upload to KV###
Write-Output 'Attaching SSH password' >> $logFilePath
$sshPwName = $sftpUserName+'Password'
$localUserPwVName = "Pwd not generated. Please contact CFS"
$password = New-AzStorageLocalUserSshPassword -ResourceGroupName $sftpRg -StorageAccountName $sftpStorageAcctName -UserName $sftpUserName


    if ($null -ne $password){
    # Set variable in DevOps Pipeline with Password value
        #Write-Output "##vso[task.setvariable variable=$localUserPwVName;isOutput=true]$password"
        $localUserPwVName = $password

        Write-Output 'Successfully attached password to local user' >> $logFilePath
        Write-Output '***********************************************' >> $logFilePath

        $strRaw = ($password.SshPassword | Out-String)
        $str = $strRaw.Trim()
        $string = New-Object System.Net.NetworkCredential("",$str)
        $secretvalue = $string.SecurePassword

        Write-Output 'Uploading SSH password to key vault' >> $logFilePath
        $kvpw = Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $sshPwName -SecretValue $secretvalue
            if ($null -ne $kvpw){
                Write-Output 'Successfully added password to key vault' >> $logFilePath
                Write-Output '***********************************************' >> $logFilePath
            }
            else {
                Write-Output 'Unable to add password to key vault' >> $logFilePath
                Write-Output '***********************************************' >> $logFilePath
            }

            Write-Output '************************************************' >> $logFilePath
            Write-Output $sftpRg >> $logFilePath
            Write-Output $sftpStorageAcctName >> $logFilePath
            Write-Output $sftpContainerName >> $logFilePath
            Write-Output $keyVaultName >> $logFilePath
            Write-Output '************************************************' >> $logFilePath
            return $localUserPwVName
    }
    else {
        # Write-Output "##vso[task.setvariable variable=$localUserPwVName;isOutput=true]$localUserPwVNameDefault"
        return $localUserPwVName
        Write-Output 'Unable to generate and send password' >> $logFilePath
    }

Disconnect-AzAccount -ErrorAction Stop