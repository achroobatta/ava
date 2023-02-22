param(
    [Parameter(Mandatory=$true)]
    [String]$serviceAcctUserName
)

$msipath = "C:\Users\$serviceAcctUserName\softwares\AzureCLI\azure-cli-2.44.0.msi"
Start-Process msiexec.exe -Wait -ArgumentList "/I $msipath /quiet"