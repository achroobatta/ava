param
(
    [Parameter(Mandatory=$true)]
    [string]$keyVaultNameforSecret,
    [Parameter(Mandatory=$true)]
    [string]$subId,
    [Parameter(Mandatory=$true)]
    [string]$subTenantId
)

$logFilePath = "$PSScriptRoot\logging_Install7zip.txt"
$arrayResult = @()

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

try
{
    #Install 7zip
    try
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Start") >> $logFilePath

        $azctx = Get-AzContext
        if($null -eq $azctx)
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"VM is not connected in Azure") >> $logFilePath
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Reconnecting to azure...") >> $logFilePath
            azconnect -subId $subId -subTenantId $subTenantId | Out-Null
        }

        #Searching 7zip file
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Checking 7-zip on local") >> $logFilePath
        $srch7zip = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*7-Zip*" }
        if ($null -ne $srch7zip)
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"7zip is already installed") >> $logFilePath
            $arrayResult += "7zip is already installed"
        }
        else
        {
            #install 7zip
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Installing 7zip") >> $logFilePath

            $get7zip = Get-ChildItem -Path "$env:USERPROFILE\softwares\7zip"
            $get7name = $get7zip.BaseName
            $get7exts = $get7zip.Extension
            $7Name = $get7name + $get7exts
            Copy-Item -Path "$env:USERPROFILE\softwares\7zip\$7Name" -Destination "C:\Temp"

            try
            {
                Start-Process -Wait -FilePath "$env:HOMEDRIVE\Temp\$7Name" -ArgumentList "/S" -PassThru | Out-Null
                $arrayResult += "Successfully installed 7zip"
            }
            catch
            {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Error encountered while installing 7zip") >> $logFilePath
            }

            Remove-Item -Path "$env:HOMEDRIVE\Temp\$7Name"
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully installed 7zip") >> $logFilePath
        }

        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Checking Treesize on local") >> $logFilePath

        #Searching Treesize App
        $srchtree = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Treesize*" }
        if ($null -ne $srchtree)
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Treesize is already installed") >> $logFilePath
            $arrayResult += "Treesize is already installed"
        }
        else
        {
            #install Treesize
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Installing TreeSize") >> $logFilePath

            #License Secret Value
            $licenseValue = Get-AzKeyVaultSecret -vaultName $keyVaultNameforSecret -name LicenseSecretKey -AsPlainText
            if ($null -eq $licenseValue)
            {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to retrieve License key from key vault") >> $logFilePath
                return "Unable to retrieve License key from key vault"
            }

            $getTreesize = Get-ChildItem -Path "$env:USERPROFILE\softwares\TreeSize"
            $getTreename = $getTreesize.BaseName
            $getTreeexts = $getTreesize.Extension
            $TreeName = $getTreename + $getTreeexts
            Copy-Item -Path "$env:USERPROFILE\softwares\TreeSize\$TreeName" -Destination "$env:HOMEDRIVE\Temp"

            try
            {
                Start-Process -Wait -FilePath "$env:HOMEDRIVE\Temp\$TreeName" -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES /PASSWORD=$licenseValue" -PassThru | Out-Null
                $arrayResult += "Successfully installed Treesize"
            }
            catch
            {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Error encountered while installing treesize") >> $logFilePath
            }

            Remove-Item -Path "$env:HOMEDRIVE\Temp\$TreeName"
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully installed Treesize") >> $logFilePath
        }

        #result
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
        $installresult = $arrayResult -join ","
        return $installresult
    }
    catch
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to Get Installer: $_") >> $logFilePath
        Write-Output "Unable to Get Installer: $_"
    }
}
catch
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Please check if 7zip and Treesize installer is in correct the Storage Account") >> $logFilePath
    Write-Output "Please check if 7zip and Treesize installer is in correct the Storage Account"
}