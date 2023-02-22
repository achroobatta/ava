#Zipped File using 7zip - Main Script
#create by: Joshua Ira San Ramon
param
(
    [Parameter(Mandatory=$false)]
    [String]$keyVaultNameforSecret,
    [Parameter(Mandatory=$false)]
    [String]$localTargetDirectory,
    [Parameter(Mandatory=$false)]
    [String]$unzipPath,
    [Parameter(Mandatory=$false)]
    [String]$zipPath,
    [Parameter(Mandatory=$false)]
    [String]$sftpUsername,
    [Parameter(Mandatory=$false)]
    [string]$subId,
    [Parameter(Mandatory=$false)]
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


Function get-secret()
{
    $azctx = Get-AzContext
    if($null -eq $azctx)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"VM is not connected in Azure") >> $logFilePath
        break
    }
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Generating Password") >> $logFilePath

    try
    {
        powershell.exe -file "$PSScriptRoot\generatePassword.ps1" $keyVaultNameforSecret $sftpUsername
    }
    catch
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Error encountered generating password") >> $logFilePath
    }

    try
    {
        $namepass = $sftpUsername + "secret"
        $secret = Get-AzKeyVaultSecret -vaultName $keyVaultNameforSecret -name $namepass
        $Get_My_Scret = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
        $Enpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Get_My_Scret)
        if ($null -eq $Enpassword)
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to get password in key vault") >> $logFilePath
        }
    }
    catch
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to retrieve password") >> $logFilePath
        write-output "Unable to retrieve password"
    }
    try
    {
        #Zipping the files
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Zipping files") >> $logFilePath

        #source folder
        $originFolder = (Get-Item -Path $folder).FullName
        $orgChildFolder = (Get-ChildItem -Path $folder).FullName

        #zip folder
        $arcPath = $orgChildFolder.Replace("$localTargetDirectory","$zipPath")

        #unzip folder
        $sreplace = $originFolder.Replace("$localTargetDirectory","$unzipPath")
        $sreformat = $sreplace.Replace(" ","_")
        $srcPath = (Get-ChildItem -Path $sreformat).FullName

        $zipSize = (Get-ChildItem -Path $orgChildFolder -Exclude "*Report*" -File -Recurse | Select-Object -First 1 | Measure-Object -Property Length -sum).Sum
        try
        {
            #Path get data and report folder
            For($i=0;$i -lt $orgChildFolder.count;$i++)
            {
                $sPath = $srcPath[$i]
                $aPath = $arcPath[$i]
                Compress-7Zip -Path $sPath -ArchiveFileName "$aPath\EncryptedFile.7z" -CompressionLevel None -VolumeSize $zipSize -Format SevenZip -Password $Enpassword -EncryptFilenames -ErrorAction Stop
            }

            if((Get-ChildItem -Path $zipPath))
            {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully Zip/Encrypt file and Copy from Disk2 to Storage location") >> $logFilePath
                $fname = (Get-Item $folder).BaseName
                return "Successfully Archive Data and Report for $fname"
            }
            else
            {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed Copy from Disk2 to Storage location") >> $logFilePath
                $fname = (Get-Item $folder).BaseName
                return "Failed Archive Data and Report for $fname"
            }
        }
        catch
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Error encountered while Zipping files") >> $logFilePath
            break
        }
    }
    catch
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to Compress the files") >> $logFilePath
        return "Unable to Compress the files"
    }
}

$logFilePath = "$PSScriptRoot\logging_zipFileUsing7z.txt"

try
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Start") >> $logFilePath
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Executing get-secret function...") >> $logFilePath

    $azctx = Get-AzContext
    if($null -eq $azctx)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"VM is not connected in Azure") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Reconnecting to azure...") >> $logFilePath
        azconnect -subId $subId -subTenantId $subTenantId | Out-Null
    }

    $folders = (Get-ChildItem $localTargetDirectory).FullName
    foreach($folder in $folders)
    {
        get-secret ($keyVaultNameforSecret, $sftpUsername, $unzipPath, $zipPath, $folder, $localTargetDirectory)
    }
}
catch
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed to Zip/Encrypt file and Copy from Disk2 to Storage location") >> $logFilePath
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
    write-output "Failed to Zip/Encrypt file and Copy from Disk2 to Storage location"
}