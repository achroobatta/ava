param(
    [Parameter(Mandatory=$false)]
    [string]
    $userPassword = 'tHN8Q~hg56ti4ZaeBQPYocW_l1x3c0L.RVbA0dtP',
    [Parameter(Mandatory=$false)]
    [string]
    $ApplicationId = '45932406-113d-4785-9aef-99870af29f4a',
    [Parameter(Mandatory=$false)]
    [string]
    $TenantId = '259d5f85-f632-42ec-bcc5-b1b2072d0504',
    [Parameter(Mandatory=$false)]
    [string]
    $rgName = 'demorg',
    [Parameter(Mandatory=$false)]
    [string]
    $vmName = 'demovm',
    [Parameter(Mandatory=$false)]
    [string[]]
    $dataDiskName = @('data1','data2')
)

function connect([string] $userPassword, [string] $ApplicationId, [string] $TenantId)
{
    Write-Output "Connect"
	$SecuredPassword = ConvertTo-SecureString -String $userPassword -AsPlainText -Force
	$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecuredPassword
	Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential
}

function disconnect() {
Write-Output "Disconnect"
	Disconnect-AzAccount
}

function attach([string] $vmName, [string] $rgName) {
    Write-Output "Attach"
	$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName

	for ($i=0; $i -lt $dataDiskName.Length; $i++) {
		$disk = Get-AzDisk -ResourceGroupName $rgName -DiskName $dataDiskName[$i]
		$vm = Add-AzVMDataDisk -CreateOption Attach -Lun $i -VM $vm -ManagedDiskId $disk.Id
	}

 	Update-AzVM -VM $vm -ResourceGroupName $rgName
}
    
    clear
    Write-Output "Main"
	connect $userPassword $ApplicationId $TenantID
	attach $vmName $rgName
	disconnect
