$appId = "c5d25bfa-49bf-4e62-8668-ff0e70d0dd0b"
$tenantId = "574e14fe-5558-4211-a6a4-818ba8303014"
$env:AZCOPY_SPA_CERT_PASSWORD = "abc"
$certPath = "C:\azcopy_windows_amd64_10.17.0\putty\sp.pfx"
.\azcopy.exe login --service-principal --certificate-path $certPath  --application-id $appId --tenant-id $tenantId
#$sourcePath = "https://dsftpnpedcbkof7565.blob.core.windows.net/container7565/test.txt"
$sourcePath = "https://20.5.219.80:40001/container7565/test.txt"
$destPath = "C:\azcopy_windows_amd64_10.17.0"
.\azcopy.exe copy $sourcePath --from-to BlobFS $destPath
.\azcopy.exe logout