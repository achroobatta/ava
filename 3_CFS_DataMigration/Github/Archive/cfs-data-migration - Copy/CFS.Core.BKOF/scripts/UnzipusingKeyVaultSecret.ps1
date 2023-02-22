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
  Expand-7Zip -ArchiveFileName $localzippath -TargetPath $TargetunzipPath -Password $secret
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
    elseif ($akvsecretzip -eq $null)
    {
        write-output "Secret Name required"
        return $False;
    }
    elseif (-not(Test-Path -Path $TargetunzipPath))
    {
        write-output "Target Folder required"
        return $False;
    }
    else
    {
        get-secret($akv,$akvsecretzip,$localzippath,$TargetunzipPath)
        write-output "Successfully Unzipped the file"
    }
}
catch
{
    write-output "Cannot copy File"
    Return = $false
}