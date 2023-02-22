#Zipped File using 7zip - Main Script
#create by: Joshua Ira San Ramon
param
(
    [Parameter(Mandatory=$true)]
    [String]$keyVaultNameforSecret,
    [Parameter(Mandatory=$true)]
    [String]$localTargetDirectory,
    [Parameter(Mandatory=$true)]
    [String]$unzipPath,
    [Parameter(Mandatory=$true)]
    [String]$zipPath,
    [Parameter(Mandatory=$true)]
    [String]$destContainerName,
    [Parameter(Mandatory=$true)]
    [String]$reportPath
)
Function get-secret()
{
    powershell.exe -file "$PSScriptRoot\generatePassword.ps1" $keyVaultNameforSecret $destContainerName
    try
    {
        $namepass = $destContainerName + "secret"
        $secret = Get-AzKeyVaultSecret -vaultName $keyVaultNameforSecret -name $namepass
        $Get_My_Scret = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
        $Enpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Get_My_Scret)
    }
    catch
    {
        write-output "Unable to retrieve password"
    }
    try
    {
        #Zipping the files
        $zipSize = (Get-ChildItem -Path $localTargetDirectory -Exclude *Report* -File -Recurse | Select-Object -First 1 | Measure-Object -Property Length -sum).Sum
        Compress-7Zip -Path $unzipPath -ArchiveFileName "$zipPath\EncryptedFile.7z" -VolumeSize $zipSize -Format SevenZip -Password $Enpassword -EncryptFilenames -ErrorAction Stop

        #Zip Reports
        Compress-7Zip -Path $reportPath -ArchiveFileName "$zipPath\Report.7z" -Format SevenZip -Password $Enpassword -EncryptFilenames -ErrorAction Stop

        return "Successfully Zip/Encrypt file and Copy from Disk2 to Storage location"
    }
    catch
    {
        return "Unable to Compress the files"
    }
}
try
{
    get-secret ($keyVaultNameforSecret,$destContainerName, $unzipPath, $zipPath, $localTargetDirectory, $reportPath)
}
catch
{
    write-output "Failed to Zip/Encrypt file and Copy from Disk2 to Storage location"
}