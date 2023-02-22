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
    #Initialize Parameters
    [xml]$params = Get-Content ".\param.xml"
    Write-Output $params > ".\dummy.txt"
    Remove-Item -Path ".\dummy.txt" -Force

    #Connect to Azure using Identity
    Connect-AzAccount -Identity

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
    #Write-output $str > ".\test.txt"
    #Remove-Item -Path ".\test.txt" -Force
}

function stripe()
{
	Display("Stripping OS Disk")
	try
	{
		If ($filesize -le 10) { $params.param.sourceCount = 1 }
		else{ $params.param.sourceCount = 3 }
		Powershell.exe -file ".\stripe.ps1" -sourceCount $params.param.sourceCount
        Display("Successfully Stripping OS Disk")
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
		powershell.exe -file ".\copyfromStoragetoDisk.ps1" -storageaccount $params.param.storageaccount -stgencryptedFileName $params.param.stgencryptedFileName -localTargetDirectory $params.param.localTargetDirectory -sourceContainerName $params.param.sourceContainerName
        Display("Successfully Copy Zip (password protected file) from Storage to Disk1")
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
		if ($params.param.Party -eq "false")
		{
			powershell.exe -file ".\copyFilefromLocaltoStorage.ps1" -rgname $params.param.rgname -deststorageacctname $params.param.deststorageacctname -ContainerName $params.param.ContainerName -sourceunzippath $params.param.sourceunzippath
            Display ("Successfully Copy file from Disk2 to Storage location")
		}
		Else
		{
            powershell.exe -file ".\zipFileUsing7z.ps1" -rgname $params.param.rgname -akv $params.param.akv -akvencrypt $params.param.akvencrypt -TargetunzipPath $params.param.TargetunzipPath -newsourcezippath $params.param.newsourcezippath
            Display ("Successfully Zip/Encrypt file and Copy from Disk2 to Storage location")

            try{
                Display ("Copying File From Disk to SFTP")
                powershell.exe -file ".\copyFilefromDisktoSFTP.ps1" -rgname $params.param.rgname -sftpstoracctname $params.param.sftpstoracctname -sftpcontainerName $params.param.sftpcontainerName -sourcezippath $params.param.sourcezippath
                Display ("Successfully Copy File From Disk to SFTP")
            }
            catch
            {
                Display ("Failed to Copy File From Disk to SFTP")
            }
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
		powershell.exe -file ".\UnzipusingKeyVaultSecret.ps1" -akv $params.param.akv -akvsecretzip $params.param.akvsecretzip -localzippath $params.param.localzippath -TargetunzipPath $params.param.TargetunzipPath
        Display("Successfully Unzip and extract to Disk2")
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
		powershell.exe -file ".\SQLWriteData.ps1" -rgname $params.param.rgname -servername $params.param.servername -database $params.param.database -keyvaultscript $params.param.keyvaultscript -akv $params.param.akv -akvsecretsql $params.param.akvsecretsql -sqlusername $params.param.sqlusername -sqltablename $params.param.sqltablename -sqldata1 $params.param.sqldata1 -sqldata2 $params.param.sqldata2 -sqldata3 $params.param.sqldata3
        Display("Successfully Writte Data in SQL Database")
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