@description('SQL Server Administrator Account')
param administratorLogin string

@description('SQL Server Administrator Password')
@secure()
param administratorLoginPassword string

@description('SQL Server location')
param location string

@description('SQL Server Name')
param sqlServerName string

resource sqlServerName_resource 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    version: '12.0'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}
