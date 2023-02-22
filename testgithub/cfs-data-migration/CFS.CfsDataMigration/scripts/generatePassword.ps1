#Generate Password to be use to 7zip
Function generate_password()
{
    Add-Type -AssemblyName 'System.Web'
    $pass = [System.Web.Security.Membership]::GeneratePassword((Get-Random -Minimum 20 -Maximum 32),3)
    Return $pass
}
try
{
    generate_password
}
catch
{
    Write-Output "Password Generated"
}