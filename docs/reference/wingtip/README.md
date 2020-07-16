| Enterprise-Scale Design Principles | ARM Template | Scale without refactoring |
|:-------------|:--------------|:--------------|
|![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/BestPracticeResult.svg)|[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://ms.portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzOps%2Fmain%2Ftemplate%2Fux-foundation.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzOps%2Fmain%2Ftemplate%2Fesux.json)  | Yes |

# Deploy Enterprise-Scale foundation

## Customer profile

This reference implementation is ideal for customers who want to start with Landing Zones for their workload in Azure, where hybrid connectivity to their on-premise datacenter is not required from the start.

## How to evolve and add support for hybrid connectivity later

If the business requirements changes over time, such as migration of on-prem applications to Azure that requires hybrid connectivity, the architecture allows you to expand and implement networking without refactoring Azure Design with minimal disruption to what is already in Azure. Architecture allows to create the Connectivity Subscription and place it into the platform Management Group and assign Azure Policy for the target networking topology using either Virtual WAN or Hub and Spoke networking topology.

## Pre-requisites

To deploy this ARM template, your user/service principal must have Owner permission at the Tenant root.
See the following [instructions](https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin) on how to grant access.

## What will be deployed?

- A scalable Management Group hierarchy aligned to core platform capabilities, allowing you to operationalize at scale using centrally managed Azure RBAC and Azure Policy.
- Azure Policies that will enable autonomy for the platform and the Landing Zones.
- An Azure Subscription dedicated for management, which enables core platform capabilities at scale such as security, auditing, and logging.
- Landing Zone Management Group for Azure native, internet-facing applications and Resources, which doesn't require hybrid connectivity. This is where you will create your Subscriptions that will host your workloads.

![Enterprise-Scale without connectivity](./media/es-without-networking.PNG)

## Next steps

Once you have an environment with your desired Management Group hierarchy, you can proceed to the next step, [Initialize Git With Current Azure configuration](../../Deploy/discover-environment.md).