| Enterprise-Scale Design Principles | ARM Template | Scale without refactoring |
|:-------------|:--------------|:--------------|
|![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/BestPracticeResult.svg)| [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Fadventureworks%2FarmTemplates%2Fes-hubspoke.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Fadventureworks%2FarmTemplates%2Fportal-es-hubspoke.json)  | Yes |

# Deploy Enterprise-Scale with hub and spoke architecture

## Customer profile

This reference implementation is ideal for customers that have started their Enterprise-Scale journey with a Enterprise-Scale foundation implementation and then there is a need to add connectivity on-premises datacenters and branch offices by using a hub and spoke network architecture. This reference implementation is also well suited for customers who want to start with Landing Zones for their net new
deployment/development in Azure by implementing a network architecture based on the hub and spoke model.

## How to evolve from Enterprise-Scale foundation

If customer started with a Enterprise-Scale foundation deployment, and if the business requirements changes over time, such as migration of on-premise applications to Azure that requires hybrid connectivity, you will simply create the **Connectivity** Subscription and place it into the platform **connectivity** Management Group and assign Azure Policy for the hub and spoke network topology.

## Pre-requisites

To deploy this ARM template, your user/service principal must have Owner permission at the Tenant root.
See the following [instructions](../../EnterpriseScale-Setup-azure.md) on how to grant access before you proceed.

### Optional pre-requsites

The deployment experience in Azure portal allows you to bring in an existing (preferably empty) subscription dedicated for platform management, and an existing subscription that can be used as the initial landing zone for your applications.

To learn how to create new subscriptions programatically, please visit this [link](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/programmatically-create-subscription?tabs=rest).

To learn how to create new subscriptions using Azure portal, please visit this [link](https://azure.microsoft.com/en-us/blog/create-enterprise-subscription-experience-in-azure-portal-public-preview/).

## What will be deployed?

By default, all recommendations are enabled and you must explicitly disable them if you don't want it to be deployed and configured. 

- A scalable Management Group hierarchy aligned to core platform capabilities, allowing you to operationalize at scale using centrally managed Azure RBAC and Azure Policy where platform and workloads have clear separation
- Azure Policies that will enable autonomy for the platform and the landing zones.
- An Azure subscription dedicated for management, which enables core platform capabilities at scale using Azure Policy such as:
  - A Log Analytics workspace and an Automation account
  - Azure Security Center monitoring
  - Azure Security Center (Standard or Free tier)
  - Azure Sentinel
  - Diagnostics settings for Activity Logs, VMs, and PaaS resources sent to Log Analytics
- An Azure subscription dedicated for connectivity, enabling both connectivity of hybrid (on-premises) environment and corporate connected landing zones
  - Virtual Network hub
  - VPN Gateway
  - Express Route Gateway
  - Azure Firewall
- A landing zone subscription for Azure native, internet-facing applications and Resources, and specific workload Azure Policies such as:
  - Enforce VM monitoring (Windows & Linux)
  - Enforce VMSS monitoring (Windows & Linux)
  - Enforce Azure Arc VM monitoring (Windows & Linux)
  - Enforce VM backup (Windows & Linux)
  - Enforce secure access (HTTPS) to storage accounts
  - Enforce auditing for Azure SQL
  - Enforce encryption for Azure SQL
  - Prevent IP forwarding
  - Prevent inbound RDP from internet
  - Ensure subnets are associated with NSG

![Enterprise-Scale with connectivity](./media/es-hubspoke.png)

## Next steps

### From an application perspective:

Once you have deployed the reference implementation, you can create new subscriptions, or move an existing subscriptions to the Landing Zone management group (Online), and finally assign RBAC to the groups/users who should use the landing zones (subscriptions) so they can start deploying their workload.

#### Create new subscriptions into the landing zone (Online) management group

1. In Azure portal, navigate to Subscriptions
2. Click 'Add', and complete the required steps in order to create a new subscription.
3. When the subscription has been created, go to Management Groups and move the subscription into the Landing Zone (online) management group
4. Assign RBAC permissions for the application team/user(s) who will be deploying resources to the newly created subscription

#### Move existing subscriptions into the landing zone (Online) management group

1. In Azure portal, navigate to Management Groups
2. Locate the subscription you want to move, and move it to the landing zone (Online) management group
3. Assign RBAC permissions for the application team/user(s) who will be deploying resources to the subscription

#### [Preview] Create N number of subscriptions into targeted management groups using Azure Portal

The following deployment experiences can be leveraged to create multiple landing zones (subscriptions) and target Landing Zone management groups (online).

##### Pre-requesites

This [document](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/programmatically-create-subscription?tabs=rest-getEnrollments%2Crest-EA%2Crest-getBillingAccounts%2Crest-getBillingProfiles%2Crest-MCA%2Crest-getBillingAccount-MPA%2Crest-getCustomers%2Crest-getIndirectResellers%2Crest-MPA) outlines the requirements depending on the agreement type you have, and the RBAC permissions needed.

| Agreement types | ARM Template |
|:-------------------------|:-------------|
| Enterprise Agreement (EA) |[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Flzs%2FarmTemplates%2Feslz.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Flzs%2FarmTemplates%2Fportal-eslz.json)
| Microsoft Customer Agreement  | Coming soon
| Microsoft Partner Agreement | Coming soon