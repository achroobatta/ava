# cfs-application-platform-common

| Branch(es)           | Build status |
| -------------------- | ------------ |
| feature/* => develop | [![PR to develop branch Build](https://github.com/CFSCo/cfs-application-platform-common/actions/workflows/pr-to-develop-build.yml/badge.svg)](https://github.com/CFSCo/cfs-application-platform-common/actions/workflows/pr-to-develop-build.yml) |
| develop              | [![CI Build](https://github.com/CFSCo/cfs-application-platform-common/actions/workflows/ci-build.yml/badge.svg)](https://github.com/CFSCo/cfs-application-platform-common/actions/workflows/ci-build.yml) |
| develop => main      | [![PR to main branch Build](https://github.com/CFSCo/cfs-application-platform-common/actions/workflows/pr-to-main-build.yml/badge.svg)](https://github.com/CFSCo/cfs-application-platform-common/actions/workflows/pr-to-main-build.yml) |
| main                 | [![Release Build](https://github.com/CFSCo/cfs-application-platform-common/actions/workflows/release-build.yml/badge.svg)](https://github.com/CFSCo/cfs-application-platform-common/actions/workflows/release-build.yml) |


Solution layout
```Text
├──.github/                                        
├────workflows/                                    GitHub Actions yml in here are automatically picked up by GitHub
├──────branch-name-check.yml                       Runs for push to any branch, to check branch names are following conventions.
├──────ci-build.yml                                The CI build that triggers on push to develop branch.
├──────pr-to-develop-build.yml                     The Pull Request build that triggers on any pull request targeting the develop branch.
├──────pr-to-main-build.yml                        The Pull Request build that triggers on any pull request targeting the main branch.
├──────release-build.yml                           The Release build that triggers on push to main branch - represents a future deployment to production.
├──CFS.Application.Platform.Common.sln                       
├──CFS.Application.Platform.Common/                          
├────CFS.Application.Platform.Common.csproj        Project file contains specification on how to bundle the Bicep and parameter JSON files into a Nuget file
├────README.md                                     
├────azure-pipelines/                              Directory containing all pipeline YAML files
├──────*-pipeline.yml                              The pipeline that ...
├──────templates/                                  Sub-directory for pipeline YAML templates (to be included as templates in other YAML files).
├────bicep-templates/                              Bicep templates (all files in this folder are included in the Nuget package during PR, CI and Release Builds)
├──────deployment/                                 
├────────deploy-*/                                 Sub-directory for * Resource Type
├──────────deploy-*.bicep                          Bicep file for *
├──────────*.param.np.json                         Parameter file for the Non-Prod
├──────────*.param.prd.json                        Parameter file for the Prod
├──────modules/                                    bicep modules
├────────Microsoft.ProviderName                    Folder for * bicep modules (folder is in [resource_provider] format)
├──────────deploy*.bicep                           A * bicep module.
├──────README.md                                   
├────scripts/                                      Directory for all scripts - powershell, shell.
├────yaml-templates/                               
├──────README.md                                   
├──README.md                                       Top-level folder README
```
