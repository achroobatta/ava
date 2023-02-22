#Generate Password to be use to 7zip
param
(
    [Parameter(Mandatory=$true)]
    [String]$keyVaultNameforSecret,
    [Parameter(Mandatory=$true)]
    [String]$destContainerName
)

Function generate_password()
{
    param ($keyVaultNameforSecret, $destContainerName)

    Add-Type -AssemblyName 'System.Web'
    $pass = [System.Web.Security.Membership]::GeneratePassword((Get-Random -Minimum 20 -Maximum 32),3)
    $string = New-Object System.Net.NetworkCredential("","$pass")
    $sec = $string.SecurePassword
    $kvName = $destContainerName + "secret"
    Set-AzKeyVaultSecret -Vaultname $keyVaultNameforSecret -Name $kvName -SecretValue $sec -ErrorAction Stop -ErrorVariable $err | Out-Null
    if($null -eq $err)
    {
        return Out-Null
    }
    else
    {
        return "Failed to Upload Generated Password to Key Vault"
    }
}

try
{
    $str1 = $keyVaultNameforSecret + $keyVaultNameforSecretencrypt
    Write-output $str1 > ".\test.txt"
    Remove-Item -Path ".\test.txt" -Force
    generate_password -keyVaultNameforSecret $keyVaultNameforSecret -destContainerName $destContainerName
}
catch
{
    Write-Output "Failed to Generate Password"
}