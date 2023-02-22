targetScope = 'resourceGroup'

param virtualEnvironment object
param regionPrefix string

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string
@description('The string value for owner tag')
param owner string
@description('The string value for CostCenter tag')
param costCenter string
@description('Environment')
param environmentPrefix string

param workspaceId string
param storageAccountId string

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

var subnetName = 'sub-${environmentPrefix}-${regionPrefix}-${virtualEnvironment.serviceAbbrv}-${virtualEnvironment.component}-001'
var routeTableName = 'rt-${environmentPrefix}-${regionPrefix}-${virtualEnvironment.serviceAbbrv}-${virtualEnvironment.component}-001'
var nsgName = 'nsg-${environmentPrefix}-${regionPrefix}-${virtualEnvironment.serviceAbbrv}-${virtualEnvironment.component}-001'

// create a route table
module routeTable '../../../modules/Microsoft.Network/routeTables/deployRouteTable.bicep' = {
  name: routeTableName
  params: {
    rtName: routeTableName
    disableBGPProp: true
    routes: []
    appName: virtualEnvironment.component
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}

// and an nsg
module nsg '../../../modules/Microsoft.Network/NetworkSecurityGroups/deployNSG.bicep' = {
  name: nsgName
  params: {
    nsgName: nsgName
    location: virtualEnvironment.location
    environmentPrefix: environmentPrefix
    workspaceId: workspaceId
    storageAccountId: storageAccountId
    appName: virtualEnvironment.component
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  dependsOn: [
    routeTable
  ]
}

// create a subnet 
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: '${virtualEnvironment.vnetName}/${subnetName}'
  properties: {
    addressPrefix: virtualEnvironment.subnetAddressPrefix
    networkSecurityGroup: {
      id: resourceId('Microsoft.Network/networkSecurityGroups', nsgName)
    }
    routeTable: {
      id: resourceId('Microsoft.Network/routeTables', routeTableName)
    }
  }
}
