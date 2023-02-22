param(
    [Parameter(Mandatory=$true)]
    [String]$serviceAcctUserName,
    [Parameter(Mandatory=$true)]
    [String]$sshKeyName,
    [Parameter(Mandatory=$true)]
    [String]$rgName,
    [Parameter(Mandatory=$true)]
    [String]$keyVaultName,
    [Parameter(Mandatory=$true)]
    [String]$sftpRg,
    [Parameter(Mandatory=$true)]
    [String]$sftpStorageAcctName,
    [Parameter(Mandatory=$true)]
    [String]$sftpContainerName,
    [Parameter(Mandatory=$true)]
    [String]$sftpUserName
)

Connect-AzAccount -Identity

$currentDirectory = "C:\Users\$serviceAcctUserName\.ssh"
$sshfilePath = "$currentDirectory\*"
if (Test-Path -Path $sshfilePath){
    Remove-Item $sshfilePath
}

$logFilePath = "C:\Users\$serviceAcctUserName\logging_CreateAndUploadSsh.txt"
if (Test-Path -Path $logFilePath){
    Remove-Item $logFilePath
}

$outfile = "C:\Temp\SSH\$sshKeyName.pem"
$outFileFolder = 'C:\Temp\SSH'
$outFilePath = 'C:\Temp\SSH\*'
if (Test-Path -Path $outFileFolder){
    Remove-Item $outFilePath
}
else {
    New-Item -ItemType Directory -Path $outFileFolder
}

New-AzSshKey -ResourceGroupName $rgName -Name $sshKeyName
Write-Output 'Start' > $logFilePath
Write-Output '***********************************************' >> $logFilePath
Get-ChildItem $currentDirectory >> $logFilePath
Remove-Item "$currentDirectory\*.pub"
Get-ChildItem $currentDirectory >> $logFilePath

Write-Output $rgName >> $logFilePath
Write-Output $sshKeyName >> $logFilePath

Copy-Item -Path $sshfilePath -Destination $outfile
$storageAccountkey = (Get-AzStorageAccountKey -ResourceGroupName $sftpRg -Name $sftpStorageAcctName | Where-Object {$_.KeyName -eq "key1"}).Value
$ctx = New-AzStorageContext -StorageAccountName $sftpStorageAcctName -StorageAccountKey $storageAccountkey
Set-AzStorageBlobContent -File $outfile -Container $sftpContainerName -Blob "$sshKeyName.pem" -Context $ctx -Force

$privateKey=Get-Content -Path "$currentDirectory\*" -Encoding "utf8"

$str = ""
          for($i=0; $i -lt $privateKey.Count; $i++)
           {
                Write-Output $privateKey[$i]
                $str = $str+$privateKey[$i]+"`n"
                Write-Output '****'
                Write-Output $str
                Write-Output '$$$$$$$$$$'
           }


#Write-Output $privateKeyEncoded >> $logFilePath
Write-Output $keyVaultName >> $logFilePath
Write-Output $sshKeyName >> $logFilePath

Write-Output "Writing to keyvault now"
# $secretvalue = ConvertTo-SecureString $privateKeyEncoded -AsPlainText -Force
#$secretvalue = ConvertTo-SecureString $privateKeyEncoded
#Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $sshKeyName -SecretValue $secretvalue

$string = New-Object System.Net.NetworkCredential("",$str)
$secretvalue = $string.SecurePassword
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $sshKeyName -SecretValue $secretvalue

Remove-Item "$currentDirectory\*"
Remove-Item $outFilePath
Get-ChildItem $currentDirectory >> $logFilePath
Write-Output '***********************************************' >> $logFilePath
Write-Output 'End' >> $logFilePath


###create and attach SSH Password. upload to KV###
$sshPwName = $sftpUserName+'Password'
$password = New-AzStorageLocalUserSshPassword -ResourceGroupName $sftpRg -StorageAccountName $sftpStorageAcctName -UserName $sftpUserName
$strRaw = ($password.SshPassword | Out-String)
$str = $strRaw.Trim()
$string = New-Object System.Net.NetworkCredential("",$str)
$secretvalue = $string.SecurePassword
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $sshPwName -SecretValue $secretvalue