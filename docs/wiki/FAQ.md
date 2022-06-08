## In this Section

- [How long does enterprise-scale architecture take to deploy?](#how-long-does-enterprise-scale-architecture-take-to-deploy)
- [Why are there custom policy definitions as part of enterprise-scale architecture?](#why-are-there-custom-policy-definitions-as-part-of-enterprise-scale-reference-implementation)
- [Where can I see the policy definitions used by enterprise-scale landing zones reference implementation?](#where-can-i-see-the-policy-definitions-used-by-the-enterprise-scale-landing-zones-reference-implementation)
- [Why does enterprise-scale architecture require permission at tenant root '/' scope?](#why-does-the-enterprise-scale-reference-implementation-require-permission-at-tenant-root--scope)
- [The Azure landing zone accelerator portal-based deployment doesn't display all subscriptions in the drop-down lists?](#the-enterprise-scale-also-known-as-the-azure-landing-zone-accelerator-portal-based-deployment-doesnt-display-all-subscriptions-in-the-drop-down-lists)
- [Can we use and customize the ARM templates for enterprise-scale architecture and check them into our repository and deploy it from there?](#can-we-use-and-customize-the-arm-templates-for-enterprise-scale-architecture-and-check-them-into-our-repository-and-deploy-it-from-there)
- [What if we can't deploy by using the Azure landing zone accelerator portal-based experience, but can deploy via infrastructure-as-code?](#what-if-we-cant-deploy-by-using-the-azure-landing-zone-accelerator-portal-based-experience-but-can-deploy-via-infrastructure-as-code)
- [If we already deployed enterprise-scale architecture without using infrastructure-as-code, do we have to delete everything and start again to use infrastructure-as-code?](#if-we-already-deployed-enterprise-scale-architecture-without-using-infrastructure-as-code-do-we-have-to-delete-everything-and-start-again-to-use-infrastructure-as-code)
- [The `AzureDiagnostics` table in my Log Analytics Workspace has hit the 500 column limit, what should I do?](#the-azurediagnostics-table-in-my-log-analytics-workspace-has-hit-the-500-column-limit-what-should-i-do)

---

## Enterprise-scale FAQ

This article answers frequently asked questions relating to Enterprise-scale.

Some FAQ questions that relate more to the architecture are based over in the CAF docs here: [Enterprise-scale architecture FAQ](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/enterprise-scale/faq)

## How long does enterprise-scale architecture take to deploy?

Deployment time depends on the options you select during the implementation experience. It varies from around five minutes to 40 minutes, depending on the options selected.

For example:

- Reference implementation without any networking or connectivity options can take around five minutes to deploy.
- Reference implementation with the hub and spoke networking options, including VPN and ExpressRoute gateways, can take around 40 minutes to deploy.

## Why are there custom policy definitions as part of enterprise-scale reference implementation?

We work with and learn from our customers and partners. This collaboration helps us evolve and enhance the reference implementations to meet customer and partner requirements. As part of this interaction with customers and partners, we might notice policy definition gaps. In those cases, we create and test a definition to fill the gap and include it in enterprise-scale architecture for everyone to use.

We then work with the Azure Policy and associated engineering teams to continuously transition the new custom policy definitions into built-in policy definitions.

## Where can I see the policy definitions used by the enterprise-scale landing zones reference implementation?

You can find a list of policy definitions here: [Policies included in enterprise-scale landing zones reference implementations](https://github.com/Azure/Enterprise-Scale/blob/main/docs/ESLZ-Policies.md)

We also add changes to our [What's New? wiki page](https://github.com/Azure/Enterprise-Scale/wiki/Whats-new).

<!-- IMPLEMENTATION -->

## Why does the enterprise-scale reference implementation require permission at tenant root '/' scope?

Management group creation, subscription creation, and placing subscriptions into management groups are APIs that operate at the tenant root "`/`" scope.

To establish the management group hierarchy and create subscriptions and place them into the defined management groups, the initial deployment must be invoked at the tenant root "`/`" scope. Once you deploy enterprise-scale architecture, you can remove the owner permission from the tenant root "`/`" scope. The user deploying the enterprise-scale reference implementation is made an owner at the intermediate root management group (for example "Contoso").

For more information about tenant-level deployments in Azure, see [Deploy resources to tenant](https://docs.microsoft.com/azure/azure-resource-manager/templates/deploy-to-tenant).

## The enterprise-scale (also known as the Azure landing zone accelerator) portal-based deployment doesn't display all subscriptions in the drop-down lists?

When you deploy enterprise-scale via the portal-based deployment (also known as the Azure landing zone accelerator), the portal lists subscriptions to be selected for deployment from the platform subscriptions (management, connectivity, identity) and the landing zones (corp and online). When there are more than 50 subscriptions, the API can't display all of them in the drop-down lists.

Follow these steps as a workaround:

1. Select or enable your usual options in the portal-based experience. In the subscription drop-downs, select any visible subscription as a placeholder so that you can see and select all options (some options don't appear until you select a subscription).
1. After you've gone through each page, go back to the **Basics** page, and then select **Edit parameters**.
1. Change the value for the specific `subscriptionId` parameter inputs with the actual subscription IDs you want to use.
1. Select **Save**.
1. Select **Review + create**, and then submit the deployment.

## Can we use and customize the ARM templates for enterprise-scale architecture and check them into our repository and deploy it from there?

All of the ARM templates for enterprise-scale architecture are developed and optimized for the Azure landing zone accelerator portal-based experience. We don't recommend or support customization of these templates because they're complex. To handle all of the options and variations we provide for the Azure landing zone accelerator portal-based experience, ARM template expressions would need numerous logical operators and conditions. ARM deployments (nested templates) need to deploy in a specific order to be successful.

Finally, taking the same templates for future operations requires you to redeploy to the entire tenant for any change, and also requires permanent owner role-based access control assignment on the tenant root "`/`" scope.

However, if you want to deploy and manage enterprise-scale architecture via infrastructure-as-code, see [What if we can't deploy using the Azure landing zone accelerator portal-based experience, but want to deploy via infrastructure-as-code?](#what-if-we-cant-deploy-by-using-the-azure-landing-zone-accelerator-portal-based-experience-but-can-deploy-via-infrastructure-as-code).

## What if we can't deploy by using the Azure landing zone accelerator portal-based experience, but can deploy via infrastructure-as-code?

The following implementation options are available when you use infrastructure-as-code:

- The [Azure landing zone accelerator](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/#azure-landing-zone-accelerator) portal-based experience can integrate and bootstrap a CI/CD pipeline using GitHub with [AzOps](https://github.com/Azure/AzOps) as documented at [Deploying Enterprise Scale](https://github.com/Azure/Enterprise-Scale/wiki/Deploying-Enterprise-Scale).
- The [Enterprise-scale Do-It-Yourself (DIY) ARM templates](https://github.com/Azure/Enterprise-Scale/tree/main/eslzArm#enterprise-scale-landing-zones-arm-templates) method
- The [Terraform Module for Cloud Adoption Framework Enterprise-scale](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale#terraform-module-for-cloud-adoption-framework-enterprise-scale)
- The [Azure Landing Zone (formerly Enterprise-scale) Bicep Modules - Public Preview](https://github.com/Azure/ALZ-Bicep)

## If we already deployed enterprise-scale architecture without using infrastructure-as-code, do we have to delete everything and start again to use infrastructure-as-code?

If you used the Azure landing zone accelerator portal-based experience to deploy enterprise-scale architecture into your Azure tenant, see the guidance for the infrastructure-as-code tooling you want to use.

### ARM Templates

To use ARM templates to deploy, manage, and operate your enterprise-scale deployment, you don't have to delete everything and start again. You can configure and connect [AzOps](https://github.com/Azure/AzOps) tooling by using the [AzOps Accelerator](https://github.com/Azure/AzOps-Accelerator) and associated instructions, regardless of the stage of your Azure tenant.

Once configured, AzOps connects to your Azure tenant, scans it, and then pulls individual ARM templates into your repository in a structure that represents the [four Azure scopes](https://docs.microsoft.com/azure/azure-resource-manager/management/overview#understand-scope).

To see a demo of AzOps being used, check out this YouTube video on the Microsoft DevRadio channel: [Enterprise-scale landing zones DevOps and automation step by step](https://www.youtube.com/watch?v=wWLxxj-uMsY)

### Bicep

The [AzOps](https://github.com/Azure/AzOps) tooling supports deploying Bicep files at the [four Azure scopes](https://docs.microsoft.com/azure/azure-resource-manager/management/overview#understand-scope). Its pull process only stores the scan of your Azure tenants resources in ARM templates that use JSON.

Leave us feedback via [GitHub issues on the AzOps repository](https://github.com/Azure/AzOps/issues) if you want to see something added to AzOps.

### Terraform

Terraform builds its own [state](https://www.terraform.io/docs/language/state/index.html) file to track and configure resources. If you already deployed enterprise-scale architecture to your Azure tenant, [import](https://www.terraform.io/docs/cli/import/index.html) each resource into the state file to learn what it manages as part of your Terraform code. Then you can deploy, manage, and operate your enterprise-scale deployment via Terraform.

Terraform import is currently done on a per resource basis and can be time consuming and complex to do at scale. It's often easier to delete and redeploy via Terraform than to import everything that's been deployed by the Azure landing zone accelerator portal-based experience. Most customers know from the start that they want to use Terraform to manage their Azure tenant, so this scenario is uncommon.

To deploy enterprise-scale architecture by using Terraform, you might want to use the Terraform module we provide. It deploys everything that the Azure landing zone accelerator portal-based experience does. The module, [Terraform Module for Cloud Adoption Framework Enterprise-scale](https://registry.terraform.io/modules/Azure/caf-enterprise-scale/azurerm/0.0.4-preview), is available from the Terraform Registry page.

To see a demo of Terraform being used, check out this YouTube video on the Microsoft DevRadio channel: [Terraform Module for Cloud Adoption Framework Enterprise-scale Walkthrough](https://www.youtube.com/watch?v=5pJxM1O4bys)

## The `AzureDiagnostics` table in my Log Analytics Workspace has hit the 500 column limit, what should I do?

In larger environments that uses a range of different Azure services and associated features it can be common for you to hit the [500 maximum columns in a table limit](https://docs.microsoft.com/azure/azure-monitor/service-limits#log-analytics-workspaces). When this occurs data is not lost however, it is instead stored in a column called `AdditionalFields` as a dynamic property. 

However, some customers may not want this as it can make it more difficult and complex to query the data when the 500 column limit is breached and data is stored in the `AdditionalFields` column.

> More details on this can be found here: [AzureDiagnostics Table Docs](https://docs.microsoft.com/azure/azure-monitor/reference/tables/azurediagnostics)

To overcome this issue the Azure Monitor team has created a new collection type for diagnostic settings for resources called [**Resource-specific** collection mode](https://docs.microsoft.com/azure/azure-monitor/essentials/resource-logs#resource-specific). In this mode a separate table per Azure service is created in the Log Analytics Workspace which will mean the 500 column limit will not be hit and therefore querying and managing the data in the Log Analytics Workspace is simplified and more performant.

> An explanation of the 2 modes can be found here: [Azure resource logs](https://docs.microsoft.com/azure/azure-monitor/essentials/resource-logs)

### Next steps

As of today only a limited number of services support the [**Resource-specific** collection mode](https://docs.microsoft.com/azure/azure-monitor/essentials/resource-logs#resource-specific) which are listed [here.](https://docs.microsoft.com/azure/azure-monitor/reference/tables/azurediagnostics#azure-diagnostics-mode-or-resource-specific-mode)

We are working closely with the relevant Azure engineering teams to ensure the services add support for the [**Resource-specific** collection mode](https://docs.microsoft.com/azure/azure-monitor/essentials/resource-logs#resource-specific) and also create/update the [built-in Azure Policies](https://docs.microsoft.com/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#built-in-policy-definitions-for-azure-monitor) so we can then utilise them as part of our solution. 

Stay tuned to our [What's New page](https://github.com/Azure/Enterprise-Scale/wiki/Whats-new) where we will be announcing when we migrate services to the new collection type. Also watch [Azure Updates](https://azure.microsoft.com/updates/) for announcements from service teams for adding support to their services for this collection type.