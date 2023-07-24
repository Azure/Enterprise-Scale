## Background

This guide describes how to get started with implementing alert policies and initiatives in your environment for testing and validation. In the guide it is assumed that you will be using GitHub actions or manual deployment to implement policies, initiatives and policy assignments in your environment. 

> Note that this is a preview solution intended to solicitate feedback for further development which should be tested in a safe environment before deploying to production to protect against possible failures/unnecessary cost. 
> Also note that this private repo is shared with different select Microsoft customers and partners, as such you should never upload or otherwise divulge sensitive information to this repo. If there is any concern, please contact your Microsoft counterparts for detailed advice.

The repo at present contains code and details for the following:

- Policies to automatically create alerts, action groups and alert processing rules for different Azure resource types, centered around a recommended Azure Monitor Baseline for Alerting in a customers´ newly created or existing brownfield ALZ deployment.
- Initiatives grouping said policies into appropriate buckets for ease of policy assignment in alignment with ALZ Platform structure (Networking, Identity and Management).

Alerts, action groups and alert processing rules are created as follows:

1. All metric alerts are created in the resource group where the resource that is being monitored exists. i.e. creating an ER circuit in a resource group covered by the policies will create the corresponding alerts in that same resource group.
2. Activity log alerts are created in a specific resource group (created specifically by and used for this solution) in each subscription, when the subscription is deployed. The resource group name is parameterized, with a default value of AlzMonitoring-rg.
3. Resource health alerts are created in a specific resource group (created specifically by and used for this solution) in each subscription, when the subscription is deployed. The resource group name is parameterized, with a default value of AlzMonitoring-rg.
4. Action groups and alert processing rules are created in a specific resource group (created specifically by and used for this solution) in each subscription, when the subscription is deployed. The resource group name is parameterized, with a default value of AlzMonitoring-rg.

## Prerequisites

1. Azure Active Directory Tenant.
2. ALZ Management group hierarchy deployed as described [here](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-areas).*
3. Minimum 1 subscription, for when deploying alerts through policies. 
4. Deployment Identity with `Owner` permission to the pseudo root management group.  Owner permission is required to allow the Service Principal Account to create role-based access control assignments. 
5. If deploying manually, i.e. via Azure CLI or PowerShell, ensure that you have [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep) installed and working, before attempting installation. See here for how to configure for [Azure CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-cli) and here for [PowerShell](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-powershell)
6. For the policies to work, the following Azure resource providers, normally registered by default, must be registered on all subscriptions in scope:
    - Microsoft.AlertsManagement
    - Microsoft.Insights
  
  Please see [here](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider) for details on how to register a resource provider should you need to do so.

7. For leveraging the log alerts for Virtual Machines, ensure that VM Insights is enabled for the Virtual Machines to be monitored. For more details on VM Insights deployment see [here](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-enable-overview) . Please note only the performance collection of the VM insights solution is required  for the current alerts to deploy. 

_*While it´s recommended to implement the alert policies and initiatives to an ALZ Management Group hierarchy, it is not a technical requirement. These policies and initiatives can be implemented in existing brownfield scenarios that don´t adhere to the ALZ Management Group hierarchy. For example, in hierarchies where there is a single management group, or where the structure does not align to ALZ. At least one management group is required. In case you haven't implemented management groups, we included guidance on how to get started._

## Getting started

- Fork this repo to your own GitHub organization, you should not create a direct clone of the repo. Pull requests based off direct clones of the repo will not be allowed.
- Clone the repo from your own GitHub organization to your developer workstation.
- Review your current configuration to determine what scenario applies to you. We have guidance that will help deploy these policies and initiatives whether you are aligned with Azure Landing Zones, or use other management group hierarchy, or you may not be using management groups at all. If you know your type of management group hierarchy, you can skip forward to your preferred deployment method:
  - [Automated deployment with GitHub Actions](./Deploy-AMBA-with-GitHub-Actions) (recommended method)
  - [Automated deployment with Azure Pipelines](./Deploy-AMBA-with-Azure-Pipelines) (alternative recommended method)
  - [Manual deployment with Azure CLI ](./Deploy-AMBA-with-Azure-CLI)
  - [Manual deployment with Azure PowerShell](./Deploy-AMBA-with-Azure-PowerShell)

### Determining your management group hierarchy

Azure Landing Zones is a concept that provides a set of best practices, patterns, and tools for creating a cloud environment that is secure, Well-Architected, and easy to manage. Management groups are a key component of Azure Landing Zones, as they allow you to organize and manage your subscriptions and resources in a hierarchical structure. By using management groups, you can apply policies and access controls across multiple subscriptions and resources, making it easier to manage and govern your Azure environment.

The initiatives provided in this repository align with the management group hierarchy guidelines of Azure Landing Zones. Effectively creating the following assignment mapping between the initiative and the management group:

* Identity Initiative is assigned to the Identity management group.
* Management Initiative is assigned to the Management management group.
* Connectivity Initiative is assigned to the Connectivity management group.
* Landing Zone Initiative is assigned to the Landing Zone management group.
* Service Health Initiative is assigned to the intermediate (ALZ) root management group.

The image below is an example of how a management group hierarchy looks like when you follow Azure Landing Zone guidance. Also illustrated in this image is the default recommended assignments of the initiatives.

![ALZ Management group structure](./media/amba-alz-management-groups.png)

If you have this management group hierarchy, you can skip forward to your preferred deployment method:
* [Deploy with GitHub Actions](./Deploy-AMBA-with-GitHub-Actions)
* [Deploy with Azure Pipelines](./Deploy-AMBA-with-Azure-Pipelines)
* [Deploy with Azure CLI](./Deploy-AMBA-with-Azure-CLI)
* [Deploy with Azure PowerShell](./Deploy-AMBA-with-Azure-PowerShell)

It´s important to understand why we assign initiatives to certain management groups. In the previous example, the assignment mapping was done this way because the associated resources within a subscription below a management group have a specific purpose. For example, below the Connectivity management group you will find a subscription that contains the networking components like Firewalls, Virtual WAN, Hub Networks, etc. Consequently, this is where we assign the connectivity initiative to get relevant alerting on those services. It wouldn't make sense to assign the connectivity initiative to other management groups when there are no relevant networking services deployed.

We recognize that Azure allows for flexibility and choice, and you may not be aligned with ALZ. For example, you may have:

* A management group structure that is not aligned to ALZ. Where you may only have a Platform management group without the sub management groups like Identity/ Management/ Connectivity. 
* No management group structure.

> **NOTE:** If you are looking to align your Azure environment to Azure landing zone, please see [Transition existing Azure environments to the Azure landing zone conceptual architecture](http://aka.ms/alz/brownfield).

Suppose Identity/ Management/ Connectivity are combined in one Platform Management Group, the approach could be to assign the three corresponding initiatives to the Platform management group instead. Maybe you have a hierarchy where you organize by geography and/or business units instead of specific landing zones. Assignment mapping:

* Identity Initiative is assigned to the Platform management group.
* Management Initiative is assigned to the Platform management group.
* Connectivity Initiative is assigned to the Platform management group.
* Landing Zone Initiative is assigned to the Geography management group.
* Service Health Initiative is assigned to the top-most level(s) in your management group hierarchy.

The image below is an example of how the assignments could look like when the management group hierarchy isn´t aligned with ALZ.

![Management group structure - unaligned](./media/amba-alz-management-groups-unaligned.png)

We recommend that you review the [initiative definitions](../blob/main/src/resources/Microsoft.Authorization/policySetDefinitions/amba/) to determine where best to apply the initiatives in your management group hierarchy.

If you have this management group hierarchy, you can skip forward to your preferred deployment method:
* [Deploy with GitHub Actions](./Deploy-AMBA-with-GitHub-Actions)
* [Deploy with Azure Pipelines](./Deploy-AMBA-with-Azure-Pipelines)
* [Deploy with Azure CLI](./Deploy-AMBA-with-Azure-CLI)
* [Deploy with Azure PowerShell](./Deploy-AMBA-with-Azure-PowerShell)

If management groups were never configured in your environment, there are some additional steps that need to be implemented. To be able to deploy the policies and initiatives through the guidance and code we provide you need to create at least one management group, and by doing so the tenant root management group is created automatically. We strongly recommend following the [Azure Landing Zones guidance](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/resource-org-management-groups) on management group design. 

Please refer to our [documentation](https://learn.microsoft.com/en-us/azure/governance/management-groups/create-management-group-portal) on how to create management groups. 

If you implemented the recommended management group design, you can skip forward to your preferred deployment method, following the ALZ aligned guidance.
* [Deploy with GitHub Actions](./Deploy-AMBA-with-GitHub-Actions)
* [Deploy with Azure Pipelines](./Deploy-AMBA-with-Azure-Pipelines)
* [Deploy with Azure CLI](./Deploy-AMBA-with-Azure-CLI)
* [Deploy with Azure PowerShell](./Deploy-AMBA-with-Azure-PowerShell)

If you implemented a single management group, we recommend to move your production subscriptions into that management group, consult the steps in the [documentation](https://learn.microsoft.com/en-us/azure/governance/management-groups/manage#add-an-existing-subscription-to-a-management-group-in-the-portal) for guidance to add the subscriptions.
> To prevent unnecessary alerts, we recommend keeping development, sandbox, and other non-production subscriptions either in a different management group or below the tenant root group.

The image below is an example of how the assignments look like when you are using a single management group.

![Management group structure - single](./media/amba-alz-management-groups-single.png)

## Customizing policy assignments

As mentioned previously the above guidance will deploy policies, alerts and action groups with default settings. For details on how to customize policy and in particular initiative assignments please refer to [Customize Policy Assignment](./Customize-AMBA-Policy-Assignment)

## Customizing the `AMBA` policies

Whatever way you may choose to consume the policies we do expect, and want, customers and partners to customize the policies to suit their needs and requirements for their design in their local copies of the policies.

For example, if you want to include more thresholds, metrics, activity log alerts or similar, outside of what the parameters allow you to change and customize, then by opening the individual policy or initiative definitions you should be able to read, understand and customize the required lines to meet your requirements easily.

This customized policy can then be deployed into your environment to deliver the desired functionality.

## Disabling Monitoring

If you wish to disable monitoring for a resource or for alerts targeted at subscription level such as Activity Log, Service Health, and Resource Health. A "MonitorDisable" tag can be created with a value of "true" at the scope where you wish to disable monitor. This will effectively filter the resource or subscription from the compliance check for the policy.

<!-- markdownlint-disable -->
> **IMPORTANT:** If you believe the changes you have made should be more easily available to be customized by a parameter etc. in the policies, then please raise an [issue](https://github.com/Azure/Enterprise-Scale/issues) for a 'Feature Request' on the repository.
> 
> If you wish to, also feel free to submit a pull request relating to the issue which we can review and work with you to potentially implement the suggestion/feature request. 
<!-- markdownlint-restore -->

## Cleaning up an AMBA Deployment

In some scenarios, it may be necessary to remove everything deployed by the ALZ Monitor solution. If you want to clean up all resources deployed, please refer to the instructions on running the [Cleaning up an AMBA Deployment](./Cleaning-up-an-AMBA-Deployment).

# Next steps
- To customize policy assignments, please proceed with [Customize Policy Assignment](./Customize-AMBA-Policy-Assignment)
- To deploy with GitHub Actions, please proceed with [Deploy with GitHub Actions](./Deploy-AMBA-with-GitHub-Actions)
- To deploy with Azure DevOps Pipelines, please proceed with [Deploy with Azure Pipelines](./Deploy-AMBA-with-Azure-Pipelines)
- To deploy with Azure CLI, please proceed with [Deploy with Azure CLI](./Deploy-AMBA-with-Azure-CLI)
- To deploy with Azure PowerShell, please proceed with [Deploy with Azure PowerShell](./Deploy-AMBA-with-Azure-PowerShell)
- To deploy Service Health or another Policy Initiative (individually) with Azure CLI, please proceed with [Deploy individual Policy Initiatives with Azure CLI](./Deploy-AMBA-individual-Policy-Initiatives-with-Azure-CLI)
- To deploy Service Health or another Policy Initiative (individually) with PowerShell, please proceed with [Deploy individual Policy Initiatives with Azure PowerShell](./Deploy-AMBA-individual-Policy-Initiatives-with-Azure-PowerShell)