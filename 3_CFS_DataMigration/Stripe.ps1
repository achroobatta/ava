function create_volume([string] $storageFriendlyName, [string] $driveLetter, [array] $disk) {
    write-output 'Volume Create'
    New-StoragePool -FriendlyName $storageFriendlyName -StorageSubsystemFriendlyName (Get-StorageSubsystem -FriendlyName *Windows*).FriendlyName -PhysicalDisks $disk | New-VirtualDisk -FriendlyName 'striped' -NumberOfColumns $disk.Count -ResiliencySettingName 'Simple' -UseMaximumSize | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -DriveLetter $driveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Striped Volume' -Confirm:$false -UseLargeFRS
   write-output 'Volume create end'
}


write-output 'Main'
[array]$PhysicalDisks = Get-StorageSubSystem -FriendlyName 'Windows*' | Get-PhysicalDisk -CanPool $True 
if ($PhysicalDisks -eq $null) {
    Write-Error "Nothing is available to pool"
}
else
{
	[array]$source=@()
	[array]$target=@()
	foreach ($disks in  $PhysicalDisks) {
    	if($disks.DeviceId%2 -eq 0) {
        $source += $disks
    		} 
    	else {
        $target += $disks
      	}
	}

	create_volume 'SourcePool' 'S' $source
	create_volume 'TargetPool' 'T' $target
}

write-output 'End'