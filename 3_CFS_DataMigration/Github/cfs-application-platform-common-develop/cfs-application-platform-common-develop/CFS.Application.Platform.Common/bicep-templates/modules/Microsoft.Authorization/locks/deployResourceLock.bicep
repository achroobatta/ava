
param resourceGroupName string
param lockType string = 'CanNotDelete'

resource nameOfResource_resource 'Microsoft.Authorization/locks@2017-04-01' = {
  name: resourceGroupName
  properties: {
    level: lockType
    notes: 'CanNotDelete Resource Lock to prevent accidental deletion'
  }
}
