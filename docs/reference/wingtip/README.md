| Enterprise scale Design Principles | ARM Template | Scale without refactoring |
|:-------------|:--------------|:--------------|
|![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/BestPracticeResult.svg)|[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://ms.portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkrnese%2Fns%2Fmaster%2Fsrc%2Fe2e.json) | Yes |

# Deploy Enterprise scale foundation

## Customer profile

This reference implementation is ideal for customers who want to start with landing zones for their net new development in Azure, where hybrid connectivity to their on-premise datacenters is not required from the start.

## How to evolve and add support for hybrid connectivity later

If the business requirements changes over time, such as migration of on-prem applications to Azure that requires hybrid connectivity, the architecture allows you to expand and implement networking without any refactoring of the architecture nor implications to the runtime state of existing applications. You will simply create the connectivity subscription and place it into the platform management group and assign Azure Policy for the particular networking topology you desire.

## Pre-requisites

To deploy this ARM template, your user/service principal must have Owner permission at the tenant root.
See the following [instructions](https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin) on how to grant access.

## What will be deployed?

- A scalable management group hiearchy aligned to core platform capabilities, allowing you to operationalize at scale using RBAC and Policy
- An Azure subscription dedicated for management, which enables core platform capabilities at scale such as security, auditing, and logging
- Landing Zone management group for Azure native, internet-facing applications and resources, which doesn't require hybrid connectivity. This is where you will create your subscriptions that will host your workloads.

![Enterprise scale without connectivity](./media/es-without-networking.PNG)
