param(
    [Parameter(Mandatory=$true)]
    [String]$sshKeyName,
    [Parameter(Mandatory=$true)]
    [String]$rgName,
    [Parameter(Mandatory=$true)]
    [String]$keyVaultName,
    [Parameter(Mandatory=$true)]
    [String]$depStoRg,
    [Parameter(Mandatory=$true)]
    [String]$depStorageAcctName,
    [Parameter(Mandatory=$true)]
    [String]$depStoContainerName,
    [Parameter(Mandatory=$true)]
    [string] $clientId,
    [Parameter(Mandatory=$true)]
    [string] $clientSecret,
    [Parameter(Mandatory=$true)]
    [string] $tenantId,
    [Parameter(Mandatory=$true)]
    [string] $senderEmailAddress,
    [Parameter(Mandatory=$true)]
    [string] $receiverEmailAddress,
    [Parameter(Mandatory=$true)]
    [string] $taskNumber
)

$logFilePath = "$env:USERPROFILE\logging_CreateAndUploadSsh.txt"
if (Test-Path -Path $logFilePath){
    Remove-Item $logFilePath
    }

try {
    Write-Output 'Connecting to Azure' > $logFilePath
    $acnt = Connect-AzAccount -identity -Verbose -Force -SkipContextPopulation -ErrorAction Stop
    if ($null -ne $acnt){
        Write-Output $acnt >> $logFilePath
    }
}
catch{
    Write-Output 'Unable to connect to Azure' >> $logFilePath
    return "Unable to connect to Azure"
    Break
}

$sshdir = "$env:USERPROFILE\.ssh"
Write-Output $sshdir
$sshfilePath = "$sshdir\*"
    if (Test-Path -Path $sshfilePath){
        Remove-Item $sshfilePath
    }

$outFileFolder = "$env:USERPROFILE\temp\ssh"
$outFileName = "$sshKeyName.pem"
$outfile = "$outFileFolder\$outFileName"
$outFilePath = "$outFileFolder\*"
    if (Test-Path -Path $outFileFolder){
        Remove-Item $outFilePath
    }
    else {
        New-Item -ItemType Directory -Path $outFileFolder
    }

Write-Output 'Start' >> $logFilePath
Write-Output 'Generating New SSH Key' >> $logFilePath
try {
    $sshresult = New-AzSshKey -ResourceGroupName $rgName -Name $sshKeyName
    if ($null -ne $sshresult){
        Write-Output 'Successfully created new SSH Key' >> $logFilePath
        Write-Output '***********************************************' >> $logFilePath
    }
}
catch{
    Write-Output 'Unable to create new SSH Key' >> $logFilePath
    Write-Output '***********************************************' >> $logFilePath
    return "Unable to create new SSH Key"
    Break
}

    if ($null -ne $sshresult)
    {
        ###remove public key from local###
        Write-Output 'Removing Public Key File on local' >> $logFilePath
        Write-Output 'Before' >> $logFilePath

            Get-ChildItem $sshdir >> $logFilePath
            Remove-Item "$sshdir\*.pub"

        Write-Output 'After' >> $logFilePath

        Get-ChildItem $sshdir >> $logFilePath
        Write-Output '***********************************************' >> $logFilePath

        Write-Output $rgName >> $logFilePath
        Write-Output $sshKeyName >> $logFilePath

        ###copy and rename private key on local###
        Write-Output 'Copying private key local' >> $logFilePath
        Copy-Item -Path $sshfilePath -Destination $outfile

        ###store private key to dependency storage###
            try{
                $storageAccountkey = (Get-AzStorageAccountKey -ResourceGroupName $depStoRg -Name $depStorageAcctName | Where-Object {$_.KeyName -eq "key1"}).Value
                $ctx = New-AzStorageContext -StorageAccountName $depStorageAcctName -StorageAccountKey $storageAccountkey
                $blob = Set-AzStorageBlobContent -File $outfile -Container $depStoContainerName -Blob $outFileName -Context $ctx -Force
                    if ($null -ne $blob) {
                        Write-Output "Successfully stored private key to storage account" >> $logFilePath
                        Write-Output '***********************************************' >> $logFilePath
                        }
            }
            catch {
                Write-Output "Unable to store private key to storage account" >> $logFilePath
                Write-Output '***********************************************' >> $logFilePath
            }

        ###send private key through email###
        $emailSubject = "SSH Private Key (PEM File) for taskNumber $taskNumber. Please Save it."
        $emailContent= "Please save attachment in secured folder. You will receive password and username in seperate emails."
        $cmd = "$env:USERPROFILE\scripts\SendEmail.ps1"

            try{
                Write-Output 'Sending pem file as email attachment ' >> $logFilePath
                & "$cmd" -file $outfile -fileName $outFileName -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId -senderEmailAddress $senderEmailAddress -receiverEmailAddress $receiverEmailAddress -emailSubject $emailSubject -emailContent $emailContent #-logFilePath $logFilePath
            }
            catch{
                Write-Output 'Unable to send pem file through email' >> $logFilePath
                Write-Output '***********************************************' >> $logFilePath
            }

                    Write-Output '************************************************'
                    Write-Output $cmd
                    Write-Output $emailSubject
                    Write-Output $emailContent
                    Write-Output $sshKeyName
                    Write-Output $rgName
                    Write-Output $keyVaultName
                    Write-Output $depStoRg
                    Write-Output $depStorageAcctName
                    Write-Output $depStoContainerName
                    Write-Output $clientId
                    Write-Output $clientSecret
                    Write-Output $tenantId
                    Write-Output $senderEmailAddress
                    Write-Output $receiverEmailAddress
                    Write-Output $taskNumber
                    Write-Output '************************************************'

        ###store private key to key vault###
        try{
            $privateKey=Get-Content -Path "$sshdir\*" -Encoding "utf8"

            $str = ""
                    for($i=0; $i -lt $privateKey.Count; $i++)
                    {
                            $str = $str+$privateKey[$i]+"`n"
                    }

                Write-Output '****'
                Write-Output $str
                Write-Output '$$$$$$$$$$'

            Write-Output $keyVaultName >> $logFilePath
            Write-Output $sshKeyName >> $logFilePath

            Write-Output "Writing to keyvault now"

            $string = New-Object System.Net.NetworkCredential("",$str)
            $secretvalue = $string.SecurePassword
            $kvscrt = Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $sshKeyName -SecretValue $secretvalue
                if ($null -ne $kvscrt) {
                    Write-Output "Successfully stored private key to Key Vault" >> $logFilePath
                    Write-Output '***********************************************' >> $logFilePath
                    }
                }

        catch {
            Write-Output "Unable to store private key to Key Vault" >> $logFilePath
            Write-Output '***********************************************' >> $logFilePath
        }
    }

Get-ChildItem $sshdir >> $logFilePath
Write-Output '***********************************************' >> $logFilePath
Write-Output 'End' >> $logFilePath

Disconnect-AzAccount -ErrorAction Stop