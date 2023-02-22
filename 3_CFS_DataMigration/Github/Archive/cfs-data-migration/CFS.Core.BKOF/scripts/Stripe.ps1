param(
    [Parameter(Mandatory=$true)]
    [int32]
    $sourceCount
)

function create_volume() {
	param
  (
    [string]$pool,
    [string]$drive,
    [array]$disk
  )
    write-output 'Volume Create'
    New-StoragePool -FriendlyName $pool -StorageSubsystemFriendlyName (Get-StorageSubsystem -FriendlyName *Windows*).FriendlyName -PhysicalDisks $disk | New-VirtualDisk -FriendlyName 'striped' -NumberOfColumns $disk.Count -ResiliencySettingName 'Simple' -UseMaximumSize | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -DriveLetter $drive -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Striped Volume' -Confirm:$false -UseLargeFRS
    write-output 'Volume create end'
}

write-output 'Main'
[array]$PhysicalDisks = Get-StorageSubSystem -FriendlyName 'Windows*' | Get-PhysicalDisk -CanPool $True
if ($null -eq $PhysicalDisks) {
    Write-Error "Nothing is available to pool"
}
else
{
	[array]$source=@()
	[array]$target=@()
    $count = 0
	foreach ($disks in $PhysicalDisks) {
		if ($count -lt $sourcecount) {
			$source += $disks
			$count = $count + 1
		  }
		  else
		  {
			 $target += $disks
		  }
	}

	$pool = 'SourcePool'
	$drive = 'S'
	$disk = $source
	create_volume -Name $pool $drive $disk
    $SPath = $drive+":\FromStorageAccount"
    New-Item -itemtype "Directory" -Path $SPath
	$pool = 'TargetPool'
	$drive = 'T'
	$disk = $target
	create_volume -Name $pool $drive $disk
    $TPath1 = $drive+":\UnzipFile"
    $TPath2 = $drive+":\EncryptedZipFile"
    New-Item -itemtype "Directory" -Path $TPath1
    New-Item -itemtype "Directory" -Path $TPath2
}
write-output 'End'