#-----------------------------------------------#
# 	Master Script				                #
# 	Created by: Joseph Dionisio		            #
#						                        #
#						                        #
#-----------------------------------------------#

#=============================
# MAIN
#=============================

Function Main()
{

param
(
     #Dynamic Parameters

     [Parameter(Mandatory=$false)]
     [int]$filesize = 11,
     [Parameter(Mandatory=$false)]
     [int]$zipcount = 5, #number of split
     [Parameter(Mandatory=$false)]
     [string]$Party = "true",
     [Parameter(Mandatory=$false)]
     [string]$sourceCount = 2,
     [Parameter(Mandatory=$false)]
     [string]$stgencryptedFileName = "sampletext", #New name of the zip file
     [Parameter(Mandatory=$false)]
     [string]$akvsecretzip = "ninembpassword", #nullable
     [Parameter(Mandatory=$false)]
     [String]$sftpstoracctname = "sftpstoragepsteam1",
     [Parameter(Mandatory=$false)]
     [String]$sftpcontainerName = "sftpcontainertest5",
     [Parameter(Mandatory=$false)]
     [string]$sourceContainerName = "sourcecontainer", #waiting for achroo clarification if this is a static or dynamic

     #Static Parameters

     [Parameter(Mandatory=$false)]
     [string]$akv = "kv-np-edc-bkof-dm-0024",
     [Parameter(Mandatory=$false)]
     [String]$rgname = "rg-np-edc-bkof-dm-001",
     [Parameter(Mandatory=$false)]
     [String]$storageaccount = "sstornpedcbkofdm001",
     [Parameter(Mandatory=$false)]
     [string]$localTargetDirectory = "S:\FromStorageAccount",
     [Parameter(Mandatory=$false)]
     [string]$TargetunzipPath = "T:\UnzipFile",
     [Parameter(Mandatory=$false)]
     [string]$deststorageacctname = "dlgen2npedcbkofdm002",
     [Parameter(Mandatory=$false)]
     [string]$sourceunzippath = "T:\UnzipFile",
     [Parameter(Mandatory=$false)]
     [string]$sourcezippath = "T:\EncryptedZipFile"
)


    #Connect to Azure using Identity
    Connect-AzAccount -Identity

    #------------------------
	# Required Modules
    Modules

    #------------------------
	# Call Stripe OS Disk
	Stripe -sourceCount $sourceCount -filesize $filesize

	#------------------------
	# Call copyfromStoragetoDisk
	copyfromStoragetoDisk -storageaccount $storageaccount -localTargetDirectory $localTargetDirectory -sourceContainerName $sourceContainerName

	#--------------------------
	# Unzip and extract to Disk2
	UnzipusingKeyVaultSecret -akv $akv -akvsecretzip $akvsecretzip -localTargetDirectory $localTargetDirectory -TargetunzipPath $TargetunzipPath

	#------------------------
	# Copy file from Disk2 to Storage location
	copyFilefromLocaltoStorage -rgname $rgname -akv $akv -deststorageacctname $deststorageacctname -sourceunzippath $sourceunzippath -sftpcontainerName $sftpcontainerName -TargetunzipPath $TargetunzipPath -stgencryptedFileName $stgencryptedFileName -sftpstoracctname $sftpstoracctname -sourcezippath $sourcezippath -zipcount $zipcount -Party $Party

	#------------------------
	# Write data into SQL Database
    #SQLWriteData
}

function stripe()
{
    param ($sourceCount, $filesize)
	Display "Stripping OS Disk" "stripe.ps1"
	try
	{
		If ($filesize -le 10)
        {
            $sourceCount = 1
            Powershell.exe -file ".\stripe.ps1" -sourceCount $sourceCount
            Display "Successfully Stripping OS Disk" "stripe.ps1"
        }
        Else
        {
		    Powershell.exe -file ".\stripe.ps1" -sourceCount $sourceCount
            Display "Successfully Stripping OS Disk" "stripe.ps1"
        }
	}
	catch
	{
		Display "Stripping OS Disk failed" "stripe.ps1"
	}
}

function Modules()
{
    Display "Intalling the Modules" "Modules.ps1"
	try
	{
        $output = powershell.exe -file ".\Modules.ps1"
        Display "$output" "Modules.ps1"
	}
	catch
	{
		Display "Failed to install Modules" "Modules.ps1"
	}
}

function copyfromStoragetoDisk()
{
    param ($storageaccount, $localTargetDirectory, $sourceContainerName)
	Display "Copy Zip (password protected file) from Storage to Disk1" "copyfromStoragetoDisk.ps1"
	try
	{
		$output = powershell.exe -file ".\copyfromStoragetoDisk.ps1" -storageaccount $storageaccount -localTargetDirectory $localTargetDirectory -sourceContainerName $sourceContainerName
        Display "$output" "copyfromStoragetoDisk.ps1"
	}
	catch
	{
		Display "Copy Zip (password protected file) from Storage to Disk1 Failed" "copyfromStoragetoDisk.ps1"
	}
}

function UnzipusingKeyVaultSecret()
{
    param ($akv, $akvsecretzip, $localTargetDirectory, $TargetunzipPath)
	Display "Unzip and extract to Disk2" "UnzipusingKeyVaultSecret.ps1"
	try
	{
		$output = powershell.exe -file ".\UnzipusingKeyVaultSecret.ps1" -akv $akv -akvsecretzip $akvsecretzip -localzippath $localTargetDirectory -TargetunzipPath $TargetunzipPath
        Display "$output" "UnzipusingKeyVaultSecret.ps1"
	}
	catch
	{
		Display "Unzip and extract to Disk2 Failed" "UnzipusingKeyVaultSecret.ps1"
	}
}

function copyFilefromLocaltoStorage()
{
    param ($rgname, $akv, $deststorageacctname, $sourceunzippath, $sftpcontainerName, $TargetunzipPath, $stgencryptedFileName, $sftpstoracctname, $sourcezippath, $zipcount, $Party)
	Display "Copy file from Disk2 to Storage location" "copyFilefromLocaltoStorage.ps1"
	try
	{
		if ($Party -eq "false")
		{
			$output = powershell.exe -file ".\copyFilefromLocaltoStorage.ps1" -rgname $rgname -deststorageacctname $deststorageacctname -sourceunzippath $sourceunzippath
            Display "$output" "copyFilefromLocaltoStorage.ps1"
		}
		Else
		{
            $output = powershell.exe -file ".\zipFileUsing7z.ps1" -rgname $rgname -akv $akv -sftpcontainerName $sftpcontainerName -TargetunzipPath $TargetunzipPath -newsourcezippath "T:\EncryptedZipFile\$stgencryptedFileName.7z" -zipcount $zipcount
            Display "$output" "zipFileUsing7z.ps1"

            try
            {
                Display "Copying File From Disk to SFTP" "copyFilefromDisktoSFTP.ps1"
                $sftpoutput = powershell.exe -file ".\copyFilefromDisktoSFTP.ps1" -rgname $rgname -sftpstoracctname $sftpstoracctname -sourcezippath $sourcezippath -sftpcontainerName $sftpcontainerName
                Display "$sftpoutput" "copyFilefromDisktoSFTP.ps1"
            }
            catch
            {
                Display "Failed to Copy File From Disk to SFTP" "copyFilefromDisktoSFTP.ps1"
            }
		}
	}
	catch
	{
		Display "Copy file from Disk2 to Storage location Failed" "copyFilefromLocaltoStorage.ps1"
	}
}

function Display([string]$message, [string]$filename)
{
    $message = $message + " - " + (Get-Date).ToString()
    Write-Output $("=" * ($message.length));
    Write-Output $message;
    Write-Output $("=" * ($message.length));
    $log = "Powershell Script: $filename `r` Log: $message"
    powershell.exe -file ".\LoggingDevOps.ps1" -orgURL "https://dev.azure.com/$orgname" -WorkItemId $WorkItemId -PAT $PAT -WorkItemComment $log -coreAreaID $coreAreaID -projectname $projectname
}

Main