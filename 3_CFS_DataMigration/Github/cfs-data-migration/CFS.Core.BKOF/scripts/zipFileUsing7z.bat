echo started
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& C:\Users\ADM-AD-DMT-CFS\scripts\zipFileUsing7z.ps1 -commRG 'rg-np-edc-bkof-dm-001' -keyVaultNameforSecret 'kv-np-edc-bkof-dm-0028' -localTargetDirectory 'S:\FromStorageAccount' -unzipPath 'T:\UnzipFile' -zipPath 'T:\EncryptedZipFile' -destContainerName 'democtn1234' -reportPath 'T:\DMF Report'"
    pause
exit /b