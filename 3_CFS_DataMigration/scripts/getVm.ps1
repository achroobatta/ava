Connect-AzAccount -Identity
Set-AzContext -Subscription "a5b0380d-1f49-475e-b6a1-788228c2970b"
$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName
Update-AzVM -ResourceGroupName $rgN -VM $vm