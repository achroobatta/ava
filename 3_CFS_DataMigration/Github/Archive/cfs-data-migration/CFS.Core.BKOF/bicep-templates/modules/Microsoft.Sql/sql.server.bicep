@description('SQL Server Administrator Account')
param administratorLogin string

@description('SQL Server Administrator Password')
@secure()
param administratorLoginPassword string

@description('SQL Server location')
param location string

@description('SQL Server Name')
param sqlServerName string

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

resource sqlServerName_resource 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: sqlServerName
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  } 
  location: location
  properties: {
    version: '12.0'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    publicNetworkAccess: 'Disabled'
  }
}
