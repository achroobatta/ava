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
    param([string]$paramFile = '.\param.json')

    #Connect to Azure using Identity
    Connect-AzAccount -Identity

    # Full Parameter Values from Json File
    $params = Get-Content $paramFile | ConvertFrom-Json

    # Initialize Parameters
    $servername = $params.servername
    $database = $params.database
    $keyvaultscript = $params.keyvaultscript
    $sqltablename = $params.sqltablename
    $akv = $params.akv
    $akvsecretsql = $params.akvsecretsql
    $sqlusername = $params.sqlusername
    $sqldata1 = $params.sqldata1
    $sqldata2 = $params.sqldata2
    $sqldata3 = $params.sqldata3
    $storageaccount = $params.storageaccount
    $EncryptedFileName = $params.EncryptedFileName
    $localTargetDirectory = $params.localTargetDirectory
    $ContainerName = $params.ContainerName
    $encryptedpath = $params.encryptedpath
    $TargetPath = $params.TargetPath
    $sourceCount = $params.sourceCount
    $filesize = $params.filesize
    $3rdParty = $params.Party
    $rgname = $params.rgname
    $deststorageacctname = $params.deststorageacctname
    $sourceunzippath = $params.sourceunzippath
    $akvencrypt = $params.akvencrypt
    $TargetunzipPath = $params.TargetunzipPath
    $sourcezippath = $params.sourcezippath

    # Used Param
    $str = $servername + $database + $keyvaultscript + $sqltablename + $akv + $akvsecretsql + $sqlusername + $sqldata1 + $sqldata2 + $sqldata3 + $storageaccount + $EncryptedFileName + $localTargetDirectory + $ContainerName + $encryptedpath + $TargetPath + $sourceCount + $filesize + $3rdParty + $rgname + $deststorageacctname + $sourceunzippath + $akvencrypt + $TargetunzipPath + $sourcezippath

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

    Write-output $str > ".\test.txt"
    Remove-Item -Path ".\test.txt" -Force
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