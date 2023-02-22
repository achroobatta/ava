az deployment sub create --location "australiaeast" --template-file main.bicep  --parameters adminUsername=$username --parameters adminPassword=$password --only-show-errors

az deployment sub create --location "australiaeast" --template-file main.bicep --only-show-errors

az deployment group create -g cfskxkrg --template-file test.bicep

az deployment sub delete -n main 

az deployment group create -g demorg --template-file runCommand.bicep