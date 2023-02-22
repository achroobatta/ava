param
(
     [Parameter(Mandatory=$true)]
     [string]$commRG,
     [Parameter(Mandatory=$true)]
     [string]$keyVaultNameforSecret,
     [Parameter(Mandatory=$true)]
     [string]$secretName,
     [Parameter(Mandatory=$true)] #parameter for datalake stg and sftp stg
     [String]$destStorageAccount,
     [Parameter(Mandatory=$true)] #parameter for datalake container and sftp container
     [String]$destContainerName,
     [Parameter(Mandatory=$true)] #If the process is in Non-prod or Prod
     [string]$deployEnvironment,
     [Parameter(Mandatory=$true)] #If the process if external or internal
     [string]$targetDataType,
     [Parameter(Mandatory=$true)] #this is the parameter for getting the file from CBA sftp or databox
     [string]$sourceDatatype,
     [Parameter(Mandatory=$false)] #this is the parameter for getting the file from CBA Databox nullable
     [string]$sourceLocation,

     #SFTP Connection
     [Parameter(Mandatory=$false)]
     [string]$srcSftpCtn,
     [Parameter(Mandatory=$false)]
     [string]$srcSftpAcctNm,
     [Parameter(Mandatory=$false)]
     [string]$srcSftpPass,
     [Parameter(Mandatory=$false)]
     [string]$srcSftpKey,

     #DevOps Parameters
     [Parameter(Mandatory=$true)]
     [string]$vmRG,
     [Parameter(Mandatory=$true)]
     [string]$sftpLocalUser,
     [Parameter(Mandatory=$true)]
     [int]$taskNumber,
     [Parameter(Mandatory=$true)]
     [string]$resourceLocation,
     [Parameter(Mandatory=$true)]
     [string]$vmName,
     [Parameter(Mandatory=$true)]
     [string]$diagStorageAccount,
     [Parameter(Mandatory=$true)]
     [string]$emailAddress,
     [Parameter(Mandatory=$true)] #Added as part of the name in created container in sourcestorage
     [string]$buildId
)

Function Main()
{

    param
    (
        #dynamic parameters sent by Devops
        [Parameter(Mandatory=$false)]
        [string]$commRG,
        [Parameter(Mandatory=$false)]
        [string]$vmRG,
        [Parameter(Mandatory=$false)]
        [string]$keyVaultNameforSecret,
        [Parameter(Mandatory=$false)]
        [string]$secretName,
        [Parameter(Mandatory=$false)]
        [String]$destStorageAccount,
        [Parameter(Mandatory=$false)]
        [String]$destContainerName,
        [Parameter(Mandatory=$false)]
        [string]$deployEnvironment,
        [Parameter(Mandatory=$false)]
        [string]$targetDataType,
        [Parameter(Mandatory=$false)]
        [string]$sourceDatatype,
        [Parameter(Mandatory=$false)]
        [string]$sourceLocation,
        [Parameter(Mandatory=$false)]
        [string]$buildId,
        [Parameter(Mandatory=$false)]
        [string]$sftpLocalUser,

        #SFTP Connection
        [Parameter(Mandatory=$false)]
        [string]$srcSftpCtn,
        [Parameter(Mandatory=$false)]
        [string]$srcSftpAcctNm,
        [Parameter(Mandatory=$false)]
        [string]$srcSftpPass,
        [Parameter(Mandatory=$false)]
        [string]$srcSftpKey,

        #DevOps Parameters
        [Parameter(Mandatory=$false)]
        [int]$taskNumber,
        [Parameter(Mandatory=$false)]
        [string]$resourceLocation,
        [Parameter(Mandatory=$false)]
        [string]$vmName,
        [Parameter(Mandatory=$false)]
        [string]$diagStorageAccount,
        [Parameter(Mandatory=$false)]
        [string]$emailAddress
    )

    #static local paths
    $Troot = "T:\"
    $Sroot = "S:\"

    $localTargetDirectory = "$Sroot" + "FromStorageAccount"
    $unzipPath = "$Troot" + "UnzipFile"
    $zipPath = "$Troot" + "EncryptedZipFile"

    if($deployEnvironment -eq "Non-Production")
    {
        $sourceStorageAccount = "sstornpedcbkofdm001"
    }
    else
    {
        $sourceStorageAccount = "sstorprdedcbkofdm001"
    }

    Connect-AzAccount -Identity -Force -ErrorAction Stop
    #------------------------
	# Install 7zip
    installZip

    #------------------------
    #Selection of sourceDatatype
    if($sourceDatatype -eq "sftp")
    {
        #------------------------
	    # Call Copy From SFTP to Disk1
        triggerSFTP -commRG $commRG -localTargetDirectory $localTargetDirectory -keyVaultNameforSecret $keyVaultNameforSecret -taskNumber $taskNumber -buildId $buildId -sourceStorageAccount $sourceStorageAccount -srcSftpCtn $srcSftpCtn -srcSftpAcctNm $srcSftpAcctNm -srcSftpPass $srcSftpPass -srcSftpKey $srcSftpKey
    }
    else
    {
        #------------------------
	    # Call copyfromStoragetoDisk
        copyfromStoragetoDisk -sourceStorageAccount $sourceStorageAccount -localTargetDirectory $localTargetDirectory -sourceLocation $sourceLocation -commRG $commRG
    }

	#--------------------------
	# Unzip and extract to Disk2
	UnzipusingKeyVaultSecret -keyVaultNameforSecret $keyVaultNameforSecret -secretName $secretName -localTargetDirectory $localTargetDirectory -unzipPath $unzipPath -commRG $commRG

    #--------------------------
	# TVT Checking
    $output = TVTreport -reportPath $reportPath -unzipPath $unzipPath

    If($output -eq "No Mismatch Found")
    {
	    #------------------------
	    # Copy file from Disk2 to Storage location
	    copyFilefromLocaltoStorage -commRG $commRG -keyVaultNameforSecret $keyVaultNameforSecret -destStorageAccount $destStorageAccount -unzipPath $unzipPath -destContainerName $destContainerName -zipPath $zipPath -targetDataType $targetDataType -reportPath $reportPath -localTargetDirectory $localTargetDirectory

        #------------------------
        #Trigger Housekeeping Pipeline
        Housekeeping -taskNumber $taskNumber -deployEnvironment $deployEnvironment -vmName $vmName -vmRG $vmRG -diagStorageAccount $diagStorageAccount -resourceLocation $resourceLocation -emailAddress $emailAddress -commRG $commRG -sftpLocalUser $sftpLocalUser -targetDataType $targetDataType -destStorageAccount $destStorageAccount -destContainerName $destContainerName -keyVaultNameforSecret $keyVaultNameforSecret
    }
    else
    {
        return $output
    }
}

function installZip()
{
	Display -message "Installing 7zip" -psName "Install7zip.ps1"
    try
    {
        $output = powershell.exe -file "$PSScriptRoot\Install7zip.ps1"
        Display -message "$output" -psName "Install7zip.ps1"
    }
    catch
    {
        Display -message "$output" -psName "Install7zip.ps1"
    }
}

function triggerSFTP()
{
    param ($commRG, $localTargetDirectory, $keyVaultNameforSecret, $taskNumber, $buildId, $sourceStorageAccount, $srcSftpCtn, $srcSftpAcctNm, $srcSftpPass, $srcSftpKey)
    Display -message "Copying Zip (password protected file) from SFTP to Disk1" -psName "copyFilefromSFTPtoDisk.ps1"
    try
    {
        $output = powershell.exe -file "$PSScriptRoot\copyFilefromSFTPtoDisk.ps1" -commRG $commRG -localTargetDirectory $localTargetDirectory -keyVaultNameforSecret $keyVaultNameforSecret -taskNumber $taskNumber -buildId $buildId -sourceStorageAccount $sourceStorageAccount -srcSftpCtn $srcSftpCtn -srcSftpAcctNm $srcSftpAcctNm -srcSftpPass $srcSftpPass -srcSftpKey $srcSftpKey
        Display -message "$output" -psName "copyFilefromSFTPtoDisk.ps1"
    }
    catch
    {
        Display -message "Copy Zip (password protected file) from SFTP to Disk1 Failed" -psName "copyFilefromSFTPtoDisk.ps1"
    }
}

function copyfromStoragetoDisk()
{
    param ($sourceStorageAccount, $localTargetDirectory, $sourceLocation, $commRG)
	Display -message "Copying Zip (password protected file) from Storage to Disk1" -psName "copyfromStoragetoDisk.ps1"
	try
	{
		$output = powershell.exe -file "$PSScriptRoot\copyfromStoragetoDisk.ps1" -sourceStorageAccount $sourceStorageAccount -localTargetDirectory $localTargetDirectory -sourceLocation $sourceLocation -commRG $commRG
        $fname = (get-ChildItem $localTargetDirectory).Name
        Display -message "$output" -psName "copyfromStoragetoDisk.ps1" -accName $sourceStorageAccount -ctnname $sourceLocation -filename $fname
	}
	catch
	{
		Display -message "Copy Zip (password protected file) from Storage to Disk1 Failed" -psName "copyFilefromSFTPtoDisk.ps1" -accName $sourceStorageAccount -ctnname $sourceLocation
	}
}

function UnzipusingKeyVaultSecret()
{
    param ($keyVaultNameforSecret, $secretName, $localTargetDirectory, $unzipPath, $commRG)
	Display -message "Unzipping and extract to Disk2" -psName "UnzipusingKeyVaultSecret.ps1"
	try
	{
		$output = powershell.exe -file "$PSScriptRoot\UnzipusingKeyVaultSecret.ps1" -keyVaultNameforSecret $keyVaultNameforSecret -secretName $secretName -localzippath $localTargetDirectory -unzipPath $unzipPath -commRG $commRG
        $fname = (get-ChildItem $unzipPath).Name
        Display -message $output -psName "UnzipusingKeyVaultSecret.ps1" -accName $keyVaultNameforSecret -filename $fname -secName $secretName
	}
	catch
	{
		Display -message "Unzip and extract to Disk2 Failed" -psName "UnzipusingKeyVaultSecret.ps1" -accName $keyVaultNameforSecret -filename $fname -secName $secretName
	}
}

function copyFilefromLocaltoStorage()
{
    param ($commRG, $keyVaultNameforSecret, $destStorageAccount, $unzipPath, $destContainerName, $zipPath, $targetDataType, $localTargetDirectory, $reportPath)
	Display -message "Copying file from Disk2 to Storage location" -psName "copyFilefromLocaltoStorage.ps1"
	try
	{
		if ($targetDataType -eq "internal")
		{
			$output = powershell.exe -file "$PSScriptRoot\copyFilefromLocaltoStorage.ps1" -commRG $commRG -destStorageAccount $destStorageAccount -unzipPath $unzipPath -destContainerName $destContainerName -reportPath $reportPath
            $fname = (get-ChildItem $unzipPath).Name
            Display -message "$output" -psName "copyFilefromLocaltoStorage.ps1" -accName $destStorageAccount -ctnname $destContainerName -filename $fname
		}
		Else
		{
            $output = powershell.exe -file "$PSScriptRoot\zipFileUsing7z.ps1" -commRG $commRG -keyVaultNameforSecret $keyVaultNameforSecret -destContainerName $destContainerName -unzipPath $unzipPath -zipPath $zipPath -localTargetDirectory $localTargetDirectory -reportPath $reportPath
            $fname = (get-ChildItem $localTargetDirectory).Name
            Display -message "$output" -psName "zipFileUsing7z.ps1" -accName $keyVaultNameforSecret -filename $fname -secName $destContainerName + "secret"
            try
            {
                Display -message "Copying File From Disk to SFTP" -psName "copyFilefromDisktoSFTP.ps1"
                $sftpoutput = powershell.exe -file "$PSScriptRoot\copyFilefromDisktoSFTP.ps1" -commRG $commRG -destStorageAccount $destStorageAccount -zipPath $zipPath -destContainerName $destContainerName
                $fname = (get-ChildItem $localTargetDirectory).Name
                Display -message "$sftpoutput" -psName "copyFilefromDisktoSFTP.ps1" -accName $destStorageAccount -ctnname $destContainerName -filename $fname
            }
            catch
            {
                Display -message "Failed to Copy File From Disk to SFTP" -psName "copyFilefromDisktoSFTP.ps1"
            }
		}
	}
	catch
	{
		Display -message "Copy file from Disk2 to Storage location Failed" -psName "copyFilefromLocaltoStorage.ps1"
	}
}

function TVTreport()
{
    param ($reportPath, $unzipPath)
    Display -message "Generating and Comparing TVT Reports" -psName "reconcilliationReport.ps1"
    try
    {
        $output = powershell.exe -file "$PSScriptRoot\reconcilliationReport.ps1" -reportPath $reportPath -unzipPath $unzipPath
        if($output -eq "No Mismatch Found")
        {
            Display -message "Successfully Compared/Generate TVT Report: $output" -psName "reconcilliationReport.ps1"
            return $output
        }
        else
        {
            return $output
        }
    }
    catch
    {
        Display -message "Unable to run TVT Checking Script" -psName "reconcilliationReport.ps1"
    }
}

function Display()
{
    param([string]$message, [string]$psName, [string]$filename, [string]$accName, [string]$ctnname, [string]$secName)

    $message = $message + " - " + (Get-Date).ToString()
    Write-Output $message;
    if ($null -eq $ctnname -and $null -eq $accName -and $null -eq $filename)
    {
        $log = "<br>Powershell Script: $psName <br> Message: $message<br> "
        powershell.exe -file "$PSScriptRoot\LoggingDevOps.ps1" -WorkItemComment $log -taskNumber $taskNumber -keyVaultNameforSecret $keyVaultNameforSecret
    }
    elseif ($null -ne $secName)
    {
        $log = "<br>Powershell Script: $psName <br>Account Name: $accName <br>Name: $filename<br>Secret Name: $secName<br> Message: $message<br>"
        powershell.exe -file "$PSScriptRoot\LoggingDevOps.ps1" -WorkItemComment $log -taskNumber $taskNumber -keyVaultNameforSecret $keyVaultNameforSecret
    }
    elseif ($null -eq $ctnname)
    {
        $log = "<br>Powershell Script: $psName <br>Account Name: $accName <br>Name: $filename<br> Message: $message<br>"
        powershell.exe -file "$PSScriptRoot\LoggingDevOps.ps1" -WorkItemComment $log -taskNumber $taskNumber -keyVaultNameforSecret $keyVaultNameforSecret
    }
    else
    {
        $log = "<br>Powershell Script: $psName <br>Account Name: $accName <br>Container: $ctnname<br> Name: $filename<br> Message: $message<br>"
        powershell.exe -file "$PSScriptRoot\LoggingDevOps.ps1" -WorkItemComment $log -taskNumber $taskNumber -keyVaultNameforSecret $keyVaultNameforSecret
    }
}

function Housekeeping()
{
    param ($taskNumber, $deployEnvironment, $vmName, $vmRG, $diagStorageAccount, $resourceLocation, $emailAddress, $commRG, $sftpLocalUser, $targetDataType, $destStorageAccount, $destContainerName, $keyVaultNameforSecret)
    Display -message "Triggering Housekeeping Pipeline" -psName "TriggerHousekeeping.ps1"
    $output = powershell.exe -file "$PSScriptRoot\TriggerHousekeeping.ps1" -taskNumber $taskNumber -deployEnvironment $deployEnvironment -vmName $vmName -vmRG $vmRG -diagStorageAccount $diagStorageAccount -resourceLocation $resourceLocation -emailAddress $emailAddress -commRG $commRG -sftpLocalUser $sftpLocalUser -targetDataType $targetDataType -destStorageAccount $destStorageAccount -destContainerName $destContainerName -keyVaultNameforSecret $keyVaultNameforSecret
    if($output -eq $true)
    {
        Display -message "Successfully Triggered Housekeeping Pipeline" -psName "TriggerHousekeeping.ps1"
    }
    else
    {
        Display -message "Failed Triggered Housekeeping Pipeline" -psName "TriggerHousekeeping.ps1"
    }
}
try
{
    Connect-AzAccount -Identity -Force -ErrorAction Stop
}
catch
{
    #log for backend outfile
    Write-Error "Unable to connect using connect-azaccount"
}
Main -commRG $commRG -vmRG $vmRG -keyVaultNameforSecret $keyVaultNameforSecret -secretName $secretName -destStorageAccount $destStorageAccount -destContainerName $destContainerName -deployEnvironment $deployEnvironment -targetDataType $targetDataType -sourceDatatype $sourceDatatype -sourceLocation $sourceLocation -buildId $buildId -sftpLocalUser $sftpLocalUser -taskNumber $taskNumber -resourceLocation $resourceLocation -vmName $vmName -diagStorageAccount $diagStorageAccount -emailAddress $emailAddress -srcSftpCtn $srcSftpCtn -srcSftpAcctNm $srcSftpAcctNm -srcSftpPass $srcSftpPass -srcSftpKey $srcSftpKey