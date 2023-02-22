#Generate Password to be use to 7zip
param
(
    [Parameter(Mandatory=$true)]
    [String]$akv,
    [Parameter(Mandatory=$true)]
    [string]$akvencrypt
)

Function generate_password()
{
    Connect-AzAccount -Identity
    Add-Type -AssemblyName 'System.Web'
    $pass = [System.Web.Security.Membership]::GeneratePassword((Get-Random -Minimum 20 -Maximum 32),3)
    $string = New-Object System.Net.NetworkCredential("","$pass")
    $sec = $string.SecurePassword
    Set-AzKeyVaultSecret -Vaultname $akv -Name $akvencrypt -SecretValue $sec
}

try
{
    $str1 = $akv + $akvencrypt
    Write-output $str1 > ".\test.txt"
    Remove-Item -Path ".\test.txt" -Force
    generate_password
}
catch
{
    Write-Output "Password Generated"
}