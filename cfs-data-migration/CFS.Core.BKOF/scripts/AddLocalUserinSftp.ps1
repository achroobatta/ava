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
    [string] $vendorPubKeySecNm,
    [Parameter(Mandatory=$true)]
    [string] $tenantId,
    [Parameter(Mandatory=$true)]
    [string] $subId
)

function create_localUser() {
    ###Create Local User and attach Public Key###
    Write-Output 'Start'
    Write-Output '***********************************************'
    Write-Output 'Retrieving Public Key Value from Key Vault secret'

    $pubKey = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $vendorPubKeySecNm -AsPlainText

    if ($null -ne $pubKey) {
        Write-Output 'Successfully retrieved Public Key from Key Vault'
        Write-Output '***********************************************'
        Write-Output 'Creating Local user and attaching public key'
        $sshkey = New-AzStorageLocalUserSshPublicKey -Key $pubKey -Description "sshpulickey"
        $permissionScope = New-AzStorageLocalUserPermissionScope -Permission rl -Service blob -ResourceName $sftpContainerName

        if (($null -ne $sshkey) -and ($null -ne $permissionScope)) {
            $localuser = Set-AzStorageLocalUser -ResourceGroupName $sftpRg -AccountName $sftpStorageAcctName -UserName $sftpUserName -HomeDirectory $sftpContainerName -SshAuthorizedKey $sshkey -PermissionScope $permissionScope

            if ($null -ne $localuser) {
               Write-Output 'Successfully Created Local user and attached public key'
               Write-Output '***********************************************'
            }
            else {
               Write-Error 'Unable to create Local user and attach public key'
               return 'Failed. Unable to create Local user and attach public key'
            }
        }
        else
        {
            Write-Error 'Key or Permission Scope is empty'
        }
    }
    else {
        Write-Error 'Unable to retrieve Public Key from Key Vault'
        return 'Failed. Unable to retrieve Public Key from Key Vault'
    }

    ###create and attach SSH Password. upload to KV###
    Write-Output 'Attaching SSH password'
    $sshPwName = $sftpUserName+'SSHAuthPassword'
    $localUserPwVName = "Pwd not generated. Please contact CFS"
    $password = New-AzStorageLocalUserSshPassword -ResourceGroupName $sftpRg -StorageAccountName $sftpStorageAcctName -UserName $sftpUserName


    if ($null -ne $password){
        # Set variable in DevOps Pipeline with Password value
            #Write-Output "##vso[task.setvariable variable=$localUserPwVName;isOutput=true]$password"
        $localUserPwVName = $password

        Write-Output 'Successfully attached password to local user'
        Write-Output '***********************************************'

        $strRaw = ($password.SshPassword | Out-String)
        $str = $strRaw.Trim()
        $string = New-Object System.Net.NetworkCredential("",$str)
        $secretvalue = $string.SecurePassword

        Write-Output 'Uploading SSH password to key vault'
        $kvpw = Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $sshPwName -SecretValue $secretvalue

        if ($null -ne $kvpw){
            Write-Output 'Successfully added password to key vault'
            Write-Output '***********************************************'
        }
        else {
            Write-Error 'Unable to add password to key vault'
            return 'Failed. Unable to add password to key vault'
        }

        Write-Output '************************************************'
        Write-Output $sftpRg
        Write-Output $sftpStorageAcctName
        Write-Output $sftpContainerName
        Write-Output $keyVaultName
        Write-Output '************************************************'
        return $localUserPwVName
    }
    else {
            # Write-Output "##vso[task.setvariable variable=$localUserPwVName;isOutput=true]$localUserPwVNameDefault"
        return 'Failed. Unable to generate and send password'
        return $localUserPwVName
        Write-Error 'Unable to generate and send password'
    }
}

Write-Output 'sftUserName: ' $sftpUserName
$attempt = 1
$result = Get-AzContext
if($null -eq $result) {
   $azctx = $false
}
else {
   $azctx = $true
}
while($attempt -le 3 -and -not $azctx)
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Connecting to Azure")
    try
    {
        Connect-AzAccount -Identity -Tenant $tenantId -Subscription $subId -Force
        $result = Get-AzContext
        if($null -ne $result) {
        $azctx = $true
        }
    }
    catch
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Sleeping for 15 Seconds, before next attempt")
        Start-Sleep -Seconds 60
        if($attempt -gt 2)
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Sleeping for Additional 15 Seconds, before final attempt")
            Start-Sleep -Seconds 60
        }
    }
    $attempt += 1
}

if ($azctx -eq  $true) {
    Write-Output 'Subscription Value:' $subId
    Set-AzContext -Subscription $subId -Force
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Connection Established, Trying to create Local User")
    create_localUser ($sftpRg, $sftpStorageAcctName, $sftpContainerName, $sftpUserName, $keyVaultName, $vendorPubKeySecNm)
    Disconnect-AzAccount
    Clear-AzContext -Force
}
else
{
    return "Failed. Unable to Add Local User in SFTP"
}

