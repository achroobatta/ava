@description('availability set name')
param availabilitySetName string

@description('location')
param location string

@description('Availability Set Objects')
param availabilityObject object

@description('Parameters for resource tags')
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

resource availabilitySet 'Microsoft.Compute/availabilitySets@2021-07-01' = [for i in availabilityObject.availabilitySets : {
    name: '${availabilitySetName}-${i.availabilitySet_abbv}'
    location: location
    tags: {
      appName: i.appName
      environment: environmentPrefix
      owner: owner
      costCenter: costCenter
      createOnDate: createOnDate
    }
    sku: {
      name: 'Aligned'
    }
    properties: {
      platformFaultDomainCount: i.platformFaultDomainCount
      platformUpdateDomainCount: i.platformUpdateDomainCount
    }
  }]
