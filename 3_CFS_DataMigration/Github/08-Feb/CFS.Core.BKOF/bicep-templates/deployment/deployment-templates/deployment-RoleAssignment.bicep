param principalId string

param vmName string

param subscriptionId string

param vmRG string 

param kvRG string


// module deployRoleKV '../../modules/Microsoft.Compute/deployRoleAssignmentsKV.bicep'  = {
//   name:  'roleAssignmentforKV'
//   params:{
//     principalId: principalId 
//     vmName: vmName          
//   }   
//   scope: resourceGroup(subscriptionId, kvRG)    
// }

// module deployRoleVM '../../modules/Microsoft.Compute/deployRoleAssignmentsVM.bicep'  = {
//   name:  'roleAssignmentforVM'
//   params:{
//     principalId: principalId 
//     vmName: vmName         
//   }   
//   scope: resourceGroup(subscriptionId, vmRG)    
// }
