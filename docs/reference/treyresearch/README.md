| Enterprise-Scale Design Principles | ARM Template | Scale without refactoring |
|:-------------|:--------------|:--------------|
|![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/BestPracticeResult.svg)|[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://ms.portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjuazasan%2FEnterprise-Scale%2Ffta%2Ftrey-research-ri-abstracted%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fes-fta.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjuazasan%2FEnterprise-Scale%2Ffta%2Ftrey-research-ri-abstracted%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fportal-es-fta.json)  | Yes |

# Deploy Enterprise-Scale for Small and Medium Enterprises

The Enterprise-Scale architecture is modular by design and allow organizations to start with foundational landing zones that support their application portfolios, regardless of whether the applications are being migrated or are newly developed and deployed to Azure. The architecture enables organizations to start as small as needed and scale alongside their business requirements regardless of scale point.

## Customer profile

This reference implementation is ideal for customers who want to start with Landing Zones for their workload in Azure, where hybrid connectivity to their on-premise datacenter is not required from the start.

## How to evolve and add support for hybrid connectivity later

If the business requirements changes over time, such as migration of on-prem applications to Azure that requires hybrid connectivity, the architecture allows you to expand and implement networking without refactoring Azure Design with no disruption to what is already in Azure. The Enterprise-Scale architecture allows to create the Connectivity Subscription and place it into the platform Management Group and assign Azure Policies or/and deploy the target networking topology using either Virtual WAN or Hub and Spoke networking topology.
For more details, see the *next steps* section at the end of this document.

## Pre-requisites

To deploy this ARM template, your user must have Owner permission at the Tenant root.
See the following [instructions](../../EnterpriseScale-Setup-azure.md) on how to grant access.

## What will be deployed?

- A scalable Management Group hierarchy aligned to core platform capabilities, allowing you to operationalize at scale using centrally managed Azure RBAC and Azure Policy.
- Azure Policies that will enable autonomy for the platform and the Landing Zones.
- [Optional] An Azure subscription dedicated for management, which enables core platform capabilities at scale such as:
  - A Log Analytics workspace and an Automation account
  - Azure Security Center monitoring
  - Azure Security Center (Standard or Free tier)
  - Diagnostics settings for Activity Logs, VMs, and PaaS resources sent to Log Analytics
- [Optional] A landing zone subscription for Azure native, internet-facing applications and Resources, and specific workload policies such as:
  - Enforce VM backup
  - Enforce secure access (HTTPS) to storage accounts
  - Enforce auditing for Azure SQL
  - Enforce encryption for Azure SQL
  - Prevent IP forwarding
  - Prevent inbound RDP from internet
  - Ensure subnets are associated with NSG

![Enterprise-Scale without connectivity](./media/es-without-networking.PNG)

## Next steps

### From a platform perspective:

If you later want to add connectivity to your Enterprise-Scale architecture to support workloads requiring hybrid connectivity, you can:

1. Create a new child management group called 'Connectivity' in the Platform management group
2. Move/create new subscription into the Connectivity management group
3. Deploy your desired networking topology, being VWAN (Microsoft managed) or hub & spoke (customer managed)
4. Create new management group (Corp) in the landing zone management group, to separate connected workloads from online workloads.

Optionally, you can enable the above using the following ARM templates:

| Connectivity setup | Description | ARM Template |
|:-------------------------|:-------------|:-------------|
| Virtual WAN | Deploys requisite infrastructure for on-premises connectivity with Virtual WAN  |<!-- [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://ms.portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzOps%2Fmain%2Ftemplate%2Fux-hub-spoke.json) --> ETA (7/31) |
| Hub & Spoke | Deploys requisite infrastructure for on-premises connectivity with Hub & Spoke  |<!-- [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://ms.portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzOps%2Fmain%2Ftemplate%2Fux-hub-spoke.json) --> ETA (7/31) |

### From an application perspective:

Once you have deployed the reference implementation, you can create new subscriptions, or move an existing subscriptions to the Landing Zone management group (Online), and start deploying your workload.

#### Create new subscriptions into the landing zone (Online) management group

1. In Azure portal, navigate to Subscriptions
2. Click 'Add', and complete the required steps in order to create a new subscription.
3. When the subscription has been created, go to Management Groups and move the subscription into the Landing Zone (Online) management group
4. Assign RBAC permissions for the application team/user(s) who will be deploying resources to the newly created subscription

#### Move existing subscriptions into the landing zone (Online) management group

1. In Azure portal, navigate to Management Groups
2. Locate the subscription you want to move, and move it to the landing zone (Online) management group
3. Assign RBAC permissions for the application team/user(s) who will be deploying resources to the subscription