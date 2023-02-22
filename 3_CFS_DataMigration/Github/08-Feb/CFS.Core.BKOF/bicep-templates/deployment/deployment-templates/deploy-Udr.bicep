targetScope = 'subscription'

param udrObject object
param environmentPrefix string

resource rgDeploy 'Microsoft.Resources/resourceGroups@2021-04-01' existing = [for rg in udrObject.routeValues: {
  name: 'rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}'
}]

module deployRoute '../../modules/Microsoft.Network/routeTables/deployRoutes.bicep' = [for route in udrObject.routeValues:  {
  name: 'deployRoute-${route.routeTable}'
  scope: resourceGroup('rg-${environmentPrefix}-${(route.location == 'australiaeast') ? 'edc' : 'sdc' }-${route.serviceAbbrv}-${route.component}-00${route.instance}')
  params: {
    routeTableName: route.routeTable
    routeRules: route.routeRules
  }
}]
