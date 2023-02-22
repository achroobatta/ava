#!/bin/bash

###################################################################################################
#                                                                                                 #
#   Project:          CFS                                                                         #
#   Creator:          Sacha Roussakis-Notter                                                      #
#   Creation Date:    Friday, February 4th 2022, 15:39 pm                                         #
#   File:             EnableResourceProviders.sh                                                  #
#                                                                                                 #
#   Copyright (c) 2022 Avanade                                                                    #
#                                                                                                 #              
#   Description:      Loops through variables to Enable Resource Providers on subscriptions       #                                                   
#                                                                                                 #
#   Date                  By                  Comments                                            #
#   ---------             ---------           ------------------------------------------------    #
#                                                                                                 #
###################################################################################################

AzureProviders="Microsoft.GuestConfiguration Microsoft.ManagedIdentity Microsoft.Network Microsoft.Insights"

AzureProviders()
{
    for i in $AzureProviders; do
        echo Enabling Azure Providers to Subscriptions for "$i"
        az provider register --namespace "$i"
        echo Querying Azure Providers to Subscriptions for registrationState "$i"
        az provider show --namespace "$i" --query "[{SubscriptionProviderId:id, Status:registrationState}]" --output table
    done
}

AzureProviders