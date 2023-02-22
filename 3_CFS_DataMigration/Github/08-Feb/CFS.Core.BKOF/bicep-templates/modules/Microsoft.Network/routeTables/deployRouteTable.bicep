param rtName string
param disableBGPProp bool
param routes array = [] 

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

resource routetable 'Microsoft.Network/routeTables@2021-05-01' = {
  name: rtName
  location: resourceGroup().location
  properties: {
    disableBgpRoutePropagation: disableBGPProp
    routes: routes
  }
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}

output id string = routetable.id
