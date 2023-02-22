param(
    [Parameter(Mandatory=$true)]
    [string] $keyVaultName,
    [Parameter(Mandatory=$true)]
    [string] $keyVaultSecretName,
    [Parameter(Mandatory=$true)]
    [string] $tenantId,
    [Parameter(Mandatory=$true)]
    [string] $subId
)
Connect-AzAccount -Identity -Tenant $tenantId -Subscription $subId -Force -ErrorAction Stop
$kvSecretValue = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $keyVaultSecretName -AsPlainText
Disconnect-AzAccount -ErrorAction Stop
return $kvSecretValue



