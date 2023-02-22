param location string = 'australiaeast'

// param tags object 

param vmName string = 'cfsn5aShirPc'

resource symbolicname 'Microsoft.Compute/virtualMachines/runCommands@2022-08-01' = {
  name: '${vmName}/runCommandOnVM'
  location: location 
  // tags: tags
  
  properties: {
    // asyncExecution: true
    // errorBlobUri: 'https://demosa98011.blob.core.windows.net/error'
    // outputBlobUri: 'https://demosa98011.blob.core.windows.net/output'
    runAsPassword: 'Administrator@890'
    runAsUser: 'demousr'
    source: {
      // commandId: 'RunPowerShellScript'
      // script: 'function create_volume([string] $storageFriendlyName, [string] $driveLetter, [array] $disk) New-StoragePool -FriendlyName $storageFriendlyName -StorageSubsystemFriendlyName (Get-StorageSubsystem -FriendlyName *Windows*).FriendlyName -PhysicalDisks $disk | New-VirtualDisk -FriendlyName \'striped\' -NumberOfColumns $disk.Count -ResiliencySettingName \'Simple\' -UseMaximumSize | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -DriveLetter $driveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel \'Striped Volume\' -Confirm:$false -UseLargeFRS } [array]$PhysicalDisks = Get-StorageSubSystem -FriendlyName \'Windows*\' | Get-PhysicalDisk -CanPool $True if ($PhysicalDisks -eq $null) { Write-Error \'Nothing is available to pool\' } else { [array]$source=@() [array]$target=@() foreach ($disks in  $PhysicalDisks) { if($disks.DeviceId%2 -eq 0) { $source += $disks } else { $target += $disks } } create_volume \'SourcePool\' \'S\' $source create_volume \'TargetPool\' \'T\' $target } write-output \'End\' '
      scriptUri: 'https://demosa98011.blob.core.windows.net/info/Stripe.ps1'
      // scriptUri: 'C:\\Users\\demousr\\Stripe.ps1'
      // commandId: 'RunPowerShellScript'
      // script: 'C:\\Users\\demousr\\Stripe.ps1'
    }
    // timeoutInSeconds: int
  }
}
