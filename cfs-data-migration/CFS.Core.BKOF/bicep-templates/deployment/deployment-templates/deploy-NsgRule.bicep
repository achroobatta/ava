targetScope = 'subscription'

param environmentPrefix string
param nsgObject object

// resource rgDeploy 'Microsoft.Resources/resourceGroups@2021-04-01' existing = [for rg in nsgObject.nsgValues: {
//   name: rg.resourceGroup
// }]

module deployNSGRule '../../modules/Microsoft.Network/NetworkSecurityGroups/deployNSGRules.bicep' = [for nsg in nsgObject.nsgValues:  {
  name: '${nsg.nsgName}'
  scope: resourceGroup('rg-${environmentPrefix}-${(nsg.location == 'australiaeast') ? 'edc' : 'sdc' }-${nsg.serviceAbbrv}-${nsg.component}-00${nsg.instance}')
  params: {
    nsgName: nsg.nsgName
    nsgRules: nsg.securityRules
  }
}]

