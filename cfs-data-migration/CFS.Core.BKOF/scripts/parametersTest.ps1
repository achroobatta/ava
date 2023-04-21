param (
    [string]$taskNumber,
    [string]$resourceLocation,
    [string]$deployEnvironment,
    [string]$sourceDataType,
    [string]$sourceLocation,
    [string]$targetDataType,
    [string]$secretName,
    [string]$keyVaultNameforSecret,
    [string]$emailAddress,
    [string]$destStorageAccount,
    [string]$destContainerName,
    [string]$vmName,
    [string]$diagStorageAccount,
    [int]$buildId,
    [string]$commRG,
    [string]$vmRG,
    [string]$srcSftpCtn,
    [string]$srcSftpAcctNm,
    [string]$srcSftpPass,
    [string]$srcSftpKey,
    [string]$CBASFTPSourcePath,
    [string]$clientEmailAddress,
    [string]$runType,
    [string]$subId,
    [string]$subTenantId,
    [string]$sftpUserName,
    [string]$appName
)
$outFile = "$env:USERPROFILE\MasterParameters.txt"

if (Test-Path -Path $outFile) {
    Remove-Item $outFile
}

Write-Output "taskNumber: $taskNumber" > $outFile
Write-Output "resourceLocation: $resourceLocation" >> $outFile
Write-Output "deployEnvironment: $deployEnvironment" >> $outFile
Write-Output "sourceDataType: $sourceDataType" >> $outFile
Write-Output "sourceLocation: $sourceLocation" >> $outFile
Write-Output "targetDataType: $targetDataType" >> $outFile
Write-Output "secretName: $secretName" >> $outFile
Write-Output "keyVaultNameforSecret: $keyVaultNameforSecret" >> $outFile
Write-Output "emailAddress: $emailAddress" >> $outFile
Write-Output "destStorageAccount: $destStorageAccount" >> $outFile
Write-Output "destContainerName: $destContainerName" >> $outFile
Write-Output "vmName: $vmName" >> $outFile
Write-Output "diagStorageAccount: $diagStorageAccount" >> $outFile
Write-Output "buildId: $buildId" >> $outFile
Write-Output "commRG: $commRG" >> $outFile
Write-Output "vmRG: $vmRG" >> $outFile
Write-Output "srcSftpCtn: $srcSftpCtn" >> $outFile
Write-Output "srcSftpAcctNm: $srcSftpAcctNm" >> $outFile
Write-Output "srcSftpPass: $srcSftpPass" >> $outFile
Write-Output "srcSftpKey: $srcSftpKey" >> $outFile
Write-Output "CBASFTPSourcePath: $CBASFTPSourcePath" >> $outFile
Write-Output "clientEmailAddress: $clientEmailAddress" >> $outFile
Write-Output "runType: $runType" >> $outFile
Write-Output "subId: $subId" >> $outFile
Write-Output "subTenantId: $subTenantId" >> $outFile
Write-Output "sftpUserName: $sftpUserName" >> $outFile
Write-Output "appName: $appName" >> $outFile