$rgName = "rg-np-edc-bkof-dm-001"
$storageAcct = "dlgen2npedcbkof7922"
$location = "australiaeast"
$endpoint = "pve-$location-$storageAcct"
$dnsZoneGrp = "default"
$backSub = "subsc-np-backoffice-001"
$connSub = "subsc-np-connectivity-001"
$connRg = "rg-np-edc-hub-netw-001"

# az login --service-principal -u <app-id> -p <password-or-cert> --tenant <tenant>
az account set --subscription $backSub
$privateIp = az network private-endpoint dns-zone-group show --endpoint-name $endpoint -n $dnsZoneGrp -g $rgName --query privateDnsZoneConfigs[].recordSets[].ipAddresses[] --output tsv
$privateIp

az account set --subscription $connSub
az network private-dns record-set a list -g $connRg -z privatelink.blob.core.windows.net
az network private-dns record-set a add-record -g $connRg -a $privateIp -n $storageAcct -z privatelink.blob.core.windows.net
az logout