Description - SCRIPT FOR COPYING FILE FROM STORAGE ACCOUNT TO LOCAL DISK
Script Name - copyfromStoragetoDisk.ps1
Usage - .\copyfromStoragetoDisk.ps1 $storageaccount $stgencryptedFileName $localTargetDirectory $sourceContainerName
Variables:
$storageaccount			#Source Storage Account where the zip file is located
$stgencryptedFileName		#The file name of the zip file
$localTargetDirectory		#Local Disk path where the zip file should be saved
$sourceContainerName		#Container name of the Source Storage Account


Description - UNZIP FILE USING STORED KEY/S IN AKV
Script Name - UnzipusingKeyVaultSecret.ps1
Usage - .\UnzipusingKeyVaultSecret.ps1 $akv $akvsecretzip $localzippath $TargetunzipPath
Variables:
$akv					#Azure Key Vault Name
$akvsecretzip			#Name of the Secret on the key vault
$localzippath			#Local disk path where the zipped files where saved
$TargetunzipPath			#Local disk path where the UNZIPPED file should be saved


Description - COPY FILE FROM DISK2 TO STORAGE LOCATION
Script Name - copyFilefromLocaltoStorage.ps1
Usage - .\copyFilefromLocaltoStorage.ps1 $rgname $deststorageacctname $ContainerName $sourceunzippath
Variables:
$rgname				#Resouregroup name
$deststorageacctname		#Name of the storage account where the file should be saved after unzipping
$ContainerName 			#Container name of the Destination Storage account name
$sourceunzippath			#Local disk path where the source unzipped file was saved


Description - COPY ZIP FILE FROM DISK3 TO SFTP LOCATION
Script Name - copyFilefromDisktoSFTP.ps1	
Usage - .\copyFilefromDisktoSFTP.ps1 $rgname $sftpstoracctname $sftpcontainerName $sourcezippath
Variables:
$rgname				#Resouregroup name
$sftpstoracctname 		#Name of the SFTP enabled storage account where the file should be saved
$sftpcontainerName 		#Container name of the sftp enabled storage account
$sourcezippath			#Local disk path where the source ZIPPED file was saved

Description - INSERT DATA TO DATABASE TABLE
Script Name - SQLWriteData.ps1
Usage - .\SQLWriteData.ps1 $rgname $servername $database $keyvaultscript $akv $akvsecretsql $sqlusername $sqltablename $sqldata1 $sqldata2 $sqldata3
Variables:
$rgname 				#Resource Name
$servername 			#Azure SQL Server Name
$database 				#Azure SQL Database NAme
$keyvaultscript 			#Name of the .ps1 script for getting secrets in key vault
$akv 					#Azure Key Vault Name
$akvsecretsql 			#Secret name that contains sql password
$sqlusername 			#Username for the SQL Server
$sqltablename 			#Table name inside the Database
$sqldata1				#Datas that will be inputed in SQL Table
$sqldata2 				#Datas that will be inputed in SQL Table
$sqldata3				#Datas that will be inputed in SQL Table

Description - DISPLAY DATA FROM DATABASE TABLE
Script Name - SQLQuery.ps1
Usage - .\SQLQuery.ps1 $rgname $servername $database $keyvaultscript $akv $akvsecretsql $sqlusername $sqltablename
Variables:
$rgname 				#Resource Name
$servername 			#Azure SQL Server Name
$database 				#Azure SQL Database Name
$keyvaultscript 			#Name of the .ps1 script for getting secrets in key vault
$akv 					#Azure Key Vault Name
$akvsecretsql 			#Secret name that contains sql password
$sqlusername 			#Username for the SQL Server
$sqltablename 			#Table name inside the Database

Description - READ SECRET FROM KEY VAULT
Script Name - readkeyvaultpass.ps1
Usage - .\readkeyvaultpass.ps1 $akv $akvsecretsql
Variables:
$akv 					#Azure Key Vault Name
$akvsecretsql 			#Secret name that contains sql password


Description - GENERATE SECRET, UPLOAD TO KEY VAULT & ZIP THE FILE WITH PASSWORD
Script Name - generateUploadPassZipFile.ps1
Usage - .\generateUploadPassZipFile.ps1 $akv $akvencrypt $TargetunzipPath $sourcezippath
Variables:
$akv					#Azure Key Vault Name
$akvencrypt				#Secret name that contains the generated password
$TargetunzipPath			#From Disk 2, Local disk path where the UNZIP File is saved
$sourcezippath			#Local disk path where the newly ZIP file with New password should be saved










 


