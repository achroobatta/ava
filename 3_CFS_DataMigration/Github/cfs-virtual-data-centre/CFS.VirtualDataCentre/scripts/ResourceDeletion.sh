#!/bin/bash

###################################################################################################
#                                                                                                 #
#   Project:          CFS                                                                         #
#   Creator:          Sacha Roussakis-Notter                                                      #
#   Creation Date:    Friday, February 4th 2022, 15:39 pm                                         #
#   File:             ResourceDeletion.sh                                                         #
#                                                                                                 #
#   Copyright (c) 2022 Avanade                                                                    #
#                                                                                                 #              
#   Description:      Destroys Azure Resource Groups relevant to the stage that was deployed      #                                                   
#                                                                                                 #
#   Date                  By                  Comments                                            #
#   ---------             ---------           ------------------------------------------------    #
#                                                                                                 #
###################################################################################################

######################### Example Usage in Master Pipeline #####################################

# Copy and paste this block in the relevant stage you want it to apply to, change the arguments in the inclineScript relevant to the ${component}
# in the resource group, example changing 'stor' to 'kv' to find and delete keyvault resource groups change subscription id to correct one example
# $(sc-subsc-prd-security-sid) uses security subscription id if you want it to look in identity change it to $(sc-subsc-prd-identity-sid).

#----------------------------------------------------------------------------------------------#
#            - ${{ if eq(parameters.destroyDeployment, true) }}:
#              - task: AzureCLI@2
#                displayName : DeleteStageResourceGroups
#                inputs:
#                  azureSubscription: $(AzureSubscriptionConnectionName)
#                  scriptType: 'pscore'
#                  scriptLocation: 'inlineScript'
#                  inlineScript: bash $(System.ArtifactsDirectory)\$(scripts)\ResourceDeletion.sh 'stor' '$(sc-subsc-prd-security-sid)' '$(deploymentName)' $(System.ArtifactsDirectory)\$(deployments)\resourceGroupCleanup.template.json'
#----------------------------------------------------------------------------------------------#

## Arguments:

# $1 = Code unique component relevant to each stage for example "comp", "stor", "kv" - injected at the pipeline
# $2 = $(sc-subsc-prd-security-sid) - subscription id injected at the pipeline
# $3 = $(deploymentName) - injected at the pipeline uses the stage displayName
# $4 = $(System.ArtifactsDirectory)\$(deployments)\resourceGroupCleanup.template.json - injected at the pipeline
rg_component='-'"$1"'-'
ResourceGroups=$(az group list --query "[? contains(name, '$rg_component')][].{name:name}" -o tsv --subscription ''"$2"'')
CleanedOutput=$(echo "$ResourceGroups" | tr -d '\r')

AzureResourceGroups()

{
    for i in $CleanedOutput; do
        echo Querying Stage Resource Groups "'$i'";
        az deployment group create --mode Complete --no-prompt --template-file "$4" --name "$3" --resource-group "$i" -c;
        az configure --defaults group="$i";
        az group delete -y -n "$i" --verbose; 
    done
}

AzureResourceGroups "$1" "$2" "$3" "$4"