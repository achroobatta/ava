#Generate Password to be use to 7zip
param
(
    [Parameter(Mandatory=$true)]
    [String]$keyVaultNameforSecret,
    [Parameter(Mandatory=$true)]
    [String]$sftpUsername
)

Function generate_password()
{
    param ($keyVaultNameforSecret, $sftpUsername)

    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Generating password to be used for 7zip") >> $logFilePath

    Add-Type -AssemblyName 'System.Web'
    $pass = [System.Web.Security.Membership]::GeneratePassword((Get-Random -Minimum 20 -Maximum 32),3)
    if ($null -ne $pass)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully generated password") >> $logFilePath
    }
    $string = New-Object System.Net.NetworkCredential("","$pass")
    $sec = $string.SecurePassword
    $kvName = $sftpUsername + "secret"

    try
    {
        Set-AzKeyVaultSecret -Vaultname $keyVaultNameforSecret -Name $kvName -SecretValue $sec -ErrorAction Stop | Out-Null
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully upload password to key vault") >> $logFilePath
    }

    catch
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to upload password to key vault") >> $logFilePath
    }
}

$logFilePath = "$PSScriptRoot\logging_generatePassword.txt"

try
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Start") >> $logFilePath
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Executing generate_password function...") >> $logFilePath

    generate_password -keyVaultNameforSecret $keyVaultNameforSecret -sftpUsername $sftpUsername
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
}
catch
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed to Generate Password") >> $logFilePath
    Write-Output "Failed to Generate Password"
}