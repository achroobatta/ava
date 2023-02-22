param(
    [Parameter(Mandatory=$true)]
    [string]
    $fileSize
)
function create_volume() {
    Write-Output 'Volume Creation Starts' >> $logFilePath
    New-StoragePool -FriendlyName $pool -StorageSubsystemFriendlyName (Get-StorageSubsystem -FriendlyName *Windows*).FriendlyName -PhysicalDisks $disk | New-VirtualDisk -FriendlyName 'striped' -NumberOfColumns $disk.Count -ResiliencySettingName 'Simple' -UseMaximumSize | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -DriveLetter $drive -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Striped Volume' -Confirm:$false -UseLargeFRS
    Write-Output 'Volume Creation Ended' >> $logFilePath
}

$logFilePath = "$env:USERPROFILE\logging_Stripe.txt"

if (Test-Path -Path $logFilePath) {
    Remove-Item $logFilePath
}
# Main Script
Write-output 'Main' > $logFilePath
Write-Output '******************************************' >> $logFilePath
[array]$PhysicalDisks = Get-StorageSubSystem -FriendlyName 'Windows*' | Get-PhysicalDisk -CanPool $True

if ($null -eq $PhysicalDisks) {
    Write-Output "Nothing is available to pool" >> $logFilePath
}
else
{
    Write-Output "Physical disk count: "  >> $logFilePath
	Write-Output $PhysicalDisks >> $logFilePath
	Write-Output "FileSize: $fileSize" >> $logFilePath
	$fileSizeArr = $fileSize -split " "
    Write-Output "FileSizeArr: $fileSizeArr" >> $logFilePath
	$fileSizeInt = [int]($fileSizeArr[0])
    Write-Output "FileSizeAInt: $fileSizeInt" >> $logFilePath

	$fileSizeType = [string]$fileSizeArr[1]
	Write-Output "FileSizeAType: $fileSizeType" >> $logFilePath
	[array]$source=@()
	[array]$target=@()
	if  ($fileSizeType -eq "TB") {
		Write-Output "TB processing"  >> $logFilePath
 		$decimal = $fileSizeInt/16
		if ( ($fileSizeInt % 16) -ne 0) {
	  		$sourcecount = [int]$decimal + 1
		}
		else {
	  		$sourcecount = [int]$decimal
		}
	} else {
		Write-Output "Other Size processing"  >> $logFilePath
		$sourcecount = 1
	}

	Write-Output "Source Count: $sourcecount"  >> $logFilePath
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

	Write-Output "Source : " >> $logFilePath
	Write-Output $source >> $logFilePath
	Write-Output '************************************' >> $logFilePath
	Write-Output 'Target : ' >> $logFilePath
	Write-Output $target >> $logFilePath
	Write-Output '************************************' >> $logFilePath

	[array]$disk=@()
	$pool = 'SourcePool'
	$drive = 'S'
	$disk = $source

	create_volume -Name $pool $drive $disk
    $SPath = $drive+":\FromStorageAccount"
    New-Item -itemtype "Directory" -Path $SPath
	Write-Output "Directory Created in Source" >> $logFilePath

	[array]$disk=@()
	$pool = 'TargetPool'
	$drive = 'T'
	$disk = $target

	create_volume -Name $pool $drive $disk
    $TPath1 = $drive+":\UnzipFile"
    $TPath2 = $drive+":\EncryptedZipFile"
    New-Item -itemtype "Directory" -Path $TPath1
    New-Item -itemtype "Directory" -Path $TPath2
	Write-Output "Directory Created in Destination" >> $logFilePath
}
Write-Output '******************************************' >> $logFilePath
write-output 'End' >> $logFilePath