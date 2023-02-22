#Upload Secret to Azure Key Vault
param
(
    [Parameter(Mandatory=$true)]
    [String]$akv,
    [Parameter(Mandatory=$true)]
    [String]$akvencrypt,
    [Parameter(Mandatory=$true)]
    [String]$pass
)
function upload_toakv()
{
    Connect-AzAccount -Identity
    $secval = ConvertTo-SecureString $pass -AsPlainText -Force
    $sec = Set-AzKeyVaultSecret -Vaultname $akv  -Name $akvencrypt -SecretValue $secval
}
try
{
    upload_toakv ($akv,$akvencrypt,$password)
    Write-Output "Sucessfully uploaded the password in the Key Vault"
}
catch
{
    Write-Output "Unable to run script"
    Return $False
}