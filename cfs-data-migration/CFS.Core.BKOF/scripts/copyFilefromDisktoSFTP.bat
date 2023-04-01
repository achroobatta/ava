echo started
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& C:\Users\ADM-AD-DMT-CFS\scripts\copyFilefromDisktoSFTP.ps1 -commRG 'rg-np-edc-bkof-dm-001' -destStorageAccount 'dsftpnpedcbkof7565' -zipPath 'T:\EncryptedZipFile' -destContainerName 'tcscontainer7565'"
    pause
exit /b