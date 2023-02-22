param ipGroupName string
param location string
param ipAddresses array

resource ipGroup_resource 'Microsoft.Network/ipGroups@2021-05-01' = {
  name: ipGroupName
  location: location
  properties: {
    ipAddresses: ipAddresses
  }
}
