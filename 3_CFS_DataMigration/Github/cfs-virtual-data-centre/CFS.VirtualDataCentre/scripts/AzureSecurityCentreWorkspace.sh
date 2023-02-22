#!/bin/bash

###################################################################################################
#                                                                                                 #
#   Project:          CFS                                                                         #
#   Creator:          Sacha Roussakis-Notter                                                      #
#   Creation Date:    Monday, February 7th 2022, 10:39 am                                         #
#   File:             AzureSecurityCentreWorkspace.sh                                             #
#                                                                                                 #
#   Copyright (c) 2022 Avanade                                                                    #
#                                                                                                 #              
#   Description:      Set Workspace for Microsoft Cloud Defender using Log Analytics              #                                                   
#                                                                                                 #
#   Date                  By                  Comments                                            #
#   ---------             ---------           ------------------------------------------------    #
#                                                                                                 #
###################################################################################################

# $1 = $(AzureEnvironmentPrefix) injected at the pipeline
# $2 = $(AzureSubscriptionId) injected at the pipeline

LogAnalyticsWorkspaceId=$(az resource list -g 'rg-'"$1"'-edc-sec-sec-001' -n 'ws-'"$1"'-edc-001' --query "[].id" -o tsv --subscription ''"$2"'')

AzureSecurityCentreWorkspace()
{
        for i in $LogAnalyticsWorkspaceId; do
        echo Setting Log Analytics Worksapce in Cloud Defender for Cloud "$i"
        az security workspace-setting create -n 'ws-'"$1"'-edc-001' --target-workspace "$i"
    done
}

AzureSecurityCentreWorkspace "$1" "$2"