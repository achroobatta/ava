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
     [string]$sqltablename
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
    $Command = $Connection.CreateCommand()
    $Select = "SELECT * From $sqltablename"
    $Command.CommandText = $Select
    $Adapter = New-Object System.Data.SqlClient.SqlDataAdapter $Command
    $dataset = New-Object System.Data.DataSet
    $Adapter.fill($dataset)
    $dataset.Tables
    $Connection.Close();
}
#------------------------Test if the Input parameters is valid---------------------#
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
        Write-Outputt "Invalid script path"
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
        sqlinput($fqdn, $database, $keyvaultscript, $akv, $akvsecretsql, $sqlusername, $sqltablename)
        Write-Output "Successfully retrieve the data in Database"
    }
}
catch
{
    Write-Output "Cannot run SQL Script"
}