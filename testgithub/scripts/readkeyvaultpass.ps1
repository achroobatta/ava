param
(
     [Parameter(Mandatory=$true)]
     [string]$akv,
     [Parameter(Mandatory=$true)]
     [string]$akvsecret
)
Function get-secret()
{
    try
    {
        $secret = Get-AzKeyVaultSecret -VaultName $akv -Name $akvsecret -AsPlainText
        return $secret
    }
    catch
    {
        Write-Output "Invalid Input"
    }
}
try{
    if ($akv -eq $null)
    {
        Write-Output "Invalid Key Vault Name"
        return $false;
    }
    elseif ($akvsecret -eq $null)
    {
        Write-Output "Invalid Secret Name"
        return $false
    }
    else
    {
        $password = get-secret ($akv,$akvsecret)
        Write-Output $password
    }
}
catch
{
    Write-Output "Unable to fetch Secret from Key Vault"
}