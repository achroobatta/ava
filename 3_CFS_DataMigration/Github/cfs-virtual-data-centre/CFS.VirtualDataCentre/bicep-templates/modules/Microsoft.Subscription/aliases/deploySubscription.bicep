targetScope = 'tenant'

@description('Provide the full resource ID of billing scope to use for subscription creation.')
param billingScope string
param instance int
param subscriptions array = []
param environmentPrefix string

resource subscriptionAlias 'Microsoft.Subscription/aliases@2020-09-01' = [for sub in subscriptions: {
  scope: tenant()
  name: 'subsc-${environmentPrefix}-${sub.service}-00${instance}'
  properties: {
    workload: sub.workload
    displayName: 'subsc-${environmentPrefix}-${sub.service}-00${instance}'
    billingScope: billingScope
  }  
}]
 output subscriptionIds array = [for (subs, i) in subscriptions: {
    id: subscriptionAlias[i].properties.subscriptionId
 }]
