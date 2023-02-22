
@description('location')
param location string = resourceGroup().location

param vmName string = 'demovm' 


@description('clientId of management Identity')
param identity string = 'a0148e79-f712-4e7d-b6d6-a3a017a6aa29'

// @description('tags of the project')
// param tags object



var file = 'C:\\Users\\demousr\\Attach.ps1'

var commandToExecute = 'powershell -ExecutionPolicy Unrestricted -File ${file}'           

resource vm_customScriptExtensions 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {  
  name: '${vmName}/attachExtension'
  location: location
  // tags: tags 
  properties: {      
    typeHandlerVersion: '1.10'    
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    // forceUpdateTag: 'true'    
    settings: {
      timestamp: 123456789
    }
    protectedSettings: {
      // fileUris: ['https://${storageAccountName}.blob.core.windows.net/data/InstallGatewayOnLocalMachine.ps1']
      commandToExecute: commandToExecute
      managedIdentity : {        
        clientId: identity
       }       
    }             
  }
}
