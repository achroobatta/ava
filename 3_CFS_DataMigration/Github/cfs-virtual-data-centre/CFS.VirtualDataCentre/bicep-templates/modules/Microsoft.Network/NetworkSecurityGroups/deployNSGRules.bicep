param nsgName string
param nsgRules array

resource validateNsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' existing = {
  name: nsgName
}

resource nsgName_ruleName 'Microsoft.Network/networkSecurityGroups/securityRules@2020-04-01' = [for nsg in nsgRules: {
  name: '${nsgName}/${nsg.name}'
  properties: {
    description: nsg.properties.description
    protocol: nsg.properties.protocol
    sourcePortRange: nsg.properties.sourcePortRange
    destinationPortRange: nsg.properties.destinationPortRange
    sourceAddressPrefix: nsg.properties.sourceAddressPrefix
    destinationAddressPrefix: nsg.properties.destinationAddressPrefix
    access: nsg.properties.access
    priority: nsg.properties.priority
    direction: nsg.properties.direction
    sourcePortRanges: nsg.properties.sourcePortRanges
    destinationPortRanges: nsg.properties.destinationPortRanges
    sourceAddressPrefixes: nsg.properties.sourceAddressPrefixes
    destinationAddressPrefixes: nsg.properties.destinationAddressPrefixes
  }
  dependsOn: [
    validateNsg
  ]
}]
