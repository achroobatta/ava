$grp = "MyBicepRG"
az group create --name $grp -l "eastus"
az deployment group create --resource-group $grp --template-file .\main.bicep --mode Complete
az deployment sub create --name 'sub-id' --template-file .\main.bicep  
az group delete --resource-group $grp --yes
