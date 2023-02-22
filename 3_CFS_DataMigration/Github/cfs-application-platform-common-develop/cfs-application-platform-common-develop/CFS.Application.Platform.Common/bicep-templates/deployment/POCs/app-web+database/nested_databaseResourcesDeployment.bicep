param resourceId_Microsoft_Network_virtualNetworks_subnets_parameters_vnetName_parameters_privateEndpointSubnet string
param resourceId_Microsoft_Sql_servers_parameters_serverName string
param resourceId_Microsoft_Network_privateDnsZones_parameters_privateDnsZoneNameForDb string
param variables_databaseResourcesDeployment string
param variables_databaseVersion string
param isVnetEnabled bool
param privateEndpointNameForDb string
param location string
param serverName string
param serverUsername string

@secure()
param serverPassword string
param databaseName string
param collation string
param sqlDbSkuName string
param sqlDbTierName string
param storageAccountName string
param storageAccountSubscriptionId string

var permissionRoleGuid = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var minimalTlsVersion = '1.2'
var retentionDays = 90
var publicNetworkAccess = 'Enabled'

resource serverName_resource 'Microsoft.Sql/servers@2021-08-01-preview' = {
  name: serverName
  location: location
  tags: {}
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: serverUsername
    administratorLoginPassword: serverPassword
    version: variables_databaseVersion
    minimalTlsVersion: minimalTlsVersion
    publicNetworkAccess: publicNetworkAccess
  }
}

resource serverName_databaseName 'Microsoft.Sql/servers/databases@2021-08-01-preview' = {
  name: '${serverName}/${databaseName}'
  location: location
  tags: {}
  properties: {
    collation: collation
  }
  sku: {
    name: sqlDbSkuName
    tier: sqlDbTierName
  }
  dependsOn: [
    serverName_resource
  ]
}

resource serverName_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2021-08-01-preview' = {
  name: '${serverName}/AllowAllWindowsAzureIps'
  location: location
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
  dependsOn: [
    serverName_resource
  ]
}

module variables_databaseResourcesDeployment_vnet './nested_variables_databaseResourcesDeployment_vnet.bicep' = if (isVnetEnabled) {
  name: '${variables_databaseResourcesDeployment}-vnet'
  params: {
    privateEndpointNameForDb: privateEndpointNameForDb
    location: location
    resourceId_Microsoft_Network_virtualNetworks_subnets_parameters_vnetName_parameters_privateEndpointSubnet: resourceId_Microsoft_Network_virtualNetworks_subnets_parameters_vnetName_parameters_privateEndpointSubnet
    resourceId_Microsoft_Sql_servers_parameters_serverName: resourceId_Microsoft_Sql_servers_parameters_serverName
    resourceId_Microsoft_Network_privateDnsZones_parameters_privateDnsZoneNameForDb: resourceId_Microsoft_Network_privateDnsZones_parameters_privateDnsZoneNameForDb
  }
  dependsOn: [
    serverName_resource
  ]
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: storageAccountName
}

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: permissionRoleGuid
}

resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(storageAccountSubscriptionId, roleDefinition.id)
  scope: storageAccount
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: serverName_resource.identity.principalId
  }
  dependsOn: [
    serverName_resource
  ]
}

resource auditSettings 'Microsoft.Sql/servers/auditingSettings@2021-08-01-preview' = {
  name: '${serverName}/Default'
  properties: {
    retentionDays: retentionDays
    auditActionsAndGroups: [
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
      'BATCH_COMPLETED_GROUP'
    ]
    isStorageSecondaryKeyInUse: false
    isAzureMonitorTargetEnabled: false
    state: 'Enabled'
    storageEndpoint: 'https://${storageAccountName}.blob.core.windows.net'
    storageAccountSubscriptionId: storageAccountSubscriptionId
  }
  dependsOn:[
    serverName_resource
    //storageRoleAssignment
  ]
}
resource extendedAuditingSettings 'Microsoft.Sql/servers/extendedAuditingSettings@2021-08-01-preview' = {
  name: '${serverName}/Default'
  properties: {
    retentionDays: retentionDays
    auditActionsAndGroups: [
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
      'BATCH_COMPLETED_GROUP'
    ]
    isStorageSecondaryKeyInUse: false
    isAzureMonitorTargetEnabled: false
    state: 'Enabled'
    storageEndpoint: 'https://${storageAccountName}.blob.core.windows.net'
    storageAccountSubscriptionId: storageAccountSubscriptionId
  }
  dependsOn:[
    serverName_resource
    //storageRoleAssignment
  ]
}
resource securityAlertsPolicies 'Microsoft.Sql/servers/securityAlertPolicies@2021-08-01-preview' = {
  name: '${serverName}/Default'
  properties: {
    state: 'Enabled'
    disabledAlerts: []
    emailAddresses: [
      'Cfs-azure-nonprod-admin@ausupnonp.onmicrosoft.com'
    ]
    emailAccountAdmins: true
    retentionDays: 0
  }
  dependsOn:[
    serverName_resource
  ]
}
