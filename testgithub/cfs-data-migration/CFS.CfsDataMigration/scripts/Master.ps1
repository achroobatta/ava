#-----------------------------------------------#
# 	Master Script				                #
# 	Created by: Joseph Dionisio		            #
#						                        #
#						                        #
#-----------------------------------------------#
#Param (
#    [string] $servername,
#    [string] $database,
#    [string] $keyvaultscript,
#    [string] $sqltablename,
#    [string] $akv,
#    [string] $akvsecretsql,
#    [string] $sqlusername,
#    [string] $sqldata1,
#    [string] $sqldata2,
#    	     $sqldata3,
#    [string] $storageaccount,
#    [string] $EncryptedFileName,
#    [string] $localTargetDirectory,
#    [string] $ContainerName,
#    [string] $encryptedpath,
#    [string] $TargetPath,
#    [int32]  $sourceCount,
#    [int32]  $filesize,
#    [ValidateSet("True","False")]
#    [string] $3rdParty = "False",
#    [string] $rgname,
#    [string] $deststorageacctname,
#    [string] $sourceunzippath,
#    [String] $akvencrypt,
#    [String] $TargetunzipPath,
#    [String] $sourcezippath
#)

param(
    [string]$paramFile = '.\param.json'
)

#=============================
# MAIN
#=============================

Function Main()
{
    #Connect to Azure using Identity
    Connect-AzAccount -Identity

    # Full Parameter Values from Json File
    $params = Get-Content $paramFile | ConvertFrom-Json

    # Initialize Parameters
    [string] $servername = $params.servername
    [string] $database = $params.database
    [string] $keyvaultscript = $params.keyvaultscript
    [string] $sqltablename = $params.sqltablename
    [string] $akv = $params.akv
    [string] $akvsecretsql = $params.akvsecretsql
    [string] $sqlusername = $params.sqlusername
    [string] $sqldata1 = $params.sqldata1
    [string] $sqldata2 = $params.sqldata2
    [string] $sqldata3 = $params.sqldata3
    [string] $storageaccount = $params.storageaccount
    [string] $EncryptedFileName = $params.EncryptedFileName
    [string] $localTargetDirectory = $params.localTargetDirectory
    [string] $ContainerName = $params.ContainerName
    [string] $encryptedpath = $params.encryptedpath
    [string] $TargetPath = $params.TargetPath
    [int32]  $sourceCount = $params.sourceCount
    [int32]  $filesize = $params.filesize
    [string] $3rdParty = $params.Party
    [string] $rgname = $params.rgname
    [string] $deststorageacctname = $params.deststorageacctname
    [string] $sourceunzippath = $params.sourceunzippath
    [String] $akvencrypt = $params.akvencrypt
    [String] $TargetunzipPath = $params.TargetunzipPath
    [String] $sourcezippath = $params.sourcezippath

	#------------------------
	# Call Stripe OS Disk
	Stripe

	#------------------------
	# Call copyfromStoragetoDisk
	copyfromStoragetoDisk

	#--------------------------
	# Unzip and extract to Disk2
	UnzipusingKeyVaultSecret

	#------------------------
	# Copy file from Disk2 to Storage location
	copyFilefromLocaltoStorage

	#------------------------
	# Write data into SQL Database
    SQLWriteData
}

function stripe()
{
	Display("Stripping OS Disk")
	try
	{
		If ($filesize -le 10) { $sourceCount = 1 }
		else{ $sourceCount = 3 }
		Powershell.exe -file ".\stripe.ps1" $sourceCount
        Display("Testing Stripping")
	}
	catch
	{
		Display("Stripping OS Disk failed")
	}

}

function copyfromStoragetoDisk()
{
	Display("Copy Zip (password protected file) from Storage to Disk1")
	try
	{
		powershell.exe -file ".\copyfromStoragetoDisk.ps1" $storageaccount $EncryptedFileName $localTargetDirectory $ContainerName
	}
	catch
	{
		Display("Copy Zip (password protected file) from Storage to Disk1 Failed")
	}
}

function copyFilefromLocaltoStorage()
{
	Display("Copy file from Disk2 to Storage location")
	try
	{
		if ($3rdParty -eq $false)
		{
			powershell.exe -file ".\copyFilefromLocaltoStorage.ps1" $rgname $deststorageacctname $ContainerName $sourceunzippath
		}
		Else
		{
            powershell.exe -file ".\zipFileUsing7z.ps1" $akv $akvencrypt $TargetunzipPath $sourcezippath
		}
	}
	catch
	{
		Display ("Copy file from Disk2 to Storage location Failed")
	}
}

function UnzipusingKeyVaultSecret()
{
	Display("Unzip and extract to Disk2")
	try
	{
		powershell.exe -file ".\UnzipusingKeyVaultSecret.ps1" $akv $akvsecret $encryptedpath $TargetPath
        Display("Testing Unzip")
	}
	catch
	{
		Display("Unzip and extract to Disk2 Failed")
	}
}

function SQLWriteData()
{
	Display("Write Log to SQL")
	try
	{
		powershell.exe -file ".\SQLWriteData.ps1" $rgname $servername $database $keyvaultscript $akv $akvsecretsql $sqlusername $sqltablename $sqldata1 $sqldata2 $sqldata3
	}
	catch
	{
		Display("Writting Data in SQL Database failed")
	}
}

function Display([string]$message)
{
    $message = $message + " - " + (Get-Date).ToString()
    Write-Output $("=" * ($message.length));
    Write-Output $message;
    Write-Output $("=" * ($message.length));
}

Main $args