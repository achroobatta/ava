#UNZIP FILE USING STORED KEY/S IN AKV
param
(
    [Parameter(Mandatory=$true)]
    [String]$akv,
    [Parameter(Mandatory=$true)]
    [string]$akvsecretzip,
    [Parameter(Mandatory=$true)]
    [string]$localzippath,
    [Parameter(Mandatory=$true)]
    [string]$TargetunzipPath
)
Function get-secret()
{
    $secret = Get-AzKeyVaultSecret -VaultName $akv -Name $akvsecretzip -AsPlainText
    & ${env:ProgramFiles}\7-Zip\7z.exe x $localzippath "-o$($TargetunzipPath)" -y -p"$secret"

}

Function get-nosecret()
{
    & ${env:ProgramFiles}\7-Zip\7z.exe x $localzippath "-o$($TargetunzipPath)" -y
}

try
{
    if (-not(Test-Path -Path $localzippath))
    {
        write-output "Source Directory required"
        return $False;
    }
    elseif ($akv -eq $null)
    {
        write-output "Azure Key Vault Name required"
        return $False;
    }
    elseif (-not(Test-Path -Path $TargetunzipPath))
    {
        write-output "Target Folder required"
        return $False;
    }
    elseif ($akvsecretzip -eq $null)
    {
        get-nosecret($akv,$localzippath,$TargetunzipPath)
        write-output "uccessfully Unzip and extract to Disk2"
    }
    else
    {
        get-secret($akv,$akvsecretzip,$localzippath,$TargetunzipPath)
        write-output "Successfully Unzip and extract to Disk2"
    }
}
catch
{
    write-output "Unzip and extract to Disk2 Failed"
    Return = $false
}