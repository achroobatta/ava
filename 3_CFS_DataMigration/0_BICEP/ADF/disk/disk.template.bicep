param diskName string = 'data2'

param diskLocation string = resourceGroup().location 

param diskSku string = 'Premium_LRS'

// resource dataDisk 'Microsoft.Compute/disks@2022-07-02' = {
//   name: diskName
//   location: diskLocation
//   sku: {
//     name: diskSku
//   }  
//   properties: {
//     // tier: 'P60'
//     diskSizeGB: 8
//     creationData: {
//       createOption: 'Empty'

//     }
//   }
// }

resource dataDisk 'Microsoft.Compute/disks@2022-07-02' = {
    name: diskName
    location: diskLocation
    sku: {
      name: diskSku
    }  
    properties: {
      // tier: 'P60'
      diskSizeGB: 8
      creationData: {
        createOption: 'Empty'
  
      }
    }
  }


  output dataDiskName string =  dataDisk.name
  output dataDiskId string = dataDisk.id
  