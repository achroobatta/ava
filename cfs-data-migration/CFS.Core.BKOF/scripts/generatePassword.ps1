#Generate Password to be use to 7zip
param
(
    [Parameter(Mandatory=$true)]
    [String]$keyVaultNameforSecret,
    [Parameter(Mandatory=$true)]
    [String]$sftpUsername,
    [Parameter(Mandatory=$true)]
    [string]$subId,
    [Parameter(Mandatory=$true)]
    [string]$subTenantId
)

function azconnect()
{
    param ($subId, $subTenantId)

    $attempt = 1
    $result = Get-AzContext
    if($null -eq $result)
    {
        $azctx = $false
    }
    else
    {
        $azctx = $true
    }
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Connecting to Azure") >> $logFilePath
    while($attempt -le 3 -and -not $azctx)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Attempt $attempt") >> $logFilePath
        try
        {
            Connect-AzAccount -Identity -Tenant $subTenantId -Subscription $subId -Force
            $result = Get-AzContext
            if($null -ne $result)
            {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Connection with azure established") >> $logFilePath
                break
            }
        }
        catch
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed to established connection") >> $logFilePath
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Sleep for 60 Seconds") >> $logFilePath
            Start-Sleep -Seconds 60
            if($attempt -gt 2)
            {
                Start-Sleep -Seconds 60
            }
        }
        $attempt += 1
    }
    $azresult = Get-AzContext
    if($null -eq $azresult)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to established connection") >> $logFilePath
        break
    }
}
Function generate_password()
{
    param ($keyVaultNameforSecret, $sftpUsername)

    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Generating password to be used for 7zip") >> $logFilePath

    Add-Type -AssemblyName 'System.Web'
    $pass = [System.Web.Security.Membership]::GeneratePassword((Get-Random -Minimum 20 -Maximum 32),3)
    if ($null -ne $pass)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully generated password") >> $logFilePath
    }
    $string = New-Object System.Net.NetworkCredential("","$pass")
    $sec = $string.SecurePassword
    $kvName = $sftpUsername + "7ZipPassword"

    try
    {
        Set-AzKeyVaultSecret -Vaultname $keyVaultNameforSecret -Name $kvName -SecretValue $sec -ErrorAction Stop | Out-Null
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully upload password to key vault") >> $logFilePath
    }

    catch
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to upload password to key vault") >> $logFilePath
    }
}

$logFilePath = "$PSScriptRoot\logging_generatePassword.txt"

try
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Start") >> $logFilePath
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Executing generate_password function...") >> $logFilePath

    $azctx = Get-AzContext
    if($null -eq $azctx)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"VM is not connected in Azure") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Reconnecting to azure...") >> $logFilePath
        azconnect -subId $subId -subTenantId $subTenantId | Out-Null
    }

    generate_password -keyVaultNameforSecret $keyVaultNameforSecret -sftpUsername $sftpUsername
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
}
catch
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed to Generate Password") >> $logFilePath
    Write-Output "Failed to Generate Password"
}