param
(
    [Parameter(Mandatory = $true)]
    [string]$commRG,
    [Parameter(Mandatory = $true)]
    [string]$keyVaultNameforSecret,
    [Parameter(Mandatory = $true)] #password for the zip inputfile
    [string]$secretName,
    [Parameter(Mandatory = $true)] #parameter for datalake stg and sftp stg
    [String]$destStorageAccount,
    [Parameter(Mandatory = $true)] #parameter for datalake container and sftp container
    [String]$destContainerName,
    [Parameter(Mandatory = $true)] #If the process is in Non-prod or Prod
    [string]$deployEnvironment,
    [Parameter(Mandatory = $true)] #If the process if external or internal
    [string]$targetDataType,
    [Parameter(Mandatory = $true)] #this is the parameter for getting the file from CBA sftp or databox or etl
    [string]$sourceDatatype,
    [Parameter(Mandatory = $false)] #this is the parameter for getting the file from CBA Databox nullable
    [string]$sourceLocation,
    [Parameter(Mandatory = $true)] #set as "na" for default value of the parameter
    [string]$sourceStorageAccountfromPipeline,

    #SFTP Connection
    [Parameter(Mandatory = $false)]
    [string]$srcSftpCtn,
    [Parameter(Mandatory = $false)]
    [string]$srcSftpAcctNm,
    [Parameter(Mandatory = $false)]
    [string]$srcSftpPass,
    [Parameter(Mandatory = $false)]
    [string]$srcSftpKey,
    [Parameter(Mandatory = $false)] #List of full paths of SFTP
    [string]$CBASFTPSourcePath,

    #DevOps Parameters
    [Parameter(Mandatory = $true)]
    [string]$vmRG,
    [Parameter(Mandatory = $true)]
    [string]$sftpUsername,
    [Parameter(Mandatory = $true)]
    [int]$taskNumber,
    [Parameter(Mandatory = $true)]
    [string]$resourceLocation,
    [Parameter(Mandatory = $true)]
    [string]$vmName,
    [Parameter(Mandatory = $true)]
    [string]$diagStorageAccount,
    [Parameter(Mandatory = $true)]
    [string]$emailAddress,
    [Parameter(Mandatory = $true)] #Added as part of the name in created container in sourcestorage
    [string]$buildId,
    [Parameter(Mandatory = $true)]
    [string]$clientEmailAddress,
    [Parameter(Mandatory = $true)]
    [string]$runType,
    [Parameter(Mandatory = $true)]
    [string]$appName,
    [Parameter(Mandatory = $true)]
    [string]$etlDestStorageAccountName,


    #Azure connection
    [Parameter(Mandatory = $true)]
    [string]$subId,
    [Parameter(Mandatory = $true)]
    [string]$subTenantId
)
#-----------------------------------------------------------[Functions]------------------------------------------------------------
#region Functions
Function Main() {

    param
    (
        #dynamic parameters sent by Devops
        [Parameter(Mandatory = $false)]
        [string]$commRG,
        [Parameter(Mandatory = $false)]
        [string]$vmRG,
        [Parameter(Mandatory = $false)]
        [string]$keyVaultNameforSecret,
        [Parameter(Mandatory = $false)]
        [string]$secretName,
        [Parameter(Mandatory = $false)]
        [String]$destStorageAccount,
        [Parameter(Mandatory = $false)]
        [String]$destContainerName,
        [Parameter(Mandatory = $false)]
        [string]$deployEnvironment,
        [Parameter(Mandatory = $false)]
        [string]$targetDataType,
        [Parameter(Mandatory = $false)]
        [string]$sourceDatatype,
        [Parameter(Mandatory = $false)]
        [string]$sourceLocation,
        [Parameter(Mandatory = $false)]
        [string]$buildId,
        [Parameter(Mandatory = $false)]
        [string]$sftpUsername,
        [Parameter(Mandatory = $false)] #set as "default" for default value of the parameter
        [string]$sourceStorageAccountfromPipeline,

        #SFTP Connection
        [Parameter(Mandatory = $false)]
        [string]$srcSftpCtn,
        [Parameter(Mandatory = $false)]
        [string]$srcSftpAcctNm,
        [Parameter(Mandatory = $false)]
        [string]$srcSftpPass,
        [Parameter(Mandatory = $false)]
        [string]$srcSftpKey,
        [Parameter(Mandatory = $false)] #List of full paths of SFTP
        [string]$CBASFTPSourcePath,

        #DevOps Parameters
        [Parameter(Mandatory = $false)]
        [int]$taskNumber,
        [Parameter(Mandatory = $false)]
        [string]$resourceLocation,
        [Parameter(Mandatory = $false)]
        [string]$vmName,
        [Parameter(Mandatory = $false)]
        [string]$diagStorageAccount,
        [Parameter(Mandatory = $false)]
        [string]$emailAddress,
        [Parameter(Mandatory = $false)]
        [string]$clientEmailAddress,
        [Parameter(Mandatory = $false)]
        [string]$runType,
        [Parameter(Mandatory = $false)]
        [string]$appName,
        [Parameter(Mandatory = $false)]
        [string]$etlDestStorageAccountName,

        #Azure connection
        [Parameter(Mandatory = $false)]
        [string]$subId,
        [Parameter(Mandatory = $false)]
        [string]$subTenantId
    )

    #-----------------------------------------------------------[Execution]------------------------------------------------------------
    #region Execution
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Executing CheckRealTimeMonitoring Function") >> $logFilePath
    try {
        $checkRTM = CheckRealTimeMonitoring
    }
    catch {
        Housekeeping -taskNumber $taskNumber -deployEnvironment $deployEnvironment -vmName $vmName -vmRG $vmRG -diagStorageAccount $diagStorageAccount -resourceLocation $resourceLocation -emailAddress $emailAddress -commRG $commRG -sftpUsername $sftpUsername -targetDataType $targetDataType -destStorageAccount $destStorageAccount -destContainerName $destContainerName -keyVaultNameforSecret $keyVaultNameforSecret -clientEmailAddress $clientEmailAddress -runType $runType -manualVerificationEmail 'false' -tvtresult $value -unzipPath $unzipPath -subId $subId -subTenantId $subTenantId -appName $appName -realTimeMonitoringEmail 'true' -stgMisMatch "na" -sourceDatatype $sourceDatatype -threatLogs 'na' -etlDestStorageAccountName $etlDestStorageAccountName
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Extraction process stopped. Failed to check if Microsoft Real Time Monitoring is enabled.") >> $logFilePath
        Display -message "Extraction process stopped. An issue occured while checking if Microsoft Defender is enabled." -psName "Master.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
        break
    }
    if ($checkRTM -eq $true) {
        #static local paths
        $Troot = "T:\"
        $Sroot = "S:\"

        $localTargetDirectory = "$Sroot" + "FromStorageAccount"
        $unzipPath = "$Troot" + "UnzipFile"
        $zipPath = "$Troot" + "EncryptedZipFile"

        # Connect to Azure
        azconnect -subId $subId -subTenantId $subTenantId

        #Source Storage Account
        if ($sourceStorageAccountfromPipeline -eq "na") {
            if ($deployEnvironment -eq "Non-Production") {
                $sourceStorageAccount = "sstornpedcbkofdm001"
            }
            else {
                $sourceStorageAccount = "sstorprdedcbkofdm001"
            }
        }
        else {
            $sourceStorageAccount = $sourceStorageAccountfromPipeline
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Validating if Source Storage Account container have input files") >> $logFilePath

            #Storage Account Verification
            try {
                $ctx = (Get-AzStorageAccount -ResourceGroupName $commRG -Name $sourceStorageAccount).Context
            }
            catch {
                $stgMisMatch = "Error: Mismatch values for sourceStorageAccountFromPipeline: " + $sourceStorageAccountFromPipeline + " sourceLocation: " + $sourceLocation + ". Storage Account: $sourceStorageAccountFromPipeline is not existing in Resource Group: $commRG"
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $stgMisMatch) >> $logFilePath
                Housekeeping -taskNumber $taskNumber -deployEnvironment $deployEnvironment -vmName $vmName -vmRG $vmRG -diagStorageAccount $diagStorageAccount -resourceLocation $resourceLocation -emailAddress $emailAddress -commRG $commRG -sftpUsername $sftpUsername -targetDataType $targetDataType -destStorageAccount $destStorageAccount -destContainerName $destContainerName -keyVaultNameforSecret $keyVaultNameforSecret -clientEmailAddress $clientEmailAddress -runType $runType -manualVerificationEmail "false" -unzipPath $unzipPath -subId $subId -subTenantId $subTenantId -tvtresult " " -appName $appName -realTimeMonitoringEmail 'false' -threatLogs "na" -stgMisMatch $stgMisMatch -sourceDatatype $sourceDatatype  -etlDestStorageAccountName $etlDestStorageAccountName
                break
            }
            #Storage Account Container Verification
            $inputfile = Get-AzStorageContainer -Name $sourceLocation* -Context $ctx | Get-AzStorageBlob
            if ($null -eq $inputfile) {
                $stgMisMatch = "Error: Mismatch values for sourceStorageAccountFromPipeline: " + $sourceStorageAccountFromPipeline + " sourceLocation: " + $sourceLocation + ". Container is not existing or empty in the provided storage account"
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $stgMisMatch) >> $logFilePath
                Housekeeping -taskNumber $taskNumber -deployEnvironment $deployEnvironment -vmName $vmName -vmRG $vmRG -diagStorageAccount $diagStorageAccount -resourceLocation $resourceLocation -emailAddress $emailAddress -commRG $commRG -sftpUsername $sftpUsername -targetDataType $targetDataType -destStorageAccount $destStorageAccount -destContainerName $destContainerName -keyVaultNameforSecret $keyVaultNameforSecret -clientEmailAddress $clientEmailAddress -runType $runType -manualVerificationEmail "false" -unzipPath $unzipPath -subId $subId -subTenantId $subTenantId -tvtresult " " -appName $appName -realTimeMonitoringEmail 'false' -threatLogs "na" -stgMisMatch $stgMisMatch -sourceDatatype $sourceDatatype  -etlDestStorageAccountName $etlDestStorageAccountName
                break
            }
        }

        #Destination Container Name if "Existing"
        if ($destContainerName -eq "existing") {
            #$val = $stg -replace "[a-zA-Z-]",""
            $pos = $destStorageAccount.IndexOf("bkof")
            $rightPart = $destStorageAccount.Substring($pos + 1)

            $strbkof = $rightPart.IndexOf("f")
            $buildno = $rightPart.Substring($strbkof + 1)

            #new value
            $destContainerName = "container" + $buildno
        }
        $CBASFTPSourcePath = ($CBASFTPSourcePath).Replace("*", " ")

        if ($runType -ne "Dryrun" -or $runType -ne "ETLPreprocessDryrun") {
            #Destination Storage Account Verification
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Validating Destination Storage Account and Container if both are existing") >> $logFilePath

            #Storage Account Verification
            try {
                $desctx = (Get-AzStorageAccount -ResourceGroupName $commRG -Name $destStorageAccount).Context
            }
            catch {
                $desMisMatch = "Error: Mismatch values for destStorageAccount: " + $destStorageAccount + ". Storage Account: $destStorageAccount is not existing in Resource Group: $commRG"
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $desMisMatch) >> $logFilePath
                Display -message $desMisMatch -psName "Master.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
                break
            }
            #Storage Account Container Verification
            $desInputFile = Get-AzStorageContainer -Name $destContainerName* -Context $desctx
            if ($null -eq $desInputFile) {
                $desMisMatch = "Error: Mismatch values for destContainerName: " + $destContainerName + ". Container is not existing in the provided storage account"
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $desMisMatch) >> $logFilePath
                Display -message $desMisMatch -psName "Master.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
                break
            }
        }
        #-----------------------------------------------------------[Calling Sub-Scripts]------------------------------------------------------------

        #------------------------
        # Install 7zip
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Executing installZip Function") >> $logFilePath
        try {
            installZip -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
        }
        catch {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Error encountered while installing 7zip") >> $logFilePath
            break
        }

        #------------------------
        #Selection of sourceDatatype
        if ($sourceDatatype -eq "sftp" -and $sourceStorageAccountfromPipeline -eq "na") {
            #------------------------
            # Call Copy From SFTP to Disk1
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Executing triggerSFTP Function") >> $logFilePath
            try {
                triggerSFTP -commRG $commRG -localTargetDirectory $localTargetDirectory -keyVaultNameforSecret $keyVaultNameforSecret -taskNumber $taskNumber -buildId $buildId -sourceStorageAccount $sourceStorageAccount -srcSftpCtn $srcSftpCtn -srcSftpAcctNm $srcSftpAcctNm -srcSftpPass $srcSftpPass -srcSftpKey $srcSftpKey -CBASFTPSourcePath $CBASFTPSourcePath -subId $subId -subTenantId $subTenantId
            }
            catch {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Error encountered while executing triggerSFTP function") >> $logFilePath
                break
            }
        }
        else {
            #------------------------
            # Call copyfromStoragetoDisk
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Executing copyfromStoragetoDisk Function") >> $logFilePath
            try {
                copyfromStoragetoDisk -sourceStorageAccount $sourceStorageAccount -localTargetDirectory $localTargetDirectory -sourceLocation $sourceLocation -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
            }
            catch {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Error encountered whileCopying from Databox to Disk") >> $logFilePath
                break
            }
        }

        #--------------------------
        # Unzip and extract to Disk2
        if ($sourceDatatype -ne "etl") {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Executing UnzipusingKeyVaultSecret Function") >> $logFilePath
            try {
                UnzipusingKeyVaultSecret -keyVaultNameforSecret $keyVaultNameforSecret -secretName $secretName -localTargetDirectory $localTargetDirectory -unzipPath $unzipPath -subId $subId -subTenantId $subTenantId
            }
            catch {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Error encountered while unzipping Zip file to Target Disk") >> $logFilePath
                break
            }
        }

        #--------------------------
        #region Check for Threats
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Executing checkThreatLogs Function") >> $logFilePath
        try {
            $checkThreat = checkThreatLogs -localTargetDirectory $localTargetDirectory
        }
        catch {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Error encountered while executing checkThreatLogs Function") >> $logFilePath
            break
        }

        #endregion

        if ($checkThreat -eq $false) {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Error encountered while executing checkThreatLogs Function") >> $logFilePath
            break
        }
        else {
            $checkThreat = [IO.File]::ReadAllText("$PSScriptRoot\threatLogs.txt")
            #Normal or ETL process selection
            if ($sourceDatatype -eq "etl") {
                #------------------------
                # Copy file from Disk2 to Storage location
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Executing copyFilefromLocaltoStorage Function") >> $logFilePath
                try {
                    copyFilefromLocaltoStorage -commRG $commRG -keyVaultNameforSecret $keyVaultNameforSecret -destStorageAccount $destStorageAccount -unzipPath $localTargetDirectory -destContainerName $destContainerName -zipPath $zipPath -targetDataType $targetDataType -localTargetDirectory $localTargetDirectory  -subId $subId -subTenantId $subTenantId -runType $runType -etlDestStorageAccount $etlDestStorageAccountName
                }
                catch {
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Error encountered while Copying file from Target Disk to Destination Storage Account") >> $logFilePath
                    break
                }

                #------------------------
                #Trigger Housekeeping Pipeline
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Executing Housekeeping Function") >> $logFilePath
                try {
                    Housekeeping -taskNumber $taskNumber -deployEnvironment $deployEnvironment -vmName $vmName -vmRG $vmRG -diagStorageAccount $diagStorageAccount -resourceLocation $resourceLocation -emailAddress $emailAddress -commRG $commRG -sftpUsername $sftpUsername -targetDataType $targetDataType -destStorageAccount $destStorageAccount -destContainerName $destContainerName -keyVaultNameforSecret $keyVaultNameforSecret -clientEmailAddress $clientEmailAddress -runType $runType -manualVerificationEmail "false" -unzipPath $zipPath -subId $subId -subTenantId $subTenantId -tvtresult " " -appName $appName -realTimeMonitoringEmail 'false' -threatLogs $checkThreat -stgMisMatch "na" -sourceDatatype $sourceDatatype -etlDestStorageAccountName $etlDestStorageAccountName
                }
                catch {
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Error encountered while Triggering Housekeeping Pipeline") >> $logFilePath
                    break
                }
            }
            else {
                #--------------------------
                # TVT Checking
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Executing TVT Checking Function") >> $logFilePath
                try {
                    $output = TVTreport -localTargetDirectory $localTargetDirectory -unzipPath $unzipPath -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
                }
                catch {
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Error encountered while executing TVT Checking") >> $logFilePath
                    break
                }

                If ($output -eq $true) {
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "No Mismatch") >> $logFilePath
                    #------------------------
                    # Copy file from Disk2 to Storage location

                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Executing copyFilefromLocaltoStorage Function") >> $logFilePath
                    try {
                        copyFilefromLocaltoStorage -commRG $commRG -keyVaultNameforSecret $keyVaultNameforSecret -destStorageAccount $destStorageAccount -unzipPath $unzipPath -destContainerName $destContainerName -zipPath $zipPath -targetDataType $targetDataType -localTargetDirectory $localTargetDirectory  -subId $subId -subTenantId $subTenantId -runType $runType -etlDestStorageAccount $etlDestStorageAccountName
                    }
                    catch {
                        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Error encountered while Copying file from Target Disk to Destination Storage Account") >> $logFilePath
                        break
                    }
                    #------------------------
                    #Trigger Housekeeping Pipeline
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Executing Housekeeping Function") >> $logFilePath
                    try {
                        Housekeeping -taskNumber $taskNumber -deployEnvironment $deployEnvironment -vmName $vmName -vmRG $vmRG -diagStorageAccount $diagStorageAccount -resourceLocation $resourceLocation -emailAddress $emailAddress -commRG $commRG -sftpUsername $sftpUsername -targetDataType $targetDataType -destStorageAccount $destStorageAccount -destContainerName $destContainerName -keyVaultNameforSecret $keyVaultNameforSecret -clientEmailAddress $clientEmailAddress -runType $runType -manualVerificationEmail "false" -unzipPath $unzipPath  -subId $subId -subTenantId $subTenantId -tvtresult " " -appName $appName -realTimeMonitoringEmail 'false' -threatLogs $checkThreat -stgMisMatch "na" -sourceDatatype $sourceDatatype -etlDestStorageAccountName $etlDestStorageAccountName
                    }
                    catch {
                        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Error encountered while Triggering Housekeeping Pipeline") >> $logFilePath
                        break
                    }
                }
                else {
                    $value = [IO.File]::ReadAllText("$PSScriptRoot\result.txt")
                    Housekeeping -taskNumber $taskNumber -deployEnvironment $deployEnvironment -vmName $vmName -vmRG $vmRG -diagStorageAccount $diagStorageAccount -resourceLocation $resourceLocation -emailAddress $emailAddress -commRG $commRG -sftpUsername $sftpUsername -targetDataType $targetDataType -destStorageAccount $destStorageAccount -destContainerName $destContainerName -keyVaultNameforSecret $keyVaultNameforSecret -clientEmailAddress $clientEmailAddress -runType $runType -manualVerificationEmail "true" -tvtresult $value -unzipPath $unzipPath -subId $subId -subTenantId $subTenantId -appName $appName -realTimeMonitoringEmail 'false' -threatLogs $checkThreat -stgMisMatch "na" -sourceDatatype $sourceDatatype -etlDestStorageAccountName $etlDestStorageAccountName
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Mismatch found please check backend logs and devops logging") >> $logFilePath
                    return "Mismatch found please check backend logs and devops logging"
                }
            }
        }
    }
    elseif ($checkRTM -eq $false) {
        Housekeeping -taskNumber $taskNumber -deployEnvironment $deployEnvironment -vmName $vmName -vmRG $vmRG -diagStorageAccount $diagStorageAccount -resourceLocation $resourceLocation -emailAddress $emailAddress -commRG $commRG -sftpUsername $sftpUsername -targetDataType $targetDataType -destStorageAccount $destStorageAccount -destContainerName $destContainerName -keyVaultNameforSecret $keyVaultNameforSecret -clientEmailAddress $clientEmailAddress -runType $runType -manualVerificationEmail 'false' -tvtresult $value -unzipPath $unzipPath -subId $subId -subTenantId $subTenantId -appName $appName -realTimeMonitoringEmail 'true' -stgMisMatch "na" -sourceDatatype $sourceDatatype -threatLogs 'na' -etlDestStorageAccountName $etlDestStorageAccountName
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Extraction process stopped. Microsoft Defender Real Time Monitoring is not enabled.") >> $logFilePath
        Display -message "Extraction process stopped. Microsoft Defender Real Time Monitoring is not enabled." -psName "Master.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId

    }
    #endregion
}

function CheckRealTimeMonitoring() {
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Checking Real Time Monitoring for Microsoft Defender") >> $logFilePath
    Display -message "Checking Real Time Monitoring for Microsoft Defender" -psName "CheckRealTimeMonitoring.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
    try {
        $output = powershell.exe -file "$PSScriptRoot\CheckRealTimeMonitoring.ps1"
        if ($output -like "*RTM Error:*") {
            foreach ($str in $output) {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $str) >> $logFilePath
            }
            $logDev = $devOpsResult -join "<br>"
            Display -message $logDev -psName "CheckRealTimeMonitoring.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
            return $false
        }
        elseif ($output -like "*Real Time Monitoring Enabled*") {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Real Time Monitoring Enabled") >> $logFilePath
            Display -message "Real Time Monitoring Enabled" -psName "CheckRealTimeMonitoring.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
            return $true

        }
    }
    catch {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
        Display -message "$output" -psName "CheckRealTimeMonitoring.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
        return $false
    }

}
function azconnect() {
    param ($subId, $subTenantId)

    $attempt = 1
    $result = Get-AzContext
    if ($null -eq $result) {
        $azctx = $false
    }
    else {
        $azctx = $true
    }
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Connecting to Azure") >> $logFilePath
    while ($attempt -le 3 -and -not $azctx) {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Attempt $attempt") >> $logFilePath
        try {
            Connect-AzAccount -Identity -Tenant $subTenantId -Subscription $subId -Force
            $result = Get-AzContext
            if ($null -ne $result) {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Connection with azure established") >> $logFilePath
                break
            }
        }
        catch {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Failed to established connection") >> $logFilePath
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Sleep for 60 Seconds") >> $logFilePath
            Start-Sleep -Seconds 60
            if ($attempt -gt 2) {
                Start-Sleep -Seconds 60
            }
        }
        $attempt += 1
    }
    $azresult = Get-AzContext
    if ($null -eq $azresult) {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Unable to established connection") >> $logFilePath
        break
    }
}
function installZip() {
    param ($keyVaultNameforSecret, $subId, $subTenantId)
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Installing 7zip") >> $logFilePath
    Display -message "Installing 7zip" -psName "Install7zip.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
    try {
        $output = powershell.exe -file "$PSScriptRoot\Install7zip.ps1" -keyVaultNameforSecret $keyVaultNameforSecret  -subId $subId -subTenantId $subTenantId
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
        Display -message "$output" -psName "Install7zip.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
    }
    catch {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
        Display -message "$output" -psName "Install7zip.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
    }
}
function triggerSFTP() {
    param ($commRG, $localTargetDirectory, $keyVaultNameforSecret, $taskNumber, $buildId, $sourceStorageAccount, $srcSftpCtn, $srcSftpAcctNm, $srcSftpPass, $srcSftpKey, $CBASFTPSourcePath, $subId, $subTenantId)
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Copying Zip (password protected file) from SFTP to Disk1") >> $logFilePath
    Display -message "Copying Zip (password protected file) from SFTP to Disk1" -psName "copyFilefromSFTPtoDisk.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
    try {
        $output = powershell.exe -file "$PSScriptRoot\copyFilefromSFTPtoDisk.ps1" -localTargetDirectory $localTargetDirectory -keyVaultNameforSecret $keyVaultNameforSecret -taskNumber $taskNumber -buildId $buildId -sourceStorageAccount $sourceStorageAccount -srcSftpCtn $srcSftpCtn -srcSftpAcctNm $srcSftpAcctNm -srcSftpPass $srcSftpPass -srcSftpKey $srcSftpKey -CBASFTPSourcePath $CBASFTPSourcePath -commRG $commRG -subId $subId -subTenantId $subTenantId
        if ($output -like "*Successfully*") {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
            Display -message "$output" -psName "copyFilefromSFTPtoDisk.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
        }
        else {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
            Display -message "$output" -psName "copyFilefromSFTPtoDisk.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
            break
        }
    }
    catch {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Copy Zip (password protected file) from SFTP to Disk1 Failed") >> $logFilePath
        Display -message "Copy Zip (password protected file) from SFTP to Disk1 Failed" -psName "copyFilefromSFTPtoDisk.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
        break
    }
}
function copyfromStoragetoDisk() {
    param ($sourceStorageAccount, $localTargetDirectory, $sourceLocation, $keyVaultNameforSecret, $subId, $subTenantId)
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Copying Zip (password protected file) from Storage Account to Disk1") >> $logFilePath
    Display -message "Copying Zip (password protected file) from Storage to Disk1" -psName "copyfromStoragetoDisk.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
    try {
        $output = powershell.exe -file "$PSScriptRoot\copyfromStoragetoDisk.ps1" -sourceStorageAccount $sourceStorageAccount -localTargetDirectory $localTargetDirectory -sourceLocation $sourceLocation -subId $subId -subTenantId $subTenantId
        if ($output -like "*Successfully*") {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
            Display -message "$output" -psName "copyfromStoragetoDisk.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
        }
        else {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
            Display -message "$output" -psName "copyfromStoragetoDisk.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
            break
        }
    }
    catch {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Copy Zip (password protected file) from Storage to Disk1 Failed") >> $logFilePath
        Display -message "Copy Zip (password protected file) from Storage to Disk1 Failed" -psName "copyFilefromSFTPtoDisk.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
        break
    }
}
function UnzipusingKeyVaultSecret() {
    param ($keyVaultNameforSecret, $secretName, $localTargetDirectory, $unzipPath, $subId, $subTenantId)
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Unzipping and extract to Disk2") >> $logFilePath
    Display -message "Unzipping and extract to Disk2" -psName "UnzipusingKeyVaultSecret.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
    try {
        $output = powershell.exe -file "$PSScriptRoot\UnzipusingKeyVaultSecret.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -secretName $secretName -localzippath $localTargetDirectory -unzipPath $unzipPath -subId $subId -subTenantId $subTenantId
        if ($output -like "*Successfully*") {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
            Display -message $output -psName "UnzipusingKeyVaultSecret.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
        }
        else {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
            Display -message $output -psName "UnzipusingKeyVaultSecret.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
            break
        }
    }
    catch {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Unzip and extract to Disk2 Failed") >> $logFilePath
        Display -message "Unzip and extract to Disk2 Failed" -psName "UnzipusingKeyVaultSecret.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
        break
    }
}
function checkThreatLogs() {
    param($localTargetDirectory)
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Checking Microsoft Defender Logs for Threats") >> $logFilePath
    Display -message "Checking Microsoft Defender Logs for Threats" -psName "CheckThreatReports.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
    try {
        $threat = @()
        $output = powershell.exe -file "$PSScriptRoot\CheckThreatReports.ps1" -localTargetDirectory $localTargetDirectory
        if ($output -like "*Check Threat Error:*") {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
            Display -message $output -psName "CheckThreatReports.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
            return $false
        }
        elseif ($output -like "*Threat Found:*") {
            foreach ($str in $output) {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $str) >> $logFilePath
            }
            $logDev = $output -join "<br>"
            $threat = $output -join "</p><p>"
            Write-Output $threat >> "$PSScriptRoot\threatLogs.txt"
            Display -message $logDev -psName "CheckThreatReports.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
            return $true
        }
        else {
            $threat = "<p>No Threats Found</p>"
            Write-Output $threat >> "$PSScriptRoot\threatLogs.txt"
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "No Threats Found") >> $logFilePath
            Display -message "No Threats Found" -psName "CheckThreatReports.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
            return $true
        }
    }
    catch {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
        Display -message "$output" -psName "CheckThreatReports.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
    }

}
function copyFilefromLocaltoStorage() {
    param ($commRG, $keyVaultNameforSecret, $destStorageAccount, $unzipPath, $destContainerName, $zipPath, $targetDataType, $localTargetDirectory, $subId, $subTenantId, $runType, $etlDestStorageAccount)

    try {
        if ($targetDataType -eq "internal" -or $runType -eq "ETLPreprocessProduction") {
            try {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Copying file from Disk2 to Storage location") >> $logFilePath
                Display -message "Copying file from Disk2 to Storage location" -psName "copyFilefromLocaltoStorage.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId

                $output = powershell.exe -file "$PSScriptRoot\copyFilefromLocaltoStorage.ps1" -commRG $commRG -destStorageAccount $destStorageAccount -unzipPath $unzipPath -destContainerName $destContainerName -subId $subId -subTenantId $subTenantId
                if ($output -like "*Successfully*") {
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
                    Display -message "$output" -psName "copyFilefromLocaltoStorage.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
                }
                else {
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
                    Display -message "$output" -psName "copyFilefromLocaltoStorage.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
                    break
                }
            }
            catch {
                Display -message "Failed to Copy File From Disk to Storage Account" -psName "copyFilefromLocaltoStorage.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Unable to run script copyFilefromLocaltoStorage.ps1") >> $logFilePath
                break
            }
        }
        Else {
            try {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Re-Zipping file using Generated Password") >> $logFilePath
                Display -message "Re-Zipping file using Generated Password" -psName "zipFileUsing7z.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId

                $output = powershell.exe -file "$PSScriptRoot\zipFileUsing7z.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -sftpUsername $sftpUsername -unzipPath $unzipPath -zipPath $zipPath -localTargetDirectory $localTargetDirectory -subId $subId -subTenantId $subTenantId
                if ($output -like "*Successfully*") {
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
                    Display -message "$output" -psName "zipFileUsing7z.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
                }
                else {
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
                    Display -message "$output" -psName "zipFileUsing7z.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
                    break
                }
            }
            catch {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Unable to run script zipFileUsing7z.ps1") >> $logFilePath
                break
            }
            try {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Copying File From Disk to SFTP") >> $logFilePath
                Display -message "Copying File From Disk to SFTP" -psName "copyFilefromDisktoSFTP.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId

                $sftpoutput = powershell.exe -file "$PSScriptRoot\copyFilefromDisktoSFTP.ps1" -commRG $commRG -destStorageAccount $destStorageAccount -zipPath $zipPath -destContainerName $destContainerName -subId $subId -subTenantId $subTenantId
                if ($sftpoutput -like "*Successfully*") {
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $sftpoutput) >> $logFilePath
                    Display -message "$sftpoutput" -psName "copyFilefromDisktoSFTP.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
                }
                else {
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
                    Display -message "$sftpoutput" -psName "copyFilefromDisktoSFTP.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
                    break
                }
            }
            catch {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Failed to Copy File From Disk to SFTP") >> $logFilePath
                Display -message "Failed to Copy File From Disk to SFTP" -psName "copyFilefromDisktoSFTP.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
            }
        }
        if ($etlDestStorageAccount -ne 'na') {
            try {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Copying file from Disk2 to Storage location") >> $logFilePath
                Display -message "Copying file from Disk2 to Storage location" -psName "copyFilefromLocaltoStorage.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
                $output = powershell.exe -file "$PSScriptRoot\copyFilefromLocaltoStorage.ps1" -commRG $commRG -destStorageAccount $etlDestStorageAccountName -unzipPath $unzipPath -destContainerName $destContainerName -subId $subId -subTenantId $subTenantId
                if ($output -like "*Successfully*") {
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
                    Display -message "$output" -psName "copyFilefromLocaltoStorage.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
                }
                else {
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $output) >> $logFilePath
                    Display -message "$output" -psName "copyFilefromLocaltoStorage.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
                    break
                }
            }
            catch {
                Display -message "Failed to Copy File From Disk to Storage Account" -psName "copyFilefromLocaltoStorage.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Unable to run script copyFilefromLocaltoStorage.ps1") >> $logFilePath
                break
            }
        }
    }
    catch {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Copy file from Disk2 to Storage location Failed") >> $logFilePath
        Display -message "Copy file from Disk2 to Storage location Failed" -psName "copyFilefromLocaltoStorage.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
    }
}
function TVTreport() {
    param ($localTargetDirectory, $unzipPath, $keyVaultNameforSecret)
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Generating and Comparing TVT Reports") >> $logFilePath
    Display -message "Generating and Comparing TVT Reports" -psName "reconcilliationReport.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
    try {
        $output = powershell.exe -file "$PSScriptRoot\reconcilliationReport.ps1" -localTargetDirectory $localTargetDirectory -unzipPath $unzipPath
        if ($output -like "*Mismatch Findings*") {
            foreach ($str in $output) {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $str) >> $logFilePath
            }

            $logDev = $output -join "<br>"
            $devReplace = ($logDev).Replace("\", "/")
            Display -message $devReplace -psName "reconcilliationReport.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId

            $var = $output -join "</p><p>"
            $replaceVar = ($var).Replace("\", "/")
            Write-Output $replaceVar >> "$PSScriptRoot\result.txt"
            return $false
        }
        else {
            $joinArray = $output -join ", "
            $replaceVar = ($joinArray).Replace("\", "/")
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Successfully Compared/Generate TVT Report: $replaceVar") >> $logFilePath
            Display -message "Successfully Compared/Generate TVT Report:<br> $replaceVar" -psName "reconcilliationReport.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
            return $true
        }
    }
    catch {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Unable to run TVT Checking Script") >> $logFilePath
        Display -message "Unable to run TVT Checking Script" -psName "reconcilliationReport.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
    }
}
function Display() {
    param([string]$message, [string]$psName, [string]$keyVaultNameforSecret, [string]$subId, [string]$subTenantId)

    $message = $message + " - " + (Get-Date).ToString()
    Write-Output $message;

    $log = "<br><b>Powershell Script:</b> $psName <br> <b>Message:</b> <br> $message<br> "
    powershell.exe -file "$PSScriptRoot\LoggingDevOps.ps1" -WorkItemComment $log -taskNumber $taskNumber -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
}
function Housekeeping() {
    param ($taskNumber, $deployEnvironment, $vmName, $vmRG, $diagStorageAccount, $resourceLocation, $emailAddress, $commRG, $sftpUsername, $targetDataType, $destStorageAccount, $destContainerName, $keyVaultNameforSecret, $clientEmailAddress, $runType, $manualVerificationEmail, $unzipPath, $subId, $subTenantId, $tvtresult, $appName, $realTimeMonitoringEmail, $sourceDatatype, $stgMisMatch, $threatLogs, $etlDestStorageAccountName)
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Triggering Housekeeping Pipeline") >> $logFilePath
    Display -message "Triggering Housekeeping Pipeline" -psName "TriggerHousekeeping.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
    $output = powershell.exe -file "$PSScriptRoot\TriggerHousekeeping.ps1" -taskNumber $taskNumber -deployEnvironment $deployEnvironment -vmName $vmName -vmRG $vmRG -diagStorageAccount $diagStorageAccount -resourceLocation $resourceLocation -emailAddress $emailAddress -commRG $commRG -sftpUsername $sftpUsername -targetDataType $targetDataType -destStorageAccount $destStorageAccount -destContainerName $destContainerName -keyVaultNameforSecret $keyVaultNameforSecret -clientEmailAddress $clientEmailAddress -runType $runType -manualVerificationEmail $manualVerificationEmail -unzipPath $unzipPath -subId $subId -subTenantId $subTenantId -tvtresult $tvtresult -appName $appName -realTimeMonitoringEmail $realTimeMonitoringEmail -sourceDatatype $sourceDatatype -stgMisMatch $stgMisMatch -threatLogs $threatLogs -etlDestStorageAccount $etlDestStorageAccountName
    if ($output -contains $true) {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Successfully Triggered Housekeeping Pipeline") >> $logFilePath
        Display -message "Successfully Triggered Housekeeping Pipeline" -psName "TriggerHousekeeping.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
    }
    else {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Failed Triggered Housekeeping Pipeline") >> $logFilePath
        Display -message "Failed Triggered Housekeeping Pipeline" -psName "TriggerHousekeeping.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -subId $subId -subTenantId $subTenantId
        break
    }
}
Set-Item -path WSMan:\localhost\Shell\IdleTimeout -Value '2147483647'
$DebugPreference = 'Continue'
$VerbosePreference = 'Continue'
Start-Transcript -OutputDirectory $env:HOMEDRIVE\temp\logfiles
$ErrorActionPreference = "Stop"
$logFilePath = "$PSScriptRoot\Master.txt"
Write-Output ("=====================================================================") >> $logFilePath
Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Start") >> $logFilePath
Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "Executing Main function...") >> $logFilePath
Main -commRG $commRG -vmRG $vmRG -keyVaultNameforSecret $keyVaultNameforSecret -secretName $secretName -destStorageAccount $destStorageAccount -destContainerName $destContainerName -deployEnvironment $deployEnvironment -targetDataType $targetDataType -sourceDatatype $sourceDatatype -sourceLocation $sourceLocation -buildId $buildId -sftpUsername $sftpUsername -taskNumber $taskNumber -resourceLocation $resourceLocation -vmName $vmName -diagStorageAccount $diagStorageAccount -emailAddress $emailAddress -srcSftpCtn $srcSftpCtn -srcSftpAcctNm $srcSftpAcctNm -srcSftpPass $srcSftpPass -srcSftpKey $srcSftpKey -CBASFTPSourcePath $CBASFTPSourcePath -clientEmailAddress $clientEmailAddress -runType $runType -subId $subId -subTenantId $subTenantId -appName $appName -sourceStorageAccountfromPipeline $sourceStorageAccountfromPipeline -etlDestStorageAccountName $etlDestStorageAccountName
Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), "End") >> $logFilePath
Stop-Transcript