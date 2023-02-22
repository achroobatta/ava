@description('Provide the name of the Azure Key Vault')
param keyVaultName string

@description('Provide the Tenant ID of the Azure Activ Directory who will handle Key Vault authentication')
param azureTenantId string

@description('Location used will be the same as the resource group')
param keyVaultResourceGroupLocation string

// @description('parameters for key')
// param vaultkeyEncryptName string

// @description('Parameters for secret')
// param localAdminPasswordSecretName string
// param localAdminPassword string

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

resource keyVaultResource 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: keyVaultResourceGroupLocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  properties: {
    tenantId: azureTenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    enablePurgeProtection: true
    enableRbacAuthorization: true
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}

/*
resource vaultkeyEncrypt 'Microsoft.KeyVault/vaults/keys@2021-06-01-preview' = { 
  parent: keyVaultResource
  name: vaultkeyEncryptName
  properties: {
    keySize: 3072
    kty: 'RSA'
    attributes: {
      enabled: true
    }
  }
}

//create a secret for the local administrator password for VMs
resource localAdminPasswordVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: localAdminPasswordSecretName
  parent: keyVaultResource
  properties: {
    attributes: {
      enabled: true
      exp: 1619658768
    }
    value: localAdminPassword
  }
}
*/
