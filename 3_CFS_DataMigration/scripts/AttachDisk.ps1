param(
    [Parameter(Mandatory=$false)]
    [string]
    $vmName,
    [Parameter(Mandatory=$false)]
    [string]
    $rgName,
    [Parameter(Mandatory=$false)]
    [string]
    $location,
    [Parameter(Mandatory=$false)]
    [int]
    $diskSize,
    [Parameter(Mandatory=$false)]
    [string]
    $sku,
    [Parameter(Mandatory=$false)]
    [int]
    $diskCount,
    [Parameter(Mandatory=$false)]
    [string]
    $subscriptionId
)

function connect([string] $subId)
{
   echo "Connect Start"  
   Connect-AzAccount -Identity
   Set-AzContext -Subscription $subId
   echo "Connect Complete"  
}

function disconnect() 
{
      echo "Disconnect Start"  
 	Disconnect-AzAccount
	echo "Disconnect Complete" 
}

function create_attach([string] $vmN, [string] $rgN, [string] $loc, [int] $dSize, [string] $skuType, [int] $dCount) 
{
	echo "create_attach Start"  
	$vm = Get-AzVM -Name $vmN -ResourceGroupName $rgN
	$diskConfig = New-AzDiskConfig -Location $loc -CreateOption Empty  -DiskSizeGB $dSize -SkuName $skuType

	for($i=1; $i -le $dCount; $i++) {	
    		$name = "demo-disk{0:00}" -f $i
    		$lun = $i - 1
		$dataDisk = New-AzDisk -ResourceGroupName $rgN -DiskName $name -Disk $diskConfig	
    		$vm = Add-AzVMDataDisk -VM $vm -Name $name -CreateOption Attach -ManagedDiskId $dataDisk.Id -Lun $lun 
	}

	echo "create_attach Complete"   
}
    
function update([string] $vmN, [string] $rgN) 
{
	echo "update Start" 
	$vm = Get-AzVM -Name $vmN -ResourceGroupName $rgN
	Update-AzVM -ResourceGroupName $rgN -VM $vm
	echo "update Complete"  
}

function create_volume([string] $storageFriendlyName, [string] $driveLetter) 
{
	echo "create_volume create"  
	[array]$PhysicalDisks = Get-StorageSubSystem -FriendlyName "Windows Storage*" | Get-PhysicalDisk -CanPool $True
	$diskCount = $PhysicalDisks.Count
	New-StoragePool -FriendlyName $storageFriendlyName  -StorageSubsystemFriendlyName (Get-StorageSubsystem -FriendlyName *Windows*).FriendlyName  -PhysicalDisks $PhysicalDisks | New-VirtualDisk -FriendlyName "striped" -NumberOfColumns $diskCount -ResiliencySettingName simple –UseMaximumSize | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -DriveLetter $driveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Striped Volume" -Confirm:$false -UseLargeFRS
	echo "create_volume end"  
}
    	
echo "main"  
connect $subscriptionId	
create_attach $vmName $rgName $location $diskSize $sku $diskCount
update $vmName $rgName
create_volume "SourcePool" "S"	
disconnect
echo "end"  

	
