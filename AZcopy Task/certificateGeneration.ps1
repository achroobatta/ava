$certname = "ServicePrincipal"    ## Replace {certificateName}
$cert = New-SelfSignedCertificate -Subject "CN=$certname" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256
Export-Certificate -Cert $cert -FilePath "C:\Users\achroo.batta\Downloads\azcopy_windows_amd64_10.17.0\putty\spPub.cer"   ## Specify your preferred location

$mypwd = ConvertTo-SecureString -String "abc" -Force -AsPlainText  ## Replace {myPassword}
Export-PfxCertificate -Cert $cert -FilePath "C:\Users\achroo.batta\Downloads\azcopy_windows_amd64_10.17.0\putty\sp.pfx" -Password $mypwd   ## Specify your preferred location
    