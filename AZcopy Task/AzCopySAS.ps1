$appId = "c5d25bfa-49bf-4e62-8668-ff0e70d0dd0b"
$tenantId = "574e14fe-5558-4211-a6a4-818ba8303014"
$env:AZCOPY_SPA_CLIENT_SECRET = "TdI8Q~yahqPuYURw0MH2oV3KQZL0vVAsktH2HbXs"
.\azcopy.exe login --service-principal --application-id $appId --tenant-id $tenantId
#$sourcePath = "https://dsftpnpedcbkof7565.blob.core.windows.net:40001/container7565/test.txt?sv=2021-12-02&ss=bfqt&srt=sco&sp=rwdlacupyx&se=2023-04-24T15:23:33Z&st=2023-04-24T07:23:33Z&spr=https&sig=8wtmQZwge%2B6z6TC69R61t17xZwaQEglkVxKj5EqLdGY%3D"
$sourcePath = "https://dsftpnpedcbkof7565.blob.core.windows.net:40001/container7565/test.txt"
#$sourcePath = "https://20.5.219.80:40001/container7565/test.txt"
#$sourcePath = "https://192.54.94.97/container7565/test.txt"
#$sourcePath = "https://dsftpnpedcbkof7565.blob.core.windows.net/container7565?sv=2021-12-02&ss=bfqt&srt=sco&sp=rwdlacupyx&se=2023-04-19T18:38:02Z&st=2023-04-19T10:38:02Z&spr=https&sig=JKu9WYW%2FIOXa%2FaZ5EHNDDSybJYH837CMWp9QcwQIByY%3D"
#$sourcePath = "https://dsftpnpedcbkof7566.blob.core.windows.net/container7566/test.txt?sv=2021-12-02&ss=bfqt&srt=sco&sp=rwdlacupyx&se=2023-04-20T09:42:17Z&st=2023-04-20T01:42:17Z&spr=https&sig=FhGXO2TvTgnemvgKwhcsFnKZ%2FNo3W9DkX9dEfQ%2BsKgc%3D"
$destPath = "C:\azcopy_windows_amd64_10.17.0"
.\azcopy.exe copy $sourcePath $destPath 
.\azcopy.exe logout