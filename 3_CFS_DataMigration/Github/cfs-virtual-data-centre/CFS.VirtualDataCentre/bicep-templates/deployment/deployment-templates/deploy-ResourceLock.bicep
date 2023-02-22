targetScope = 'subscription'

param rgArray array
var lockType = 'CanNotDelete'

param environmentPrefix string


resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = [for rg in rgArray : {
  name: 'rg-${environmentPrefix}-${(rg.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}'
}]


module deloyResourceLock '../../modules/Microsoft.Authorization/locks/deployResourceLock.bicep' = [for rg in rgArray : {
  name: 'deploylock-rg-${environmentPrefix}-${(rg.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}'
  scope: resourceGroup('rg-${environmentPrefix}-${(rg.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}')
  params: {
    resourceGroupName: 'rg-${environmentPrefix}-${(rg.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}'
    lockType: lockType
  }
}]
