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
   echo 'Connect Start' >> 'C:\Users\demousr\xyz.txt'
   Connect-AzAccount -Identity
   Set-AzContext -Subscription $subId
   echo 'Connect Complete' >> 'C:\Users\demousr\xyz.txt'
}

function disconnect() 
{
      echo 'Disconnect Start' >> 'C:\Users\demousr\xyz.txt'
      Disconnect-AzAccount
      echo 'Disconnect Complete' >> 'C:\Users\demousr\xyz.txt'
}

function create_attach([string] $vmN, [string] $rgN, [string] $loc, [int] $dSize, [string] $skuType, [int] $dCount)
{
    echo 'create_attach Start' >> 'C:\Users\demousr\xyz.txt'
    $vm = Get-AzVM -Name $vmN -ResourceGroupName $rgN
    $diskConfig = New-AzDiskConfig -Location $loc -CreateOption Empty  -DiskSizeGB $dSize -SkuName $skuType

    for($i=1; $i -le $dCount; $i++)
	{
       $name = 'demo-disk{0:00}' -f $i
       $lun = $i - 1
       $dataDisk = New-AzDisk -ResourceGroupName $rgN -DiskName $name -Disk $diskConfig
       $vm = Add-AzVMDataDisk -VM $vm -Name $name -CreateOption Attach -ManagedDiskId $dataDisk.Id -Lun $lun
      # echo 'update start' >> 'C:\Users\demousr\xyz.txt'
      # Update-AzVM -ResourceGroupName $rgN -VM $vm -NoWait
      # echo 'update Complete' >> 'C:\Users\demousr\xyz.txt'
    }

    echo 'create_attach Complete' >> 'C:\Users\demousr\xyz.txt'
}

function update([string] $vmN, [string] $rgN)
{
    echo 'update Start' >> 'C:\Users\demousr\xyz.txt'
    $vm = Get-AzVM -Name $vmN -ResourceGroupName $rgN
    Update-AzVM -ResourceGroupName $rgN -VM $vm
    # az login --identity
    # az vm update -n $vmN -g $rgN
    #az logout 
    echo 'update Complete' >> 'C:\Users\demousr\xyz.txt'
}

function create_volume([string] $storageFriendlyName, [string] $driveLetter)
{
    echo 'create_volume create' >> 'C:\Users\demousr\xyz.txt'
    [array]$PhysicalDisks = Get-StorageSubSystem -FriendlyName 'Windows*' | Get-PhysicalDisk -CanPool $True
    $diskCount = $PhysicalDisks.Count
    New-StoragePool -FriendlyName $storageFriendlyName -StorageSubsystemFriendlyName (Get-StorageSubsystem -FriendlyName *Windows*).FriendlyName -PhysicalDisks $PhysicalDisks | New-VirtualDisk -FriendlyName 'striped' -NumberOfColumns $diskCount -ResiliencySettingName 'Simple' -UseMaximumSize | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -DriveLetter $driveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Striped Volume' -Confirm:$false -UseLargeFRS
    echo 'create_volume end'  >> 'C:\Users\demousr\xyz.txt'
}

echo 'main' >> 'C:\Users\demousr\xyz.txt'
connect $subscriptionId
create_attach $vmName $rgName $location $diskSize $sku $diskCount
#update $vmName $rgName
create_volume 'SourcePool' 'S'
disconnect