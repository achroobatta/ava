param firewallPoliciesName string
param location string
param tier string
param dnsServers array 
param RuleCollectionObject object
param isSnatDisabled bool

@allowed( [
  'Alert'
  'Deny'
  'Off'
])
param intrusionDetectionMode string = 'Alert'

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string


resource firewallPoliciesName_resource 'Microsoft.Network/firewallPolicies@2020-11-01' = {
  name: firewallPoliciesName
  location: location
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  properties: {
    sku: {
      tier: tier
    }
    threatIntelMode: 'Alert'
    threatIntelWhitelist: {
      fqdns: []
      ipAddresses: []
    }
    intrusionDetection: (tier == 'Premium') ? {
      mode: intrusionDetectionMode
    }: null
	//By default, SNAT is enabled for all except IANA RFC 1918 ranges. A privateRanges of 0.0.0.0/0 will disable SNAT
    snat: (isSnatDisabled == true) ? {
      privateRanges: [
        '0.0.0.0/0'
      ]
    } : {}
    dnsSettings: {
      servers: dnsServers
      enableProxy: true
    }
  }
}

@batchSize(1)
resource firewallPoliciesName_DefaultRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = [for rule in RuleCollectionObject.RuleCollectionGroup : {
  name: '${firewallPoliciesName}/${rule.name}'
  properties: {
    priority: rule.priority
    ruleCollections: rule.ruleCollections
  }
  dependsOn: [
    firewallPoliciesName_resource
  ]
}]

