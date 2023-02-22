param(
    [Parameter(Mandatory=$True)]
    [string] $env,
    [Parameter(Mandatory=$True)]
    [string] $appName,
    [Parameter(Mandatory=$False)]
    [string] $keyVaultName
)

function connect_azure()
{
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
    while($attempt -le 3 -and -not $azctx)
    {
        if($attempt -gt 2)
        {
            Start-Sleep -Seconds 15
        }
        Connect-AzAccount -Identity
        $result = Get-AzContext
        if($null -eq $result)
        {
            $azctx = $false
            Start-Sleep -Seconds 15
        }
        else
        {
            $azctx = $true
        }
        $attempt+=1
    }

    return $azctx
}

try
{
   $logDirectory = 'C:/temp/SSHKey-Logs'
   Write-Information -MessageData "Checking if $logDirectory is existing" -InformationAction Continue

   if(Test-Path -LiteralPath $logDirectory)
   {
    Write-Information -MessageData "$logDirectory is existing" -InformationAction Continue
   }
   else
   {
    Write-Information -MessageData "Creating new directory $logDirectory" -InformationAction Continue
    New-Item -Itemtype "Directory" -Path $logDirectory
   }
   $logPath = "C:/temp/SSHKey-Logs/SSHKey-Log-" + $(Get-Date -Format "ddMMyyyyHHmmss") + ".txt"

   $keyPath = "C:/temp/certs/$appName" + "_" + "$env"

   Write-Output '***********************************************' >> $logPath
   Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Checking if $keyPath is existing ...") >> $logPath
   Write-Information -MessageData "Checking if $keyPath is existing" -InformationAction Continue

   if(Test-Path $keyPath)
   {
      Write-Output '***********************************************' >> $logPath
      Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"$keyPath already exists ...") >> $logPath
      Write-Information -MessageData "$keyPath is existing ..." -InformationAction Continue

   }
   else
   {
      Write-Output '***********************************************' >> $logPath
      Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Creating new directory: $keyPath ...") >> $logPath
      Write-Information -MessageData "Creating new directory: $keyPath ..." -InformationAction Continue

      New-Item -Itemtype "Directory"-Path $keyPath

      if(Test-Path $keyPath)
      {
         Write-Output '***********************************************' >> $logPath
         Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"New directory created: $keyPath ...") >> $logPath
         Write-Information -MessageData "New directory created: $keyPath ..." -InformationAction Continue

      }
      else
      {
         Write-Output '***********************************************' >> $logPath
         Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed to create new directory: $keyPath") >> $logPath
         Write-Error "Failed to create new directory: $keyPath"

         break
      }
   }

   Write-Output '***********************************************' >> $logPath
   Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Checking if $keyPath/$appName is existing ...") >> $logPath
   Write-Information -MessageData "Checking if $keyPath/$appName and $keyPath/$appName.pub is existing ..." -InformationAction Continue

   if((Test-Path $keyPath/$appName) -and (Test-Path "$keyPath/$appName.pub"))
   {
        Write-Output '***********************************************' >> $logPath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"$keyPath/$appName already exists, will not proceed with SSH key pair generation") >> $logPath
        Write-Information -MessageData "$keyPath/$appName already exists, will not proceed with SSH key pair generation" -InformationAction Continue
   }
   else
   {
       Write-Output '***********************************************' >> $logPath
       Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Generating SSH Pair Key...") >> $logPath
       Write-Information -MessageData "Generating SSH Pair Key..." -InformationAction Continue

       ssh-keygen -t rsa -b 4096 -f $keyPath/$appName -N "passphrase"

       Write-Output '***********************************************' >> $logPath
       Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"SSH Key Pair generated ...") >> $logPath
       Write-Information -MessageData "SSH Key Pair generated ..." -InformationAction Continue


   }

   $privateKey = "$keyPath/$appName"
   $publicKey = "$keyPath/$appName.pub"
   $generateRandom = Get-Random


   if((Test-Path $privateKey) -and (Test-Path $publicKey) )
   {

       Write-Output '***********************************************' >> $logPath
       Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Checking Connection to Azure ...") >> $logPath
       Write-Information -MessageData "Connecting to Azure ..." -InformationAction Continue

       $azctx = connect_azure

       if($azctx -contains $false)
       {
            Write-Output '***********************************************' >> $logPath
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed to Connect to Azure. Saving of SSH key pair to key vault did not proceed  ...") >> $logPath
            Write-Error "Failed to Connect to Azure. Saving of SSH key pair to key vault did not proceed  ..."
            break
       }
       else
       {
            Write-Output '***********************************************' >> $logPath
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Connected to Azure ...") >> $logPath
            Write-Information -MessageData "Connected to Azure ..." -InformationAction Continue

            Write-Output '***********************************************' >> $logPath
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Saving SSH public key to Key Vault: $keyVaultName ...") >> $logPath
            Write-Information -MessageData "Saving SSH public key to Key Vault: $keyVaultName ..." -InformationAction Continue

            $rawPubKey = Get-Content $publicKey -Raw
            $pubKeySecretValue = (New-Object System.Net.NetworkCredential("",$rawPubKey)).SecurePassword
            $pubKeySecretName = $appName + "-" + $env + "-ssh-pubkey" + $generateRandom

            $pubKeySecret = Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $pubKeySecretName -SecretValue $pubKeySecretValue

            if($null -ne $pubKeySecret)
            {
                Write-Output '***********************************************' >> $logPath
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully saved public key in the the key vault with secret name: $pubKeySecretName  ...") >> $logPath
                Write-Information -MessageData "Successfully saved public key in the the key vault with secret name: $pubKeySecretName  ..." -InformationAction Continue

                Write-Output '***********************************************' >> $logPath
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Validating key vault secret name: $pubKeySecretName ...") >> $logPath
                Write-Information -MessageData "Getting key vault secret name: $pubKeySecretName to validate successful saving of public key as a key vault secret ..." -InformationAction Continue

                $getPubKeySecretInfo = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $pubKeySecretName

                if($null -ne $getPubKeySecretInfo)
                {
                    Write-Output '***********************************************' >> $logPath
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Key vault secret: $pubKeySecretName found in the key vault ...") >> $logPath
                    Write-Information -MessageData $getPubKeySecretInfo.Id -InformationAction Continue

                    Write-Output '***********************************************' >> $logPath
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Deleting local copy for public key in $keyPath") >> $logPath
                    Write-Information -MessageData "Deleting local copy for public key in $keyPath" -InformationAction Continue

                    Remove-Item -Path $publicKey -Force

                    if(Test-Path $publicKey)
                    {

                        Write-Output '***********************************************' >> $logPath
                        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed to delete local copy of public key ...") >> $logPath
                        Write-Error "Failed to delete local copy of public key ..."
                        break

                    }
                    else
                    {

                        Write-Output '***********************************************' >> $logPath
                        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Local copy for public key deleted ...") >> $logPath
                        Write-Information -MessageData "Local copy for public key deleted ..." -InformationAction Continue

                    }

                }
                else
                {
                    Write-Output '***********************************************' >> $logPath
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed to validate if key vault secret: $pubKeySecretName exist in key vault: $keyVaultName ...") >> $logPath
                    Write-Error "Failed to validate if key vault secret: $pubKeySecretName exist in key vault: $keyVaultName ..."
                    break

                }
            }
            else
            {
                Write-Output '***********************************************' >> $logPath
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed to save public key in the the key vault ($keyVaultName) ...") >> $logPath
                Write-Error "Failed to save public key in the the key vault ($keyVaultName) .."
                break
            }

            Write-Output '***********************************************' >> $logPath
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Saving SSH private key to Key Vault: $keyVaultName ...") >> $logPath
            Write-Information -MessageData "Saving SSH private key to Key Vault: $keyVaultName ..." -InformationAction Continue

            $rawprivateKey = Get-Content $privateKey -Raw
            $privateKeySecretValue = (New-Object System.Net.NetworkCredential("",$rawprivateKey)).SecurePassword
            $privateKeySecretName = $appName + "-" + $env + "ssh-privateKey" + $generateRandom

            $privateKeySecret = Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $privateKeySecretName -SecretValue $privateKeySecretValue

            if($null -ne $privateKeySecret)
            {
                Write-Output '***********************************************' >> $logPath
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully saved private key in the the key vault with secret name: $privateKeySecretName  ...") >> $logPath
                Write-Information -MessageData "Successfully saved private key in the the key vault with secret name: $privateKeySecretName  ..." -InformationAction Continue

                Write-Output '***********************************************' >> $logPath
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Validating key vault secret name: $privateKeySecretName ...") >> $logPath
                Write-Information -MessageData "Getting key vault secret name: $privateKeySecretName to validate successful saving of private key as a key vault secret ..." -InformationAction Continue

                $getprivateKeySecretInfo = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $privateKeySecretName

                if($null -ne $getprivateKeySecretInfo)
                {
                    Write-Output '***********************************************' >> $logPath
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Key vault secret: $privateKeySecretName found in the key vault ...") >> $logPath
                    Write-Information -MessageData $getprivateKeySecretInfo.Id -InformationAction Continue

                    Write-Output '***********************************************' >> $logPath
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Deleting local copy for private key in $keyPath") >> $logPath
                    Write-Information -MessageData "Deleting local copy for private key in $keyPath" -InformationAction Continue

                    Remove-Item -Path $privateKey -Force

                    if(Test-Path $privateKey)
                    {

                        Write-Output '***********************************************' >> $logPath
                        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed to delete local copy of private key ...") >> $logPath
                        Write-Error "Failed to delete local copy of private key ..."
                        break

                    }
                    else
                    {

                        Write-Output '***********************************************' >> $logPath
                        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Local copy for private key deleted ...") >> $logPath
                        Write-Information -MessageData "Local copy for private key deleted ..." -InformationAction Continue

                    }

                }
                else
                {
                    Write-Output '***********************************************' >> $logPath
                    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed to validate if key vault secret: $privateKeySecretName exist in key vault: $keyVaultName ...") >> $logPath
                    Write-Error "Failed to validate if key vault secret: $privateKeySecretName exist in key vault: $keyVaultName ..."
                    break

                }
            }
            else
            {
                Write-Output '***********************************************' >> $logPath
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed to save private key in the the key vault ($keyVaultName) ...") >> $logPath
                Write-Error "Failed to save private key in the the key vault ($keyVaultName) .."
                break
            }


       }

   }
   else
   {
       Write-Output '***********************************************' >> $logPath
       Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"SSH Key Pair not generated ...") >> $logPath
       Write-Error "SSH Key Pair not generated ..."
       break
   }

}
catch
{
   Write-Output '***********************************************' >> $logPath
   Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Error: $_ ") >> $logPath
   Write-Error $_
   break
}
