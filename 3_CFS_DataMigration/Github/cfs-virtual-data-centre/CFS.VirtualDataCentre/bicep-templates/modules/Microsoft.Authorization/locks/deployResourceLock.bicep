
param resourceGroupName string
param lockType string

resource nameOfResource_resource 'Microsoft.Authorization/locks@2017-04-01' = {
  name: resourceGroupName
  properties: {
    level: lockType
    notes: '${(lockType == 'CanNotDelete') ? 'CanNotDelete Resource Lock to prevent accidental deletion' : 'ReadOnly resource lock' }'
  }
}
