#Zipped File using 7zip - Main Script
#Install-Module Az.Resources
param
(
    [Parameter(Mandatory=$true)]
    [String]$rgname,
    [Parameter(Mandatory=$true)]
    [String]$akv,
    [Parameter(Mandatory=$true)]
    [String]$TargetunzipPath,
    [Parameter(Mandatory=$true)]
    [String]$newsourcezippath,
    [Parameter(Mandatory=$true)]
    [String]$sftpcontainerName,
    [Parameter(Mandatory=$true)]
    [int]$zipcount
)
Function get-secret()
{
    if(!(Get-AzKeyVaultSecret -vaultName $akv -name $sftpcontainerName))
    {
        powershell.exe -file ".\generatePassword.ps1" $akv $sftpcontainerName
        #powershell.exe -file ".\UploadSecrettoAKV.ps1" $akv $sftpcontainerName $password
        try
        {
           $namepass = $sftpcontainerName + "secret"
           $secret = Get-AzKeyVaultSecret -vaultName $akv -name $namepass
           $Get_My_Scret = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
           $Enpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Get_My_Scret)
        }
        catch
        {
            write-output "Unable to retrieve password"
        }
        try
        {
            if($zipcount -gt 1)
            {
                $filesize = get-ChildItem T:\UnzipFile | Measure-Object -Property Length -sum
                $size = $filesize.Sum / 6810
                $sum = $size / $zipcount
                $value = [math]::Truncate($sum)

                Compress-7Zip -Path $TargetunzipPath -ArchiveFileName $newsourcezippath -VolumeSize $value -Format SevenZip -Password $Enpassword -EncryptFilenames
            }
            else
            {
                Compress-7Zip -Path $TargetunzipPath -ArchiveFileName $newsourcezippath  -Format SevenZip -Password $Enpassword -EncryptFilenames
            }
        }
        catch
        {
            write-output "Unable to Compress the files"
        }
    }
    else
    {
        try
        {
           $namepass = $sftpcontainerName + "secret"
           $secret = Get-AzKeyVaultSecret -vaultName $akv -name $namepass
           $Get_My_Scret = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
           $Enpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Get_My_Scret)
        }
        catch
        {
            write-output "Unable to retrieve password"
        }
        try
        {
            if($zipcount -gt 1)
            {
                $filesize = get-ChildItem T:\UnzipFile | Measure-Object -Property Length -sum
                $size = $filesize.Sum / 6810
                $sum = $size / $zipcount
                $value = [math]::Truncate($sum)

                Compress-7Zip -Path $TargetunzipPath -ArchiveFileName $newsourcezippath -VolumeSize $value -Format SevenZip -Password $Enpassword -EncryptFilenames
            }
            else
            {
                Compress-7Zip -Path $TargetunzipPath -ArchiveFileName $newsourcezippath  -Format SevenZip -Password $Enpassword -EncryptFilenames
            }
        }
        catch
        {
            write-output "Unable to Compress the files"
        }
     }
}
try
{
    if (!(Get-AzResourceGroup -name $rgname -ErrorAction SilentlyContinue))
    {
        Write-Output "No Existing Resource Group"
        return $False;
    }
    elseif (!(Get-AzKeyVault -VaultName $akv -ResourceGroupName $rgname))
    {
        Write-Output "No Existing Key Vault in $rgname Resource Group"
        return $False;
    }
    elseif ($sftpcontainerName -eq $null)
    {
        write-output "Provide a Container Name"
        return $False;
    }
    else
    {
        get-secret ($akv,$sftpcontainerName, $TargetunzipPath, $newsourcezippath, $zipcount)
        write-output "Successfully Zip/Encrypt file and Copy from Disk2 to Storage location"
    }
}
catch
{
    write-output "Failed to Zip/Encrypt file and Copy from Disk2 to Storage location"
}