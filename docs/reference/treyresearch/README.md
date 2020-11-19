| Enterprise-Scale Design Principles | ARM Template | Scale without refactoring |
|:-------------|:--------------|:--------------|
|![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/BestPracticeResult.svg)| [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fes-lite.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fportal-es-lite.json)  | Yes |

# Enterprise-scale for small enterprises
The Enterprise-scale architecture is modular by design. It allows organizations to start with foundational landing zones that support their application portfolios, regardless of whether the applications are being migrated or are newly developed. The architecture enables organizations to start as small as needed and scale alongside their business requirements irrespective of scale point.

## Customer profile
This reference implementation provides a design path and initial technical state for Small and Medium Enterprises' Azure environment based on Azure Landing Zones Design Recommendations.

Enterprise-Scale Reference Implementation for Small Enterprises is meant for customers who are not expecting to deploy or migrate many Workloads to Azure and do not have a large IT organization. Therefore, this design focuses on simplicity and provides a Minimum Viable Product landing zone where production workloads can be deployed with confidence and managed by a small team.

That said, the architecture enables organizations to start as small as needed and scale alongside their business requirements regardless of scale point


## Pre-requisites

To deploy this ARM template, your user/service principal must have Owner permission at the Tenant root.
See the following [instructions](https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin) on how to grant access.

## Subscriptions required 

The Azure portal's deployment experience allows you to bring in an existing (preferably empty) subscription dedicated to your Platform resources and a subscription used as the initial landing zone for your applications. To provide the information, we require the subscription id to be provided to the parameters.

To learn how to create new subscriptions programatically, please visit this [link](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/programmatically-create-subscription?tabs=rest).

To learn how to create new subscriptions using Azure portal, please visit this [link](https://azure.microsoft.com/en-us/blog/create-enterprise-subscription-experience-in-azure-portal-public-preview/).

To find the subscriptionId's you want to provide, you can either navigate to Azure portal and retrive them from there, or use PowerShell/CLI:

Azure CLI

````bash
az account list --query "[].[name, id]" --output table
````

Azure PowerShell

````powershell
Get-AzSubscription | Select Name, SubscriptionId
````


## What will be deployed?

*coming soon*

