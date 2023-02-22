targetScope = 'subscription'

var prefix = 'demo'
var uniqueSubString = uniqueString(guid(subscription().subscriptionId))
var uString = '${prefix}-${uniqueSubString}'

var resourceGroupName = '${substring(uString, 0, 6)}sql-rg'
var serverName  = '${substring(uString, 0, 6)}sql-server'

param location string = 'australiaeast'

@description('The administrator username of the SQL logical server.')
param adminUsername string  

@description('The administrator password of the SQL logical server.')
@secure()
param adminPassword string

@description('CostCenter pulled from serviceNow')
param costCenter string = 'CFS2022'

@description('ServiceRequest number pulled from serviceNow')
param serviceRequest string = 'RQ2022'

@description('StartDate pulled from serviceNow')
param startDate string = utcNow()

@description('EndtDate pulled from serviceNow')
param endDate string = utcNow()

@description('')
param spokeVnetName string = 'spokevnet'

@description('')
param SpokeVnetCidr string = '10.178.0.0/16'
@description('')
param PrivateSubnetCidr string = '10.178.0.0/18'
@description('')
param PublicSubnetCidr string = '10.178.64.0/18'
@description('')
param PrivateLinkSubnetCidr string = '10.178.192.0/18'

// dateTime = dateTimeAdd()

// var defaultDate = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))
// var convertedDatetime = dateTimeFromEpoch(convertedEpoch)

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location 
  tags: {
    Costcenter: costCenter
    Servicerequest: serviceRequest
    Startdate: startDate
    Enddate: endDate
  }
}

module sql './sql.bicep' = {
  name: 'sqlModule'
  scope: rg 
  params: {
    location: location
    serverName: serverName
    adminPassword: adminPassword
    adminUsername: adminUsername
    costCenter: costCenter
    serviceRequest: serviceRequest
    startDate: startDate
    endDate: endDate   
  }
}

module vnets './network/vnet.template.bicep' = {
  scope: rg
  name: 'HubandSpokeVnets'
  params: {
    spokeVnetName: spokeVnetName
    // securityGroupName: nsg.outputs.nsgName  
    spokeVnetCidr: SpokeVnetCidr
    publicSubnetCidr: PublicSubnetCidr
    privateSubnetCidr: PrivateSubnetCidr
    privatelinkSubnetCidr: PrivateLinkSubnetCidr   
  }
}

// module privateEndPoints './network/privateendpoint.template.bicep' = {
//   scope: rg
//   name: 'PrivateEndPoints'
//   params: {    
//     privateLinkSubnetId: vnets.outputs.privatelinksubnet_id
//     storageAccountName: adlsGen2.name
//     storageAccountPrivateLinkResource: adlsGen2.outputs.storageaccount_id   
//     vnetName: vnets.outputs.spokeVnetName
//   }
// }
