$resourceLocation = 'australiaeast'
$deploymentName = 'Test-Policies1'
$environmentPrefix = 'np'

az deployment mg create --management-group-id CFSCoNonProd --location $resourceLocation --name $deploymentName --template-file .\CFS.VirtualDataCentre\bicep-templates\deployment\deploy-policyAssignments\deployPolicy.bicep --parameters .\CFS.VirtualDataCentre\bicep-templates\deployment\deploy-policyAssignments\policy.param.$($AzureEnvironmentPrefix).json


$azureEnvironmentPrefix = 'np'

az deployment sub what-if --location australiaeast `
    --subscription subsc-np-connectivity-001 `
    --template-file .\CFS.VirtualDataCentre\bicep-templates\deployment\deploy-VDCVirtualNetwork\update-VDCVirtualNetwork.bicep `
    --parameters CFS.VirtualDataCentre\bicep-templates\deployment\connectivity.param.$($AzureEnvironmentPrefix).json `
    --parameters australiaEastOffsetSymbol=PT10H environmentPrefix=$azureEnvironmentPrefix owner='Robert Reakes' costCenter=4010 `
    --parameters storageAccountSubscriptionId='8df497d3-fea3-467a-b563-2949a9cb80ad' workspaceSubscriptionId='8df497d3-fea3-467a-b563-2949a9cb80ad'

az deployment sub what-if --location australiaeast `
    --subscription subsc-np-connectivity-001 `
    --template-file .\CFS.VirtualDataCentre\bicep-templates\deployment\deploy-RG\deployRG.bicep `
    --parameters CFS.VirtualDataCentre\bicep-templates\deployment\deploy-RG\connectivity.param.json `
    --parameters australiaEastOffsetSymbol=PT10H environmentPrefix=$azureEnvironmentPrefix owner='Robert Reakes' costCenter=4010 `

# Script to retrieve a list of policy sets (initiatives)
$set = (az policy set-definition list) | convertfrom-json

# and display the names
$set | select-object -property DisplayName | sort-object -property DisplayName

# and find a policy set by name
$set | Where-Object { $_.DisplayName -eq 'PCI v3.2.1:2018' }


az deployment sub create --location australiaeast `
    --subscription subsc-np-fwp-001 `
    --template-file .\CFS.VirtualDataCentre\bicep-templates\deployment\01-Landing-Zone\deployment-templates\deploy-VirtualEnvironment.bicep `
    --parameters .\CFS.VirtualDataCentre\bicep-templates\deployment\01-Landing-Zone\parameter-files\fwp\07-Virtual-Environment\Virtual-Environment-fwp.param.np.json `
    --parameters australiaEastOffsetSymbol=PT10H environmentPrefix=$environmentPrefix owner='Robert Reakes' costCenter=4010 `
    --parameters storageAccountSubscriptionId='8df497d3-fea3-467a-b563-2949a9cb80ad' workspaceSubscriptionId='8df497d3-fea3-467a-b563-2949a9cb80ad'


$rgs = (az group list --subscription subsc-np-fwp-001) | convertfrom-json
$rgs | where-object { $_.name -like "*sbx*" }
$rgs | where-object { $_.name -like "*sbx*" } | ForEach-Object { az group delete --name $_.name --subscription subsc-np-fwp-001 }