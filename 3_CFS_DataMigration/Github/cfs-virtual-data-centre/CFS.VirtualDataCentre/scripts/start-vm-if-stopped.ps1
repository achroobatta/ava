[CmdletBinding()]
param (
		[Parameter(Mandatory=$true)] [string] $rgName,
		[Parameter(Mandatory=$true)] [string] $vmName
)
#example usage
#.\start-vm-if-stopped.ps1 -rgName 'rg-np-edc-oper-ado-agent-3TST' -vmName 'VMNPEDCADO3TST'

#This is useful when you want to refer to the script's directory path.
$ScriptDir=Split-Path $MyInvocation.MyCommand.Path

"Original `$ErrorActionPreference='$($ErrorActionPreference)'"
$ErrorActionPreference="Stop"
"New `$ErrorActionPreference='$($ErrorActionPreference)'"

$vm=(& "$($ScriptDir)\get-vm-in-rg.ps1" -rgName $rgName -vmName $vmName)

if (! $vm)
{
	"VM '$vmName' in RG '$rgName' was not found."
	return
}

$onStatuses=@('VM starting', 'VM running')
$currentState=$vm.powerState

if (($vm.name -ne $vmName) -Or ($vm.resourceGroup -ne $rgName))
{
	Write-Error "Error (VM '$($vm.name)' -ne '$vmName') -Or (RG '$($vm.resourceGroup)' -ne '$rgName')"
}

if ($currentState -And !($onStatuses -Contains $currentState))
{
	"need to start vm '$($vmName)' : currentState=$currentState"
	az vm start --resource-group "$($rgName)" --name "$($vmName)"
	$newState=((az vm show --resource-group "$($rgName)" --name "$($vmName)" --show-details)|ConvertFrom-Json).powerState
	"newState=$newState"
} else {
	"vm is running - no need to start vm '$($vmName)' : currentState=$currentState"
}
