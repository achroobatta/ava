targetScope = 'subscription'

@description('Parameters for AvailabilitySets')
param availabilitySetObject object

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string
@description('The string value for owner tag')
param owner string
@description('The string value for CostCenter tag')
param costCenter string

@description('Environment prefix thats being injected at the master pipeline')
param environmentPrefix string

resource resourcegroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = [for rg in availabilitySetObject.resourceGroups: {
  name: 'rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.service}-${rg.component}-00${rg.rg_instance}'
}]

@batchSize(1)
module deployAvailabilitySetModule '../../modules/Microsoft.Compute/deployAvailabilitySet.bicep' = [for (rg, i) in availabilitySetObject.resourceGroups: {
  name: 'deploy-availabilityset-${i}'
  scope: resourceGroup('rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.service}-${rg.component}-00${rg.rg_instance}')
  params: {
    availabilitySetName: 'avail-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }'
    location: rg.location
    availabilityObject: rg
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  dependsOn: [
    resourcegroup
  ]
}]
