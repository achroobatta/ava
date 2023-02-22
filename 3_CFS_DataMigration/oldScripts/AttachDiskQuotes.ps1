param(
    [Parameter(Mandatory=$false)]
    [string]
    $userPassword = "tHN8Q~hg56ti4ZaeBQPYocW_l1x3c0L.RVbA0dtP",
    [Parameter(Mandatory=$false)]
    [string]
    $ApplicationId = "45932406-113d-4785-9aef-99870af29f4a",
    [Parameter(Mandatory=$false)]
    [string]
    $TenantId = "259d5f85-f632-42ec-bcc5-b1b2072d0504",
    [Parameter(Mandatory=$false)]
    [string]
    $rgName = "demorg",
    [Parameter(Mandatory=$false)]
    [string]
    $vmName = "demovm",
    [Parameter(Mandatory=$false)]
    [string]
    $dataDiskName = "data2"
)

function connect([string] $uPassword, [string] $AppId, [string] $TId)
{
      $SecuredPassword = ConvertTo-SecureString -String $uPassword -AsPlainText -Force
	$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AppId, $SecuredPassword
	Connect-AzAccount -ServicePrincipal -TenantId $TId -Credential $Credential
}


function attach([string] $vmN, [string] $rgN, [string] $diskN) {    
	$vm = Get-AzVM -Name $vmN -ResourceGroupName $rgN
	$disk = Get-AzDisk -ResourceGroupName $rgN -DiskName $diskN
	$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 1 -VM $vm -ManagedDiskId $disk.Id
	Update-AzVM -VM $vm -ResourceGroupName $rgN -NoWait
}
    
      Write-Output "Main"
	connect $userPassword $ApplicationId $TenantID
	attach $vmName $rgName $dataDiskName
