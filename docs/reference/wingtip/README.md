| Enterprise-Scale Design Principles | ARM Templates | Scale without refactoring |
|:-------------|:--------------|:--------------|
|![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/BestPracticeResult.svg)|[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Fwingtip%2FarmTemplates%2Fes-foundation.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Fwingtip%2FarmTemplates%2Fportal-es-foundation.json) | Yes |

# Deploy Enterprise-Scale foundation

The Enterprise-Scale architecture is modular by design and allow organizations to start with foundational landing zones that support their application portfolios, regardless of whether the applications are being migrated or are newly developed and deployed to Azure. The architecture enables organizations to start as small as needed and scale alongside their business requirements regardless of scale point.

## Customer profile

This reference implementation is ideal for customers who want to start with Landing Zones for their workloads in Azure, where hybrid connectivity to their on-premises datacenter is not required from the start.

## How to evolve and add support for hybrid connectivity later

If the business requirements changes over time, such as migration of on-prem applications to Azure that requires hybrid connectivity, the architecture allows you to expand and implement networking without refactoring Azure Design with no disruption to what is already in Azure. The Enterprise-Scale architecture allows to create the Connectivity Subscription and place it into the platform Management Group and assign Azure Policies or/and deploy the target networking topology using either Virtual WAN or Hub and Spoke networking topology.
For more details, see the *next steps* section at the end of this document.

## Pre-requisites

To deploy this ARM template, your user/service principal must have Owner permission at the Tenant root.
See the following [instructions](../../EnterpriseScale-Setup-azure.md) on how to grant access before you proceed.

### Optional pre-requsites

The deployment experience in Azure portal allows you to bring in an existing (preferably empty) subscription dedicated for platform management, and an existing subscription that can be used as the initial landing zone for your applications.

To learn how to create new subscriptions programatically, please visit this [link](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/programmatically-create-subscription).

To learn how to create new subscriptions using Azure portal, please visit this [link](https://azure.microsoft.com/en-us/blog/create-enterprise-subscription-experience-in-azure-portal-public-preview/).

## Enterprise-Scale Management Group Structure

The Management Group structure implemented with Enterprise-Scale is as follows:
* Top-level Management Group (directly under the tenant root group) is created with a prefix provided by the organization, which purposely will avoid the usage of the root group to allow organizations to move existing Azure subscriptions into the hierarchy, and also enables future scenarios. This Management Group is parent to all the other Management Groups created by Enterprise-Scale
* Platform: This Management Group contains all the platform child Management Groups, such as Management, Connectivity, and Identity. Common Azure Policies for the entire platform is assigned at this level
* Management: This Management Group contains the dedicated subscription for management, monitoring, and security, which will host Azure Log Analytics, Azure Automation, and Azure Sentinel. Specific Azure policies are assigned to harden and manage the resources in the management subscription.
* Landing Zones: This is the parent Management Group for all the landing zone subscriptions and will have workload agnostic Azure Policies assigned to ensure workloads are secure and compliant.
* Online: This is the dedicated Management Group for Online landing zones, meaning workloads that may require direct inbound/outbound connectivity.
* Sandboxes: This is the dedicated Management Group for subscriptions that will solely be used for testing and exploration by an organization’s application teams. These subscriptions will be securely disconnected from the Corp and Online landing zones.
* Decommissioned: This is the dedicated Management Group for landing zones that are being cancelled, which then will be moved to this Management Group before deleted by Azure after 30-60 days.

## What happens when you deploy Enterprise-Scale?

By default, all recommendations are enabled, and you must explicitly disable them if you don't want them to be deployed and configured.
* A scalable Management Group hierarchy aligned to core platform capabilities, allowing you to operationalize at scale using centrally managed Azure RBAC and Azure Policy where platform and workloads have clear separation.
*	Azure Policies that will enable autonomy for the platform and the landing zones.
* An Azure subscription dedicated for Management, which enables core platform capabilities at scale using Azure Policy such as:
  * A Log Analytics workspace and an Automation account
  * Azure Security Center monitoring
  * Azure Security Center (Standard or Free tier)
  * Azure Sentinel
  * Diagnostics settings for Activity Logs, VMs, and PaaS resources sent to Log Analytics
* (Optionally) An Azure subscription dedicated for Identity in case your organization requires to have Active Directory Domain Controllers in a dedicated subscription.
* (Optionally) Integrate your Azure environment with GitHub (Azure DevOps will come later), where you provide the PA Token to create a new repository and automatically discover and merge your deployment into Git.
* Landing Zone Management Group for Online applications that will be internet-facing, where a virtual network is optional and hybrid connectivity is not required.
  * This is where you will create your Subscriptions that will host your online workloads.
* Landing zone subscriptions for Azure native, internet-facing Online applications and resources.
* Azure Policies for online landing zones, which include:
  * Enforce VM monitoring (Windows & Linux)
  *	Enforce VMSS monitoring (Windows & Linux)
  *	Enforce Azure Arc VM monitoring (Windows & Linux)
  * Enforce VM backup (Windows & Linux)
  * Enforce secure access (HTTPS) to storage accounts
  * Enforce auditing for Azure SQL
  * Enforce encryption for Azure SQL
  * Prevent IP forwarding
  * Prevent inbound RDP from internet
  * Ensure subnets are associated with NSG

![Enterprise-Scale without connectivity](./media/es-without-networking.PNG)

## Deployment

When you click on Deploy to Azure for this reference implementation, the Azure portal will load the deployment experience into your default Azure tenant. In case you have access to multiple tenants, ensure you are selecting the right one.

### Basics

On the Basics blade, select the Region. This region will primarily be used to place the deployment resources in an Azure region, but also used as the initial region for some of the resources that are deployed, such as Azure Log Analytics and Azure automation.

![Enterprise-Scale region](./media/basics.PNG)

### Enterprise-Scale company prefix

Provide a prefix that will be used to create the management group hierarchy, and platform resources.

![Enterprise-Scale prefix](./media/prefix.PNG)

### Platform management, security, and governance

On the Platform management, security, and governance blade, you will configure the core components to enable platform monitoring and security. The options you enable will also be enforced using Azure Policy to ensure resources, landing zones, and more are continuously compliant as your deployments scales and grows. To enable this, you must provide a dedicated (empty) subscription that will be used to host the requisite infrastructure.

![Enterprise-Scale platform](./media/platform.PNG)

### Platform DevOps and Automation

You can choose to bootstrap your CICD pipeline (GitHub with GitHub actions). Provide your GitHub user/org name, the preferred name of the GitHub repository that is to be created, as well as the PA token that the deployment will use to create a new repository and discover the Enterprise-Scale deployment ARM templates and merge them into your main branch.
You can either create a new Service Principal - or use an existing one that will be granted *Owner* permission on the management group hieararchy that will be created, so your CICD pipeline can discover and deploy ARM templates to all scopes (management groups, subscriptions, and resource groups).

![Enterprise-Scale devops](./media/existingSpn.PNG)

To create a new Service Principal, a new blade will open and you must first register the application, and create a new secret that you must *copy and paste* back to the deployment experience and provide as password.

1. Create new Service Principal, and click *Register*

![New SPN](./media/newSpn.PNG)

2. A new interface will open, where you must create a new secret. Note that the secret can not be retrieved after this, so it is important you copy and store this. You must paste the secret into the SPN password.

![New Secret1](./media/createSecret.png)

3. Create the secret

![New Secret2](./media/addClientSecret.PNG)

4. Copy the secret value to clipboard

![New Secret3](./media/secretValue.PNG)

5. Close the Service Principal interface by clicking at the 'X' at the upper right corner

![Exit](./media/exit.PNG)

5. Paste the secret into the SPN password

![Copy](./media/copySecret.PNG)

### Landing zone configuration

You can optionally bring in N number of subscriptions that will be bootstrapped as landing zones, governed by Azure Policy. Select which policy you want to assign broadly to all of your landing zones. 

![Lz configuration](./media/lz.PNG)

### Review + create

Review + Create page will validate your permission and configuration before you can click deploy. Once it has been validated successfully, you can click Create.

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
| Virtual WAN | Deploys requisite infrastructure for on-premises connectivity with Virtual WAN  |[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Fwingtip%2FarmTemplates%2Fes-add-vwan.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Fwingtip%2FarmTemplates%2Fportal-es-add-vwan.json) |
| Hub & Spoke | Deploys requisite infrastructure for on-premises connectivity with Hub & Spoke  |[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Fwingtip%2FarmTemplates%2Fes-add-hub.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Fwingtip%2FarmTemplates%2Fportal-es-add-hub.json) |

### From an application perspective:

Once you have deployed the reference implementation, you can create new subscriptions, or move an existing subscriptions to the Landing Zone management group (Online), and finally assign RBAC to the groups/users who should use the landing zones (subscriptions) so they can start deploying their workloads.

Refer to the [Create Landing Zone(s)](../../EnterpriseScale-Deploy-landing-zones.md) article for guidance to create Landing Zones.
