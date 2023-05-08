<#
.SYNOPSIS
 Validate Input Parameter File
.DESCRIPTION
  This script will be used to validate input parameter file.

.NOTES
  Version:        1.0
  Author:         Abaigail Rose Artagame
  Creation Date:  8/3/2023
  Purpose/Change: Initial script development

#>


#-----------------------------------------------------------[Declarations]------------------------------------------------------------
#Parameters

# No Parameters needed
#-----------------------------------------------------------[Functions]------------------------------------------------------------
param(
    [string]$runType,
    [string]$destStorageAccount,
    [string]$appName,
    [string]$owner,
    [string]$costCenterCode,
    [string]$warrantyPeriod,
    [string]$deployEnvironment,
    [string]$fileSize,
    [string]$sourceDataType,
    [string]$sourceLocation,
    [string]$srcSftpCtn,
    [string]$srcSftpAcctNm,
    [string]$srcSftpPass,
    [string]$srcSftpKey,
    [string]$CBASFTPSourcePath,
    [string]$secretName,
    [string]$keyVaultNameforSecret,
    [string]$targetDataType,
    [string]$vendorName,
    [string]$ipTobeWhiteListed,
    [string]$ExternalHighPortForSFTP,
    [string]$vendorSuppliedPubKey,
    [string]$emailAddress,
    [string]$ExternalVendorEmailContact,
    [string]$sourceStorageAccountFromPipeline

)
#-----------------------------------------------------------[Execution]------------------------------------------------------------
$errorResult = @()

#Validation null or empty or space for each parameter is not accepted
foreach ($scriptParam in $PSBoundParameters.GetEnumerator()) {

    if ([string]::IsNullOrEmpty($scriptParam.Value) -or [string]::IsNullOrWhitespace($scriptParam.Value)) {
        $errorResult += "Error: " + $scriptParam.Key + " is null or empty or has a value of space."
    }

}
#Validation runType -eq Production, destStorageAccount -ne new OR  runType -eq DryRun, destStorageAccount -eq new
if ($runType -eq "Production" -and $destStorageAccount -eq "new" )
{
    $errorResult += "Error: Mismatch values for runType: " + $runType + " and destStorageAccount: " + $destStorageAccount + ". For runType = 'Dryrun', DestStorageAccount should be 'new', otherwise for runType = 'Production', DestStorageAccount intended for this extraction should be filled"

}
#Validation runType -eq Production, destStorageAccount -ne new OR  runType -eq DryRun, destStorageAccount -eq new
if ($runType -eq "Dryrun" -and $destStorageAccount -ne "new" ) {
    $errorResult += "Error: Mismatch values for runType: " + $runType + " and destStorageAccount: " + $destStorageAccount + ". For runType = 'Dryrun', DestStorageAccount should be 'new', otherwise for runType = 'Production', DestStorageAccount intended for this extraction should be filled"
}

#Validation appName should not be longer than 57 characters. Special characters allowed are Hyphens(-), space and underscore(_)
$appNameSpecialCharacterCheck = "^[a-zA-Z0-9\s_-]+$"
if (($appName.Length -gt 57) -or ($appName -notmatch $appNameSpecialCharacterCheck) ) {
    $errorResult += "Error: appName: " + $appName + " should not be longer than 57 characters and only allowed special characters are the ff: Hyphens(-), space ( ) and underscore(_)"
}

#Validation fileSize MB, GB and TB should be define
$validationList = 'KB', 'MB', 'GB', 'TB'
foreach($validator in $validationList)
{
    if($fileSize.Contains($validator))
    {
        $fileSizeValid = $true
    }
}
if($fileSizeValid -ne $true)
{
    $errorResult += "Error: fileSize: " + $fileSize + " should contain KB, MB, GB, or TB"
}
#Validation if sftp, sourceLocation should be na
if ($sourceDataType -eq "sftp" -and $sourceLocation -ne "na") {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType + " sourceLocation: " + $sourceLocation + ". For sourceDataType = 'sftp', sourceLocation should be 'na'"
}
#Validation if sftp, srcSftpCtn should not be na
if ($sourceDataType -eq "sftp" -and $srcSftpCtn -eq "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " srcSftpCtn: " + $srcSftpCtn + ". For sourceDataType = 'sftp', srcSftpCtn should not be 'na'"
}
#Validation if sftp, srcSftpAcctNm should not be na
if ($sourceDataType -eq "sftp" -and $srcSftpAcctNm -eq "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " srcSftpAcctNm: " + $srcSftpAcctNm + ". For sourceDataType = 'sftp', srcSftpAcctNm should not be 'na'"
}
#Validation if sftp, srcSftpPass should not be na
if ($sourceDataType -eq "sftp" -and $srcSftpPass -eq "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " srcSftpPass: " + $srcSftpPass + ". For sourceDataType = 'sftp', srcSftpPass should not be 'na'"
}
#Validation if sftp, srcSftpKey should not be na
if ($sourceDataType -eq "sftp" -and $srcSftpKey -eq "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " srcSftpKey: " + $srcSftpKey + ". For sourceDataType = 'sftp', srcSftpKey should not be 'na'"
}
#Validation if sftp, CBASFTPSourcePath should not be na
if ($sourceDataType -eq "sftp" -and $CBASFTPSourcePath -eq "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " CBASFTPSourcePath: " + $CBASFTPSourcePath + ". For sourceDataType = 'sftp', CBASFTPSourcePath should not be 'na'"
}
#Validation sftp sourceStorageAccountFromPipeline should be na
if ($sourceDataType -eq "sftp" -and $sourceStorageAccountFromPipeline -ne "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " sourceStorageAccountFromPipeline: " + $sourceStorageAccountFromPipeline + ". For sourceDataType = 'sftp', sourceStorageAccountFromPipeline should be 'na'"
}

#Validation if databox, sourceLocation should not be na
if ($sourceDataType -eq "databox" -and $sourceLocation -eq "na") {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType + " sourceLocation: " + $sourceLocation + ". For sourceDataType = 'databox', sourceLocation should not be 'na'"
}
#Validation if sftp, srcSftpCtn should be na
if ($sourceDataType -eq "databox" -and $srcSftpCtn -ne "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " srcSftpCtn: " + $srcSftpCtn + ". For sourceDataType = 'databox', srcSftpCtn should be 'na'"
}
#Validation if sftp, srcSftpAcctNm should be na
if ($sourceDataType -eq "databox" -and $srcSftpAcctNm -ne "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " srcSftpAcctNm: " + $srcSftpAcctNm + ". For sourceDataType = 'databox', srcSftpAcctNm should be 'na'"
}
#Validation if sftp, srcSftpPass should be na
if ($sourceDataType -eq "databox" -and $srcSftpPass -ne "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " srcSftpPass: " + $srcSftpPass + ". For sourceDataType = 'databox', srcSftpPass should be 'na'"
}
#Validation if sftp, srcSftpKey should be na
if ($sourceDataType -eq "databox" -and $srcSftpKey -ne "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " srcSftpKey: " + $srcSftpKey + ". For sourceDataType = 'databox', srcSftpKey should be 'na'"
}
#Validation if sftp, CBASFTPSourcePath should be na
if ($sourceDataType -eq "databox" -and $CBASFTPSourcePath -ne "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " CBASFTPSourcePath: " + $CBASFTPSourcePath + ". For sourceDataType = 'databox', CBASFTPSourcePath should be 'na'"
}

#Validation databox sourceStorageAccountFromPipeline should be na
if ($sourceDataType -eq "databox" -and $sourceStorageAccountFromPipeline -ne "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " sourceStorageAccountFromPipeline: " + $sourceStorageAccountFromPipeline + ". For sourceDataType = 'databox', sourceStorageAccountFromPipeline should be 'na'"
}

#Validation CBASFTPSourcePath, Special characters allowed are Hyphens(-), space, underscore(_), forward slash (/) and comma (,)
$CBASFTPSourcePathSpecialCharacterCheck = "^[a-zA-Z0-9,/\s_-]+$"

if ($CBASFTPSourcePath -notmatch $CBASFTPSourcePathSpecialCharacterCheck) {
    $errorResult += "Error: CBASFTPSourcePath: " + $CBASFTPSourcePath + " should only contain the following special characters: Hyphens(-), space ( ), underscore(_), forward slash (/), and comma (,)"
}

#Validation internal vendorName should be na
if ($targetDataType -eq "internal" -and $vendorName -ne "na") {
    $errorResult += "Error: Mismatch values for targetDataType: " + $targetDataType + " vendorName: " + $vendorName + ". For targetDataType = 'internal', vendorName should be 'na'"
}
#Validation internal ipTobeWhiteListed should be na
if ($targetDataType -eq "internal" -and $ipTobeWhiteListed -ne "na") {
    $errorResult += "Error: Mismatch values for targetDataType: " + $targetDataType + " ipTobeWhiteListed: " + $ipTobeWhiteListed + ". For targetDataType = 'internal', ipTobeWhiteListed should be 'na'"
}
#Validation internal ExternalHighPortForSFTP should be na
if ($targetDataType -eq "internal" -and $ExternalHighPortForSFTP -ne "na") {
    $errorResult += "Error: Mismatch values for targetDataType: " + $targetDataType + " ExternalHighPortForSFTP: " + $ExternalHighPortForSFTP + ". For targetDataType = 'internal', ExternalHighPortForSFTP should be 'na'"
}
#Validation internal ExternalVendorEmailContact should be na
if ($targetDataType -eq "internal" -and $ExternalVendorEmailContact -ne "na") {
    $errorResult += "Error: Mismatch values for targetDataType: " + $targetDataType + " ExternalVendorEmailContact: " + $ExternalVendorEmailContact + ". For targetDataType = 'internal', ExternalVendorEmailContact should be 'na'"
}
#Validation internal vendorSuppliedPubKey should be na
if ($targetDataType -eq "internal" -and $vendorSuppliedPubKey -ne "na") {
    $errorResult += "Error: Mismatch values for targetDataType: " + $targetDataType + " vendorSuppliedPubKey: " + $vendorSuppliedPubKey + ". For targetDataType = 'internal', vendorSuppliedPubKey should be 'na'"
}


#Validation external vendorName should not be na
if ($targetDataType -eq "external" -and $vendorName -eq "na") {
    $errorResult += "Error: Mismatch values for targetDataType: " + $targetDataType + " vendorName: " + $vendorName + ". For targetDataType = 'external', vendorName should not be 'na'"
}

#Validation external ipTobeWhiteListed should not be na
if ($targetDataType -eq "external" -and $ipTobeWhiteListed -eq "na") {
    $errorResult += "Error: Mismatch values for targetDataType: " + $targetDataType + " ipTobeWhiteListed: " + $ipTobeWhiteListed + ". For targetDataType = 'external', ipTobeWhiteListed should not be 'na'"
}
#Validation external ExternalHighPortForSFTP should not be na
if ($targetDataType -eq "external" -and $ExternalHighPortForSFTP -eq "na") {
    $errorResult += "Error: Mismatch values for targetDataType: " + $targetDataType + " ExternalHighPortForSFTP: " + $ExternalHighPortForSFTP + ". For targetDataType = 'external', ExternalHighPortForSFTP should not be 'na'"
}
#Validation external ExternalVendorEmailContact should not be na
if ($targetDataType -eq "external" -and $ExternalVendorEmailContact -eq "na") {
    $errorResult += "Error: Mismatch values for targetDataType: " + $targetDataType + " ExternalVendorEmailContact: " + $ExternalVendorEmailContact + ". For targetDataType = 'external', ExternalVendorEmailContact should not be 'na'"
}
#Validation external vendorSuppliedPubKey should not be na
if ($targetDataType -eq "external" -and $vendorSuppliedPubKey -eq "na") {
    $errorResult += "Error: Mismatch values for targetDataType: " + $targetDataType + " vendorSuppliedPubKey: " + $vendorSuppliedPubKey + ". For targetDataType = 'external', vendorSuppliedPubKey should not be 'na'"
}

#Validation etl runType should be Production
if ($sourceDataType -eq "etl" -and $runType -ne "Production" ) {
    $errorResult += "Error: Mismatch values for runType: " + $runType + " and sourceDataType: " + $sourceDataType + ". For sourceDataType = 'etl', runType should be 'Production'"
}
#Validation etl sourceStorageAccountFromPipeline should not be na
if ($sourceDataType -eq "etl" -and $sourceStorageAccountFromPipeline -eq "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " sourceStorageAccountFromPipeline: " + $sourceStorageAccountFromPipeline + ". For sourceDataType = 'etl', sourceStorageAccountFromPipeline should not be 'na'"
}

#Validation etl sourceLocation should not be na
if ($sourceDataType -eq "etl" -and $sourceLocation -eq "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " sourceLocation: " + $sourceLocation + ". For sourceDataType = 'etl', sourceLocation should not be 'na'"
}
#Validation if etl, srcSftpCtn should be na
if ($sourceDataType -eq "etl" -and $srcSftpCtn -ne "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " srcSftpCtn: " + $srcSftpCtn + ". For sourceDataType = 'etl', srcSftpCtn should be 'na'"
}
#Validation if etl, srcSftpAcctNm should be na
if ($sourceDataType -eq "etl" -and $srcSftpAcctNm -ne "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " srcSftpAcctNm: " + $srcSftpAcctNm + ". For sourceDataType = 'etl', srcSftpAcctNm should be 'na'"
}
#Validation if etl, srcSftpPass should be na
if ($sourceDataType -eq "etl" -and $srcSftpPass -ne "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " srcSftpPass: " + $srcSftpPass + ". For sourceDataType = 'etl', srcSftpPass should be 'na'"
}
#Validation if etl, srcSftpKey should be na
if ($sourceDataType -eq "etl" -and $srcSftpKey -ne "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " srcSftpKey: " + $srcSftpKey + ". For sourceDataType = 'etl', srcSftpKey should be 'na'"
}
#Validation if etl, CBASFTPSourcePath should be na
if ($sourceDataType -eq "etl" -and $CBASFTPSourcePath -ne "na" ) {
    $errorResult += "Error: Mismatch values for sourceDataType: " + $sourceDataType +  " CBASFTPSourcePath: " + $CBASFTPSourcePath + ". For sourceDataType = 'etl', CBASFTPSourcePath should be 'na'"
}

#Validation ETLPreProcess can be true if targetDataType is external
if (($runType -eq "ETLPreprocessDryrun" -and $targetDataType -ne "external") -or ($runType -eq "ETLPreprocessProduction" -and $targetDataType -ne "external") ) {
    $errorResult += "Error: Mismatch values for runType: " + $runType +  " targetDataType: " + $targetDataType + ". For runType = 'ETLPreprocessDryrun' or runType = 'ETLPreprocessProduction', targetDataType should be 'external'"
}

#Validation ETLPreprocessDryrun can be true if sourceDataType is etl
if ($runType -eq "ETLPreprocessDryrun" -and $sourceDataType -eq "etl") {
    $errorResult += "Error: Mismatch values for runType: " + $runType +  " sourceDataType: " + $sourceDataType + ". For runType = 'ETLPreprocessDryrun', sourceDataType should be 'sftp' or 'databox'"
}

#Validation ETLPreprocessProduction can be true if sourceDataType is etl
if ($runType -eq "ETLPreprocessProduction" -and $sourceDataType -eq "etl") {
    $errorResult += "Error: Mismatch values for runType: " + $runType +  " sourceDataType: " + $sourceDataType + ". For runType = 'ETLPreprocessProduction', sourceDataType should be 'sftp' or 'databox'"
}

#Validation ETLPreprocessProduction can be true if destStorageAccount is new
if ($runType -eq "ETLPreprocessProduction" -and $destStorageAccount -eq "new") {
    $errorResult += "Error: Mismatch values for runType: " + $runType +  " destStorageAccount: " + $destStorageAccount + ". For runType = 'ETLPreprocessProduction', destStorageAccount should not be 'new', DestStorageAccount intended for this extraction should be filled"
}

#Validation ETLPreprocessDryrun can be true if destStorageAccount is not new
if ($runType -eq "ETLPreprocessDryrun" -and $destStorageAccount -ne "new") {
    $errorResult += "Error: Mismatch values for runType: " + $runType +  " destStorageAccount: " + $destStorageAccount + ". For runType = 'ETLPreprocessDryrun', destStorageAccount should be 'new'"
}

if($errorResult -gt 0)
{
    $errorResult = $errorResult -join "</p><p>"
    $errorResult = "<p>" + $errorResult + "</p>"
}
else{
    $errorResult = "Validation Passed"
}

#Save Error as Stage Output Variable
Write-Output "##vso[task.setvariable variable=ValidationResult;isOutput=true]$errorResult"

