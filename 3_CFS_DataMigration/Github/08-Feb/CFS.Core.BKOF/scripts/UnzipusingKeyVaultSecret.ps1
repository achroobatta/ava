#UNZIP FILE USING STORED KEY/S IN keyVaultNameforSecret
param
(
    [Parameter(Mandatory=$true)]
    [String]$keyVaultNameforSecret,
    [Parameter(Mandatory=$true)]
    [string]$secretName,
    [Parameter(Mandatory=$true)]
    [string]$localzippath,
    [Parameter(Mandatory=$true)]
    [string]$unzipPath
)
function azconnect()
{
    Connect-AzAccount -identity -Force -SkipContextPopulation -ErrorAction Stop
}
Function get-secret()
{
    $secret = Get-AzKeyVaultSecret -VaultName $keyVaultNameforSecret -Name $secretName -AsPlainText
    $cnvrt = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret))

    & ${env:ProgramFiles}\7-Zip\7z.exe x $localzippath "-o$($unzipPath)" -y -p"$cnvrt" | Out-Null
    if((Get-ChildItem -Path $unzipPath))
    {
        return "Successfully Unzip and extract to Disk2"
    }
    else
    {
        return "Unzip and extract to Disk2 Failed"
    }
}

try
{
    get-secret($keyVaultNameforSecret,$secretName,$localzippath,$unzipPath)
}
catch
{
    return "Unzip and extract to Disk2 Failed"
}