param routeTableName string

param routeRules array

resource validateRouteTable 'Microsoft.Network/routeTables@2021-05-01' existing = {
  name: routeTableName
}

resource routeTableRoute 'Microsoft.Network/routeTables/routes@2021-05-01' = [for (rule, i) in routeRules : {
  name: '${routeTableName}/${rule.name}'
  properties: rule.properties
  dependsOn: [
    validateRouteTable
  ]
}]
