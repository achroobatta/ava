[CmdletBinding()]
param (
	[Parameter(Mandatory=$true)] [string] $envPrefix
)
#Usage .\run-sudoers.ps1 -envPrefix 'np'
#Usage .\run-sudoers.ps1 -envPrefix 'prd'

#This is useful when you want to refer to the script's directory path.
$ScriptDir=Split-Path $MyInvocation.MyCommand.Path

if (! (($envPrefix -eq 'np') -Or ($envPrefix -eq 'prd')) ) {
	Write-Error "invalid -envPrefix parameter"
	Exit 1
}

$subscriptions=(az account list)|ConvertFrom-Json
$securitySubscriptionId=($subscriptions | Where-Object { $_.name -eq "subsc-$envPrefix-security-001" }).id

if ( ! ($securitySubscriptionId) ) {
	Write-Error "unable to determine `$securitySubscriptionId"
	Exit 1
}

az account set --subscription "$securitySubscriptionId"
$discoverySecret=(az keyvault secret show --name "discovery-linux" --vault-name "kv-$envPrefix-edc-security-001" --query "value")

if ( ! ($discoverySecret) ) {
	Write-Error "unable to retrieve discoverySecret from keyvault"
	Exit 1
}

$qualysSecret=(az keyvault secret show --name "qualys-linux" --vault-name "kv-$envPrefix-edc-security-001" --query "value")

if ( ! ($qualysSecret) ) {
	Write-Error "unable to retrieve qualysSecret from keyvault"
	Exit 1
}

foreach ($sub in $subscriptions) {
  $subscriptionId=$sub.id
  $subscriptionName=$sub.name

  az account set --subscription "$subscriptionId"

  $vmsInSubscription=(az resource list --query "[? (type == 'Microsoft.Compute/virtualMachines') ].{rgName:resourceGroup,vmName:name}")

  foreach ($vmInfo in ($vmsInSubscription|ConvertFrom-Json)) {
    $rgName=$vmInfo.rgName
	$vmName=$vmInfo.vmName

    $vmDetails=(az vm show --resource-group "$rgName" --name "$vmName" --show-details)|ConvertFrom-Json
    if ($vmDetails.storageProfile.osDisk.osType -eq 'Linux')
    {
	  "Time: $((Get-Date).ToString("o"))"
      "SubscriptionId='$subscriptionId'"
      "SubscriptionName='$subscriptionName'"
      "rgName='$rgName'"
	  "vmName='$vmName'"
	  "privateIps='$($vmDetails.privateIps)'"

	  "Time: $((Get-Date).ToString("o"))"
      az vm run-command invoke --command-id RunShellScript `
        --name "$vmName" -g "$rgName" `
        --scripts @$ScriptDir\sudoers_servicenowdiscovery.bash `
        --parameters $discoverySecret

	  "Time: $((Get-Date).ToString("o"))"
      az vm run-command invoke --command-id RunShellScript `
        --name "$vmName" -g "$rgName" `
        --scripts @$ScriptDir\sudoers_qualys.bash `
        --parameters $qualysSecret

	  "Time: $((Get-Date).ToString("o"))"
      "============================`r`n`r`n"
    }
  }
}

