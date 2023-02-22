# cfs-virtual-data-centre

| Branch(es)           | Build status |
| -------------------- | ------------ |
| feature/* => develop | [![PR to develop branch Build](https://github.com/CFSCo/cfs-virtual-data-centre/actions/workflows/pr-to-develop-build.yml/badge.svg)](https://github.com/CFSCo/cfs-virtual-data-centre/actions/workflows/pr-to-develop-build.yml) |
| develop              | [![CI Build](https://github.com/CFSCo/cfs-virtual-data-centre/actions/workflows/ci-build.yml/badge.svg)](https://github.com/CFSCo/cfs-virtual-data-centre/actions/workflows/ci-build.yml) |
| develop => main      | [![PR to main branch Build](https://github.com/CFSCo/cfs-virtual-data-centre/actions/workflows/pr-to-main-build.yml/badge.svg)](https://github.com/CFSCo/cfs-virtual-data-centre/actions/workflows/pr-to-main-build.yml) |
| main                 | [![Release Build](https://github.com/CFSCo/cfs-virtual-data-centre/actions/workflows/release-build.yml/badge.svg)](https://github.com/CFSCo/cfs-virtual-data-centre/actions/workflows/release-build.yml) |


Solution layout
```Text
├──.github/                                        
├────workflows/                                    GitHub Actions yml in here are automatically picked up by GitHub
├──────branch-name-check.yml                       Runs for push to any branch, to check branch names are following conventions.
├──────ci-build.yml                                The CI build that triggers on push to develop branch.
├──────pr-to-develop-build.yml                     The Pull Request build that triggers on any pull request targeting the develop branch.
├──────pr-to-main-build.yml                        The Pull Request build that triggers on any pull request targeting the main branch.
├──────release-build.yml                           The Release build that triggers on push to main branch - represents a future deployment to production.
├──CFS.VirtualDataCentre.sln                       
├──CFS.VirtualDataCentre/                          
├────CFS.VirtualDataCentre.csproj                  Project file contains specification on how to bundle the Bicep and parameter JSON files into a Nuget file
├────README.md                                     
├────azure-pipelines/                              Directory containing all pipeline YAML files
├──────agents-runners-pipeline.yml                 The pipeline that provisions self-hosted ADO agents and GitHub runners.
├──────cfs-master-pipeline.yml                     The main pipeline that includes core infrastructure, each in its own stage.
├──────delete-agents-runners-pipeline.yml          The pipeline that deregisters self-hosted ADO agents and GitHub runners, with the option to delete the VM/Resource Group.
├──────templates/                                  Sub-directory for pipeline YAML templates (to be included as templates in other YAML files).
├────bicep-templates/                              Bicep templates (all files in this folder are included in the Nuget package during PR, CI and Release Builds)
├──────deployment/                                 
├────────deploy-storageAccount/                    Sub-directory for storage account Resource Type
├──────────deploy-storageAccount.bicep             Bicep file for storage account
├──────────identity-storageAccount.param.np.json   Parameter file for the identity storage account in Non-Prod
├──────────identity-storageAccount.param.prd.json  Parameter file for the identity storage account in Prod
├──────────security-storageAccount.param.np.json   Parameter file for the security storage account in Non-Prod
├──────────security-storageAccount.param.prd.json  Parameter file for the security storage account in Prod
├──────modules/                                    bicep modules
├────────Microsoft.Storage/                        Folder for storage account bicep modules (folder is in [resource_provider] format)
├──────────deployStorageAccount.bicep              A storage account bicep module.
├──────README.md                                   
├────scripts/                                      Directory for all scripts - powershell, shell.
├──────bicep-build.ps1                             This script is used in the PR, CI and Release Builds to build the Bicep into ARM, which are later scanned by the Checkov linter.
├────yaml-templates/                               
├──────README.md                                   
├──README.md                                       Top-level folder README
```
