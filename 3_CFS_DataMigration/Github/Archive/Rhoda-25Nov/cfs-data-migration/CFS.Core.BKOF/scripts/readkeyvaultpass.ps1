param
(
     [Parameter(Mandatory=$true)]
     [string]$akv,
     [Parameter(Mandatory=$true)]
     [string]$akvsec
)
Function get-secret()
{
    try
    {
        $sec = Get-AzKeyVaultSecret -VaultName $akv -Name $akvsec -AsPlainText
        return $sec
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
    elseif ($akvsec -eq $null)
    {
        Write-Output "Invalid Secret Name"
        return $false
    }
    else
    {
        $pass = get-secret ($akv,$akvsec)
        Write-Output $pass
    }
}
catch
{
    Write-Output "Unable to fetch Secret from Key Vault"
}