#Zipped File using 7zip - Main Script
#Install-Module Az.Resources
param
(
    [Parameter(Mandatory=$true)]
    [String]$rgname,
    [Parameter(Mandatory=$true)]
    [String]$akv,
    [Parameter(Mandatory=$true)]
    [String]$akvencrypt,
    [Parameter(Mandatory=$true)]
    [String]$TargetunzipPath,
    [Parameter(Mandatory=$true)]
    [String]$sourcezippath
)
Function get-secret()
{
    if(!(Get-AzKeyVaultSecret -vaultName $akv -name $akvencrypt))
    {
        $password = powershell.exe -file ".\generatePassword.ps1"
        powershell.exe -file ".\UploadSecrettoAKV.ps1" $akv $akvencrypt $password
        try
        {
           $secret = Get-AzKeyVaultSecret -vaultName $akv -name $akvencrypt
           $Get_My_Scret = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
           $Enpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Get_My_Scret)
        }
        catch
        {
            write-output "Unable to retrieve password"
        }
        try
        {
            Compress-7Zip -Path $TargetunzipPath -ArchiveFileName $sourcezippath  -Format SevenZip -Password $Enpassword -EncryptFilenames
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
           $secret = Get-AzKeyVaultSecret -vaultName $akv -name $akvencrypt
           $Get_My_Scret = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
           $Enpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Get_My_Scret)
        }
        catch
        {
            write-output "Unable to retrieve password"
        }
        try
        {
            Compress-7Zip -Path $TargetunzipPath -ArchiveFileName $sourcezippath  -Format SevenZip -Password $Enpassword -EncryptFilenames
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
    else
    {
        get-secret ($akv,$akvencrypt, $TargetunzipPath, $sourcezippath)
        write-output "Succesfully encrypted the file"
    }
}
catch
{
    write-output "Unable to fetch Secret from Key Vault"
}