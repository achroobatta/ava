echo started
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& C:\Users\ADM-AD-DMT-CFS\scripts\copyFilefromSFTPtoDisk.ps1 -commRG 'rg-np-edc-bkof-dm-001' -localTargetDirectory 'S:\FromStorageAccount' -keyVaultNameforSecret 'kv-np-edc-bkof-dm-0028' -taskNumber '383' -buildId '5432221' -sourceStorageAccount 'sstornpedcbkofdm001' -srcSftpCtn 'ssftpnpedcbkofdm001.blob.core.windows.net' -srcSftpAcctNm 'ssftpnpedcbkofdm001.sparkuser1' -srcSftpPass 'srcSftpPwdt1234' -srcSftpKey 'srcSftpKeyt1234'"
    pause
exit /b