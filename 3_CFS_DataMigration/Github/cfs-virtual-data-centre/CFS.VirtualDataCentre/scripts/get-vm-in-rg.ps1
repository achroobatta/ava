[CmdletBinding()]
param (
		[Parameter(Mandatory=$true)] [string] $rgName,
		[Parameter(Mandatory=$true)] [string] $vmName
)
#example usage
#.\get-vm-in-rg.ps1 -rgName 'rg-np-edc-oper-ado-agent-3TST' -vmName 'VMNPEDCADO3TST'

$ErrorActionPreference="Stop"


try {
	$rawRgs=(az group list --query "[?name=='$($rgName)']")
	if (($null -ne $rawRgs) -And ('' -ne $rawRgs)) {
	$jsonRgs=($rawRgs| ConvertFrom-Json)
	if ($jsonRgs.Count -gt 0) {
		$rawVms=(az vm list --resource-group "$($rgName)" --query "[?name=='$($vmName)']")
		if (($null -ne $rawVms) -And ('' -ne $rawVms)) {
			$jsonVms=($rawVms| ConvertFrom-Json)
			if ($jsonVms.Count -gt 0) {
				Write-Debug "vm count $($jsonVms.Count)"
				foreach ($vm in $jsonVms) {
					if ($vm.name -eq $vmName) {
						return ((az vm show --resource-group "$($rgName)" --name "$($vmName)" --show-details)|ConvertFrom-Json)
					}
				}
			} else {
				Write-Debug "vm array is empty"
			}
		} else {
			Write-Debug "vm array is null"
		}
	} else {
		Write-Debug "rg array is empty"
	}
	} else {
		Write-Debug "rg array is null"
	}
}
catch
{
	Write-Error "error"
}
