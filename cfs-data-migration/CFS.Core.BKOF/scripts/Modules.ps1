#create by: Joshua Ira San Ramon
try
{
    $modules = get-installedmodule
    if ($null -eq $modules)
    {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        Install-Module Az.KeyVault -force
        Install-Module Az.Accounts -force
        Install-Module Az.Storage -force
        Install-Module Az.Resources -force

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Install-Module -Name 7Zip4PowerShell -Force
        Set-PSRepository -Name 'PSGallery' -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

        return "Modules has been installed"
    }
    else
    {
        return "Modules is already installed"
    }
}
catch
{
    return "Unable to install Modules"
}