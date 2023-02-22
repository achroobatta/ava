param aseName string
param location string
param virtualNetworkSubscriptionId string
param dedicatedHostCount int = 0
param zoneRedundant bool = false
param virtualNetworkName string
param virtualNetworkResourceGroup string
param subnetName string
param subnetAddress string
var delegationName = 'delegation-${aseName}'
param ilbMode int
var privateZoneName = '${aseName}.appserviceenvironment.net'

param storageAccountId string
param workspaceId string

module existingVirtualNetworkTemplate 'nested_existingVirtualNetworkTemplate.bicep' = {
  name: 'existingVirtualNetworkTemplate'
  scope: resourceGroup(virtualNetworkSubscriptionId, virtualNetworkResourceGroup)
  params: {
    virtualNetworkName: virtualNetworkName
    subnetName: subnetName
    subnetAddress: subnetAddress
    delegationName: delegationName
  }
}

resource virtualNetwork_resource 'Microsoft.Network/virtualnetworks@2015-05-01-preview' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource aseName_resource 'Microsoft.Web/hostingEnvironments@2019-08-01' = {
  name: aseName
  kind: 'ASEV3'
  location: location
  properties: {
    name: aseName
    location: location
    dedicatedHostCount: dedicatedHostCount
    zoneRedundant: zoneRedundant
    internalLoadBalancingMode: ilbMode
    virtualNetwork: {
      id: '${virtualNetwork_resource.id}/subnets/${subnetName}'
    }
  }
  tags: {}
  dependsOn: [
    existingVirtualNetworkTemplate
  ]
}

resource privateZoneName_resource 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateZoneName
  location: 'global'
  properties: {}
  dependsOn: [
    aseName_resource
  ]
}

resource privateZoneName_vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateZoneName_resource
  name: 'vnetLink'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetwork_resource.id
    }
    registrationEnabled: false
  }
}

resource privateDnsZones_All 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
  parent: privateZoneName_resource
  name: '*'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: reference('${aseName_resource.id}/configurations/networking', '2019-08-01').internalInboundIpAddresses
      }
    ]
  }
}

resource privateDnsZones_scm 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
  parent: privateZoneName_resource
  name: '*.scm'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: reference('${aseName_resource.id}/configurations/networking', '2019-08-01').internalInboundIpAddresses
      }
    ]
  }
}

resource privateDnsZones_at 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
  parent: privateZoneName_resource
  name: '@'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: reference('${aseName_resource.id}/configurations/networking', '2019-08-01').internalInboundIpAddresses
      }
    ]
  }
}

resource aseName_DiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${aseName}'
  scope: aseName_resource
  properties: {
    logs: [
      {
        category: 'AppServiceEnvironmentPlatformLogs'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
    ]
    storageAccountId: storageAccountId
    workspaceId: workspaceId
  }
  dependsOn: [
    aseName_resource
  ]
}

