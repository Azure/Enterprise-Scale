| Enterprise scale Design Principles | ARM Template | Scale without refactoring |
|:-------------|:--------------|:--------------|
|![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/BestPracticeResult.svg)|[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://ms.portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkrnese%2Fns%2Fmaster%2Fsrc%2Fe2e.json) | Yes |

# Deploy Enterprise scale with hub and spoke architecture

## Customer profile

This reference implementation is ideal for customers that have started their Enterprise scale journey with a Enterprise scale foundation implementation and then there is a need to add connectivity on-premises datacenters and branch offices by using a hub and spoke network architecture. This reference implementation is also well suited for customers who want to start with landing zones for their net new
deployment/development in Azure by implementing a network architecture based on the hub and spoke model.

## How to evolve from Enterprise scale foundation

If customer started with a Enterprise scale foundation deployment, and if the business requirements changes over time, such as migration of on-prem applications to Azure that requires hybrid connectivity, you will simply create the **connectivity** subscription and place it into the **platform** management group and assign Azure Policy for the hub and spoke network topology.

## Pre-requisites

To deploy this ARM template, your user/service principal must have Owner permission at the tenant root.
See the following [instructions](https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin) on how to grant access.

## What will be deployed?

- A scalable management group hiearchy aligned to core platform capabilities, allowing you to operationalize at scale using RBAC and Policy
- An Azure subscription dedicated for management, which enables core platform capabilities at scale such as security, auditing, and logging
- An Azure subscription dedicated for connectivity, which deploys core networking resources such as hub VNet, Azure Firewall, VPN Gateway, Route Tables, among others.
- Landing Zone management group for corp-connected applications that require hybrid connectivity. This is where you will create your subscriptions that will host your corp-connected workloads.
- Landing Zone management group for online applications that will be internet-facing, which doesn't require hybrid connectivity. This is where you will create your subscriptions that will host your online workloads.

![Enterprise scale with connectivity](./media/es-hubspoke.png)


