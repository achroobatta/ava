param acrName string
param location string
param acrSku string
param managedIdentityName string
param manageIdentityResourceGroupName string
param keyVaultName string
param keyVaultResourceGroupName string
param key_id string
var privateEndpointName = '${acrName}-privateEndpoint'
param vnetName string 
param subnetName string
param vnetResourceGroupName string


resource ManageIdentity_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: managedIdentityName
  scope: resourceGroup(manageIdentityResourceGroupName)
}

resource keyVault_resource 'Microsoft.KeyVault/vaults@2016-10-01' existing = {
  name: keyVaultName
  scope: resourceGroup(keyVaultResourceGroupName)
}

resource vnet_resource 'Microsoft.Network/virtualNetworks@2019-04-01'existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
}


resource acrName_resource 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
     '${ManageIdentity_resource.id}': {}
    }
  }
  properties: {
    adminUserEnabled: true
    networkRuleSet: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
      exportPolicy: {
        status: 'enabled'
      }
    }
    encryption: {
      status: 'enabled'
      keyVaultProperties: {
        identity: reference(ManageIdentity_resource.id, '2018-11-30').clientId
        keyIdentifier: key_id
      }
    }
    dataEndpointEnabled: false
    publicNetworkAccess: 'Disabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: 'Disabled'
    anonymousPullEnabled: false
  }
}

resource privateEndpoint_resource 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: '${vnet_resource.id}/subnets/${subnetName}'
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: resourceId('Microsoft.ContainerRegistry/registries', acrName)
          groupIds: [
            'registry'
          ]
        }
      }
    ]
  }
}
