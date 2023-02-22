targetScope = 'managementGroup'

param roleAssignmentArray array

module contributorModule '../../modules/Microsoft.Authorization/roleAssignment/managementGroup/deployContibutorRoleAssignmentToManagementGroup.bicep' = [for mg in roleAssignmentArray: if (contains(mg.DisplayName, 'contributor')) {
  name: 'contributor-${mg.DisplayName}'
  params: {
    managementGroupId: mg.managementGroupId
    objectId: mg.ObjectId
  }
}]

module ownerModule '../../modules/Microsoft.Authorization/roleAssignment/managementGroup/deployOwnerRoleAssignmentToManagementGroup.bicep' = [for mg in roleAssignmentArray: if (contains(mg.DisplayName, 'owner')) {
  name: 'owner-${mg.DisplayName}'
  params: {
    managementGroupId: mg.managementGroupId
    objectId: mg.ObjectId
  }
}]

module readerModule '../../modules/Microsoft.Authorization/roleAssignment/managementGroup/deployReaderRoleAssignmentToManagementGroup.bicep' = [for mg in roleAssignmentArray: if (contains(mg.DisplayName, 'reader')) {
  name: 'reader-${mg.DisplayName}'
  params: {
    managementGroupId: mg.managementGroupId
    objectId: mg.ObjectId
  }
}]
