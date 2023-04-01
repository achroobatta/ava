param
(
     [Parameter(Mandatory=$true)]
     [String]$rgname,
     [Parameter(Mandatory=$true)]
     [String]$servername,
     [Parameter(Mandatory=$true)]
     [string]$database,
     [Parameter(Mandatory=$true)]
     [string]$keyvaultscript,
     [Parameter(Mandatory=$true)]
     [string]$akv,
     [Parameter(Mandatory=$true)]
     [string]$akvsecretsql,
     [Parameter(Mandatory=$true)]
     [string]$sqlusername,
     [Parameter(Mandatory=$true)]
     [string]$sqltablename,
     [Parameter(Mandatory=$true)]
     [string]$sqldata1,
     [Parameter(Mandatory=$true)]
     [string]$sqldata2,
     [Parameter(Mandatory=$true)]
     [string]$sqldata3
)
Function sqlinput()
{

    Connect-AzAccount -Identity
    try
    {
        $sqlpass = powershell.exe -file ".\$keyvaultscript" $akv $akvsecretsql
    }
    catch
    {
        Write-Output "Unable retrieve password in keyvault"
    }
    try
    {
        $Connection = New-Object System.Data.SQLClient.SQLConnection
        $Connection.ConnectionString = "server='tcp:$fqdn,1433';Initial Catalog='$database'; User ID='$sqlusername';Password='$sqlpass'"
    }
    catch
    {
        Write-Output "Unable to Connect to SQL Database"
    }
    $Connection.Open()
    $Command = New-Object System.Data.SQLClient.SQLCommand
    $Command.Connection = $Connection
    $insertquery="INSERT INTO $sqltablename ([Firstname],[Lastname],[Birthday]) VALUES ('$sqldata1','$sqldata2', '$sqldata3')"
    $Command.CommandText = $insertquery
    $Command.ExecuteNonQuery()
    $Connection.Close();
}
try
{
    if (!(Get-AzResourceGroup -name $rgname -ErrorAction SilentlyContinue))
    {
        Write-Output "No Existing Resource Group"
        return $False;
    }
    elseif (!(Get-AzSqlServer -ResourceGroupName $rgname -ServerName $servername -ErrorAction SilentlyContinue))
    {
        Write-Output "No Existing SQL Server in this $rgname Resource Group"
        return $False;
    }
    elseif (!(Get-AzSqlDatabase -DatabaseName $database -ServerName $servername -ResourceGroupName $rgname))
    {
        Write-Output "No Existing Database in $servername"
        return $False;
    }
    elseif (-not(Test-Path -Path .\$keyvaultscript))
    {
        Write-Output "Invalid script path"
        return $False;
    }
    elseif (!(Get-AzKeyVault -VaultName $akv -ResourceGroupName $rgname))
    {
        Write-Output "No Existing Key Vault in $rgname Resource Group"
        return $False;
    }
    elseif (!(Get-AzKeyVaultSecret -VaultName $akv -Name $akvsecretsql))
    {
        Write-Output "Incorrect Secret Name"
        return $False;
    }
    else
    {
        $getfqdn = Get-AzSqlServer -ResourceGroupName $rgname -ServerName $servername
        $fqdn = $getfqdn.FullyQualifiedDomainName
        sqlinput($fqdn, $database, $keyvaultscript, $akv, $akvsecretsql, $sqlusername, $sqltablename, $sqldata1, $sqldata2, $sqldata3)
        Write-Output "Successfully added the data in Database"
    }
}
catch
{
    Write-Output "Cannot run SQL Script"
}