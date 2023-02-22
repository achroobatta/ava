@description('The name of the SQL Server.')
param serverName string 

@description('The name of the SQL Database.')
param sqlDBName string = 'SampleDB'

@description('Location for all resources.')
param location string = 'australiaeast'

@description('The administrator username of the SQL logical server.')
param adminUsername string

@description('The administrator password of the SQL logical server.')
@secure()
param adminPassword string

param costCenter string 

param serviceRequest string

param startDate string 

param endDate string

resource sqlServer 'Microsoft.Sql/servers@2021-08-01-preview' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    publicNetworkAccess: 'Disabled'
    minimalTlsVersion: '1.2'
  }
  tags: {
      Costcenter: costCenter
      Servicerequest: serviceRequest
      Startdate: startDate
      Enddate: endDate
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2021-08-01-preview' = {
  parent: sqlServer
  name: sqlDBName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    
  }
  tags: {
      Costcenter: costCenter
      Servicerequest: serviceRequest
      Startdate: startDate
      Enddate: endDate
  }
  
}

// resource symbolicname 'Microsoft.Sql/servers/firewallRules@2022-02-01-preview' = {
//   name: 'firewall'
//   parent: sqlServer
//   properties: {
//     endIpAddress: '0.0.0.0'
//     startIpAddress: '0.0.0.0'
//   }
// }
