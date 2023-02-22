[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)] [String] $moduleName
)

Install-Module -name $moduleName -Force -AllowClobber
