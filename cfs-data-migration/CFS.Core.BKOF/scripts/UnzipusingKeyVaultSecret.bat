echo started
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& C:\Users\ADM-AD-DMT-CFS\scripts\UnzipusingKeyVaultSecret.ps1 -commRG 'rg-np-edc-bkof-dm-001' -keyVaultNameforSecret 'kv-np-edc-bkof-dm-0028' -secretName 'file1password' -localzippath 'S:\FromStorageAccount' -unzipPath 'T:\UnzipFile'"
    pause
exit /b