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

$attempt = 1
$result = Get-AzContext
if($null -eq $result) {
   $azctx = $false
}
else {
   $azctx = $true
}
while($attempt -le 3 -and -not $azctx)
{
    try
    {
        Connect-AzAccount -Identity -Tenant $tenantId -Subscription $subId -Force
        $result = Get-AzContext
        if($null -ne $result) {
        $azctx = $true
        }
    }
    catch
    {
        Start-Sleep -Seconds 60
        if($attempt -gt 2)
        {
            Start-Sleep -Seconds 60
        }
    }
    $attempt += 1
}

if ($azctx -eq  $true) {
    $kvSecretValue = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $keyVaultSecretName -AsPlainText
    Disconnect-AzAccount
    return $kvSecretValue
}
else {
    $kvSecretValue = "Error in getting secret value"
    return $kvSecretValue
}




