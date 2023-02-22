param(
    [Parameter(Mandatory=$false)]
    [string]
    $userPassword,
    [Parameter(Mandatory=$false)]
    [string]
    $ApplicationId,
    [Parameter(Mandatory=$false)]
    [string]
    $TenantId,
    [Parameter(Mandatory=$false)]
    [string]
    $rgName,
    [Parameter(Mandatory=$false)]
    [string]
    $vmName,
    [Parameter(Mandatory=$false)]
    [string]
    $dataDiskName
)

function connect([string] $userP, [string] $AppId, [string] $TId)
{
    Write-Output "Connect"
	$SecuredPassword = ConvertTo-SecureString -String $userP -AsPlainText -Force
	$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AppId, $SecuredPassword
	Connect-AzAccount -ServicePrincipal -TenantId $TId -Credential $Credential
}

function disconnect() {
Write-Output "Disconnect"
	Disconnect-AzAccount
}

function attach([string] $vmN, [string] $rgN, [string] $datadisk) {
    Write-Output "Attach"
    $vm = Get-AzVM -Name $vmN -ResourceGroupName $rgN
    $disk = Get-AzDisk -ResourceGroupName $rgName -DiskName $datadisk 
    $vm = Add-AzVMDataDisk -CreateOption Attach -Lun 0 -VM $vm -ManagedDiskId $disk.Id    	
}
    
    
      Write-Output "Main"
	connect $userPassword $ApplicationId $TenantID
	Start-Sleep -Seconds 5
	attach $vmName $rgName $dataDiskName
      Start-Sleep -Seconds 5
	disconnect
