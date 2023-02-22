targetScope = 'subscription'

param resourceGroup string
param appName string
param firewallPoliciesName string
param location string
param tier string
param dnsServers array
param RuleCollectionObject object
param isSnatDisabled bool

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string
param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('Environment')
param environmentPrefix string
param owner string
param costCenter string

resource rgDeploy 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroup
}

module firewallPolicy '../../modules/Microsoft.Network/azureFirewall/deployFirewallRule.bicep' = {
  name: firewallPoliciesName
  scope: rgDeploy
  params: {
    firewallPoliciesName: firewallPoliciesName
    location: location
    tier: tier
    dnsServers: dnsServers
    RuleCollectionObject: RuleCollectionObject
    isSnatDisabled: isSnatDisabled
    appName: appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}
