#!/bin/bash

###################################################################################################
#                                                                                                 #
#   Project:          CFS                                                                         #
#   Creator:          Sacha Roussakis-Notter                                                      #
#   Creation Date:    Friday, February 4th 2022, 15:39 pm                                         #
#   File:             AzureSecurityCentre.sh                                                      #
#                                                                                                 #
#   Copyright (c) 2022 Avanade                                                                    #
#                                                                                                 #              
#   Description:      Loops through variables to Enable Resources on Azure Defender for Cloud     #                                                   
#                                                                                                 #
#   Date                  By                  Comments                                            #
#   ---------             ---------           ------------------------------------------------    #
#                                                                                                 #
###################################################################################################

## This is just the start of the automation more needs to be added to this

AzureSecurityCentreResources="KeyVaults VirtualMachines StorageAccounts"

AzureResources()
{
    for i in $AzureSecurityCentreResources; do
        echo Setting Standard Tier for Azure Resources "$i"
        az security pricing create -n "$i" --tier 'Standard'
        echo Querying SKU Tier for Azure Resources "$i"
        az security pricing show -n "$i" --query "[{SubscriptionResourceId:id, ResourceName:name, SKU:pricingTier}]" --output table
    done
}

AzureResources