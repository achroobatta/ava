targetScope = 'subscription'

@description('The string value for the environment')
param environmentPrefix string

@description('The string value for the IP Group resource group location')
param location string

@description('The string value for the IP Group resource group service abbreviation')
param serviceAbbrv string

@description('The string value for the IP Group resource group component abbreviation')
param component string

@description('The string value for the IP Group resource group instance component')
param instance int

@description('The string value for the IP Group resource location')
param ipg_location string

param ipGroupObject object

resource rgDeploy 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'rg-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc' }-${serviceAbbrv}-${component}-00${instance}'
}

@batchSize(1)
module ipGroup '../../modules/Microsoft.Network/azureFirewall/deployIPGroup.bicep' = [for ipg in ipGroupObject.ipGroups:  {
  name: 'ipGroup-${ipg.ipGroupName}'
  scope: resourceGroup(rgDeploy.name)
  params: {
    ipGroupName: ipg.ipGroupName
    location: ipg_location
    ipAddresses: ipg.ipAddresses
  }
}]
