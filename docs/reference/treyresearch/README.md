| Enterprise-Scale Design Principles | ARM Template | Scale without refactoring | Internal Note |
|:-------------|:--------------|:--------------|:--------------|
|![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/BestPracticeResult.svg)|[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://ms.portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjuazasan%2FEnterprise-Scale%2Ffta%2Ftrey-research-ri-abstracted%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fes-lite.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjuazasan%2FEnterprise-Scale%2Ffta%2Ftrey-research-ri-abstracted%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fportal-es-lite.json)  | Yes | Uses default ES Deployment UI |
|![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/BestPracticeResult.svg)|[![Deploy To Azure (FTA Custom Experience)](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://ms.portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjuazasan%2FEnterprise-Scale%2Ffta%2Ftrey-research-ri-abstracted%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fes-lite.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjuazasan%2FEnterprise-Scale%2Ffta%2Ftrey-research-ri-abstracted%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fportal-es-fta.json)  | Yes | Uses custom Deployment UI |


# Deploy Enterprise-Scale for Small Enterprises

The Enterprise-Scale architecture is modular by design and allow organizations to start with foundational landing zones that support their application portfolios, regardless of whether the applications are being migrated or are newly developed and deployed to Azure. The architecture enables organizations to start as small as needed and scale alongside their business requirements regardless of scale point.

## Customer profile

This reference implementation provides a design path and initial technical state for Small and Medium Enterprises' Azure environment based on Azure Landing Zones Design Recommendations.

Enterprise-Scale Reference Implementation for Small Enterprises is meant for customers who are not expecting to deploy or migrate a large number of Workloads to Azure, and that do not have a large IT organization. Therefore the focus of this design is on simplicity, but at the same time to provide a Minimum Viable Product landing zone where production workloads can be deployed with confidence and managed by a small team.

That said, the architecture enables organizations to start as small as needed and scale alongside their business requirements regardless of scale point.

## What will be deployed?

*Coming soon...*

## How to evolve from the Reference Implementation

See the *next steps* section at the end of this document.

## Pre-requisites

### Permissions required

To deploy this ARM template, your user/service principal must have Owner permission at the Tenant root.
See the following [instructions](https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin) on how to grant access.

### Subscriptions required

The deployment experience in Azure portal allows you to bring in an existing (preferably empty) subscription dedicated for your Platform resources, and an existing subscription that can be used as the initial landing zone for your applications. In order to provide the information, we require the subscription id to be provided to the parameters.

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

## Deployment Experience

*Coming soon...*

## Post-deployment configuration

*Coming soon...*

## Next steps

### Manage your Landing Zones

Once you have deployed the reference implementation, you can provision additional Landing Zones and start deploying your workload.

#### Provision additional Landing Zones 

You can provision additional Landing Zones by moving new or existing subscriptions to an existing landing zone management group (for instance Online).

1. In Azure portal, navigate to Subscriptions.
2. Click 'Add', and complete the required steps in order to create a new subscription.
3. Go to Management Groups and move the subscription into the corresponding Landing Zone management group (for instance Online).
4. Create a Virtual Network in the new subscription.
5. Connect the new landing zone's Virtual Network to the virtual hub if hybrid connectivity is needed.
6. Assign RBAC permissions for the application team/user(s) who will be deploying resources to the newly created subscription.

Optionally, once you had completed steps 1 and 2 above, you can automate the provisioning of additional Landing Zones using the following ARM template:

[![Provision Landing Zone](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://ms.portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjuazasan%2FEnterprise-Scale%2Ffta%2Ftrey-research-ri-abstracted%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fes-add-lz.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjuazasan%2FEnterprise-Scale%2Ffta%2Ftrey-research-ri-abstracted%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fportal-es-add-lz.json) 

#### Create an additional Landing Zone for a new type of workload

You can create landing zones with a different configuration by using the following ARM template:

[![Add New Landing Zone Type](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://ms.portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjuazasan%2FEnterprise-Scale%2Ffta%2Ftrey-research-ri-abstracted%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fes-add-lz-template.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjuazasan%2FEnterprise-Scale%2Ffta%2Ftrey-research-ri-abstracted%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fportal-es-add-lz-template.json) 

### Deploy a Web Application Firewall to an existing Landing Zone

*Coming soon...*

### Deploy a Virtual Network to an existing Landing Zone

*Coming soon...*

#### Create an additional Landing Zone template / schema / archetype / type leveraging advanced Governance and Security Controls

*Coming soon...*

#### Import a Landing Zone template from the ES catalog

*Coming soon...*

### Extend your Platform

### Enable Hybrid Connectivity using [Azure ExpressRoute](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-introduction)

*Coming soon...*

#### Deploy a Perimeter Firewall in Azure

*Coming soon...*

#### Enable Hybrid Connectivity to an Azure Region 

If you skipped the deployment of the hybrid connectivity component when you bootstrapped your environment, or if you need to add support for additional regions, you can do it now by deploying a virtual hub, being VWAN (Microsoft managed) or hub & spoke (customer managed) as per your desired target networking topology, to the Platform subscription.

Optionally, you can enable the above using the following ARM templates:

| Connectivity setup | Description | ARM Template |
|:-------------------------|:-------------|:-------------|
| Virtual WAN | Deploys requisite infrastructure for on-premises connectivity with Virtual WAN  | [![Add Connectivity (vWAN)](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://ms.portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjuazasan%2FEnterprise-Scale%2Ffta%2Ftrey-research-ri-abstracted%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fes-add-vwan.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjuazasan%2FEnterprise-Scale%2Ffta%2Ftrey-research-ri-abstracted%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fportal-es-add-vwan.json)   |
| Hub & Spoke | Deploys requisite infrastructure for on-premises connectivity with Hub & Spoke  | [![Add Connectivity (H&S)](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://ms.portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjuazasan%2FEnterprise-Scale%2Ffta%2Ftrey-research-ri-abstracted%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fes-add-hub.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjuazasan%2FEnterprise-Scale%2Ffta%2Ftrey-research-ri-abstracted%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fportal-es-add-hub.json)  |

Once the virtual hub had been deployed, you will need to connect the virtual hub with any of the existing Landing Zones (if any) that required hybrid connectivity by creating Virtual Network Peerings. See [Connect virtual networks with virtual network peering using the Azure portal](https://docs.microsoft.com/en-us/azure/virtual-network/tutorial-connect-virtual-networks-portal) for further details. 
 
