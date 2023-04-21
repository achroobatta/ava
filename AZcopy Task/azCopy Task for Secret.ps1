$appId = "76e6f816-aa2c-4955-9cf2-40bf8ee88ece"
$tenantId = "259d5f85-f632-42ec-bcc5-b1b2072d0504"
#$mypwd = ConvertTo-SecureString -String "abc" -Force -AsPlainText
$env:AZCOPY_SPA_CERT_PASSWORD = "abc"
$certPath = "C:\Users\achroo.batta\Downloads\azcopy_windows_amd64_10.17.0\putty\sp.pfx"
.\azcopy.exe login --service-principal --certificate-path $certPath  --application-id $appId --tenant-id $tenantId
$sourcePath = "https://20.5.219.80:40001/data/Stripe.ps1"
$destPath = "C:\Users\achroo.batta\Downloads\azcopy_windows_amd64_10.17.0"
.\azcopy.exe copy $sourcePath $destPath
.\azcopy.exe logout