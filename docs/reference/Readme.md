
# What are Reference Implementations

Enterprise-Scale design principles and implementation can be adopted by all customers no matter what size and history their Azure estate. The following customer reference implementations target different and most common customer scenarios for a Enterprise-Scale adoption.

| Reference implementation | Description | ARM Template | Link |
|:-------------------------|:-------------|:-------------|------|
| Contoso | On-premises connectivity using Azure vWAN |[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://ms.portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzOps%2Fmain%2Ftemplate%2Fux-foundation.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzOps%2Fmain%2Ftemplate%2Fesux.json) | [Detailed description](./contoso/Readme.md) |
| AdventureWorks | On-premises connectivity with Hub & Spoke  |<!-- [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://ms.portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzOps%2Fmain%2Ftemplate%2Fux-hub-spoke.json) --> ETA (7/31) | [Detailed description](./adventureworks/README.md) |
| WingTip | Azure Only |[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://ms.portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzOps%2Fmain%2Ftemplate%2Fux-foundation.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzOps%2Fmain%2Ftemplate%2Fesux.json) | [Detailed description](./wingtip/README.md) |

# Reference Implementation

Enterprise-scale reference implementation is rooted in the principle that **Everything in Azure is a Resource**. All reference customers scenarios leverage native **Azure Resource Manager (ARM)** to describe and manage their Resources as part of their target state architecture at scale.

Enable security, logging, networking, and any other plumbing needed for landing zones (i.e. Subscriptions) autonomously through policy enforcement. Companies will deploy the Azure environment with ARM templates to create the necessary structure for management and networking to declare a desired goal state. All scenarios will apply the principle of "Policy Driven Governance" to deploy all necessary platform resources for a landing zone using policy. For example, deploying a Key Vault to store platform-level secrets in the management subscription instead of scripting the template deployment to deploy Key Vault, the Enterprise-Scale based reference implementation will have a policy definition that deploys the Key Vault in a prescriptive manner using a policy assignment at the management subscription scope. The core benefits of a policy-driven approach are manyfold but the most significant include:

* Platform can provide an orchestration capability to bring target Resources (in this case a subscription) to a desired goal state.
* Continuous conformance to ensure all platform-level Resources are compliant. Because the platform is aware of the goal state, the platform can assist by monitoring and remediation of Resources throughout the life-cycle of the Resource.
* Platform enables autonomy regardless of the customer's scale point.

## File -> New -> Region

Companies wants to leverage new Azure regions and deploy the workload closer to the user; and, they will be adding new Azure regions as business demand arises. As a part of Enterprise-Scale design principle of policy-driven governance, they will be assigning policies in their environment with a number of regions they would like to use and policies will ensure their Azure Environment is setup correctly:

### Management

All reference customers have decided to use a single Log Analytics workspace. When the first region is enabled, they will deploy Log Analytics workspace in their management subscription. No action will be required when enabling subsequent Azure regions as Azure Policy will ensure all platform logging is routed to the workspace.

### Networking

Here customers are taking different architecture designs. The following examples are for the Contoso reference implementation:

A policy will continuously check if a Virtual WAN VHub already exist in "Connectivity" subscription for all enabled regions and create one if it does not. Configure Virtual WAN VHub to secure internet traffic from secured connections (spoke VNets inside Landing Zone) to the internet via Azure Firewall.

For all Azure Virtual WAN VHubs, Policies will ensure that Azure Firewall is deployed and linked to the existing global Azure Firewall Policy as well as the creation of a regional Firewall policy, if needed.


An Azure Policy will also deploy default NSGs and UDRs in Landing Zones and, while NSG will be linked to all subnets, UDR will only be linked to VNet injected PaaS services subnets. The Azure Policy will ensure that the right NSG and UDR rules are configured to allow control plane traffic for VNet injected services to continue to work but only for those Azure PaaS services that have been approved as per the [Service Enablement Framework](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/security-governance-and-compliance#whitelist-the-service-framework) described in this document. This is required as, when landing zone VNets get connected to Virtual WAN VHub, they will get the default route (0.0.0.0/0) configured to point to their regional Azure Firewall, hence UDR and NSG rules are required to protect and manage control plane traffic for VNet injected PaaS services (such as SQL MI).

For cross-premises connectivity, Policy will ensure that ExpressRoute and/or VPN gateways are deployed (as required by the regional VHub), and it will connect the VHub to on-premises using ExpressRoute (by taking the ExpressRoute Resource ID and authorization key as parameters). In case of VPN, Contoso can decide if they use their existing SD-WAN solution to automate the connectivity from branch offices into Azure via S2S VPN, or alternatively, Contoso can manually configure the CPE devices on the branch offices and then let Azure Policy to configure the VPN sites in Azure Virtual WAN. As Contoso is rolling out a SD-WAN solution to manage the connectivity of all their branches around the globe, their preference is to use the SD-WAN solution, which is a solution certified with Azure Virtual WAN, to connect all their branches to Azure.

## File -> New -> Landing Zone (Subscription)

Reference customer wants to minimize the time it takes to create Landing Zones and do not want central IT to become a bottleneck. Subscriptions will be the unit of management for the landing zones and each business owner will have access to an Azure Billing Profile that will allow them to create new subscriptions (a.k.a. Landing Zones) with an ability to delegate this task to their own IT teams.
Once new a subscription is provisioned, the subscription will be automatically placed in the desired management group and subject to any configured policy.

Networking:

1) Create Virtual Network inside Landing Zone and establish Virtual Network peering with VWAN VHub in the same Azure region
2) Create Default NSG inside Landing Zone with default rules e.g. no RDP/SSH from Internet
3) Ensure new subnets are created inside Landing Zone and have NSGs
4) Default NSG Rules cannot be modified e.g. RDP/SSH from Internet
5) Enable NSG Flow logs and connect it to Log Analytics Workspace in management Subscription.
6) Protect Virtual Network traffic across VHubs with NSGs.

IAM

1) Create Azure AD Group for Subscriptions access
2) Create Azure AD PIM Entitlement for the scope

# File -> New -> Sandbox

Sandbox Subscriptions are for experiment and validation only. Sandbox Subscriptions will not be allowed connectivity to Production and Policy will prevent the connectivity to on-premises Resources.

## File -> Delete -> Sandbox/Landing Zone

Susbcription will be moved to a decommissioned Management Group. Decommissioned Management Group policies will deny creation of new services and a Subscription cancellation request will be sent.

# Implementation

Reference customers will use "AzOps" acronym (inspired by GitOps, KOps etc.) for Azure Operations in context of Enterprise-Scale design principles. They have decided to use platform-native capability to orchestrate, configure and deploy Landing Zones using Azure Resource Manager (ARM) for declaring goal state. They have abided by "Policy Driven Governance" design principle and wants landing zones (a.k.a Subscription) to be provisioned and configured autonomously.

All reference customer cases have deliberated over whether to use single a Template vs modular Templates and Pros and Cons of both. They have decided in favor of a single template for platform orchestration. The primary reason behind this is the template will mainly consist of Policy Definition and Policy Assignments. Since, Policy Assignments have direct dependency on Policy Definitions, it will be operationally easier to manage and control life-cycle changes/versioning if artifacts are represented in a single template.

They will use platform-provided schema as input to the parameter file. End-to-end template will use nested deployment to trigger deployment for nested children at appropriate scope (i.e. Management Group or Subscription scope).

```powershell
Get-AzManagementGroup -GroupName Tailspin -Expand -Recurse | ConvertTo-Json -Depth 100
```

Reasoning behind this is it can be machine generated on-demand and it can be **consistently** exported to be able to help with configuration drift.

```json
{
  "Id": "/providers/Microsoft.Management/managementGroups/Tailspin",
  "Type": "/providers/Microsoft.Management/managementGroups",
  "Name": "Tailspin",
  "TenantId": "3fc1081d-6105-4e19-b60c-1ec1252cf560",
  "DisplayName": "Tailspin",
  "UpdatedTime": "0001-01-01T00:00:00Z",
  "UpdatedBy": null,
  "ParentId": "/providers/Microsoft.Management/managementGroups/3fc1081d-6105-4e19-b60c-1ec1252cf560",
  "ParentName": "3fc1081d-6105-4e19-b60c-1ec1252cf560",
  "ParentDisplayName": "3fc1081d-6105-4e19-b60c-1ec1252cf560",
  "Children": [
    {
      "Type": "/providers/Microsoft.Management/managementGroups",
      "Id": "/providers/Microsoft.Management/managementGroups/Tailspin-bu1",
      "Name": "Tailspin-bu1",
      "DisplayName": "Tailspin-bu1",
      "Children": [
        {
          "Type": "/providers/Microsoft.Management/managementGroups",
          "Id": "/providers/Microsoft.Management/managementGroups/Tailspin-bu1-corp",
          "Name": "Tailspin-bu1-corp",
          "DisplayName": "Tailspin-bu1-corp",
          "Children": null
        }
      ]
    }
  ]
}

```

User should be able to copy/paste (a.k.a. "Export") output into input Template Parameter file. It is important to note that not all properties required but also having extra metadata will do no-harm and platform and template will ignore these properties. Please take a look at example [20-create-child-managementgroup.parameters.json](../../examples/20-create-child-managementgroup.parameters.json) for what is required.

```json
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "input": {
      "value": {
        "Name": "Tailspin",
        "DisplayName": "Tailspin",
        "ParentId": "/providers/Microsoft.Management/managementGroups/3fc1081d-6105-4e19-b60c-1ec1252cf560",
        "Children": [
          {
            "Id": "/providers/Microsoft.Management/managementGroups/Tailspin-bu1",
            "Name": "Tailspin-bu1",
            "DisplayName": "Tailspin-bu1",
            "Children": [
              {
                "Id": "/providers/Microsoft.Management/managementGroups/Tailspin-bu1-corp",
                "Name": "Tailspin-bu1-corp",
                "DisplayName": "Tailspin-bu1-corp"
              }
            ]
          }
        ]
      }
    }
  }
}
```

The ARM template deployment above should create the following deployment at root scope and nested deployment at the scope of children.

* Tailspin
* Tailspin-bu1
* Tailspin-bu1-corp

This ARM template can be expanded to include [Subscriptions](../../examples/60-move-subscription-under-managementgroup.parameters.json) (moving subscription),  [Policy Definition](../../examples/30-create-policydefinition-at-managementgroup.parameters.json), [Policy Assignment](../../examples/40-create-policyassignment-at-managementgroup.parameters.json), Role Definition and Role Assignment.

All reference customers have decided following for their reference implementation:

## Git repository for Azure Platform configuration

They are already using Azure and is concerned about their existing Management Group and Subscription already deployed in production. To address the concerns, they have decided to create Git repository to store existing Management Group and Subscription organization.

Azure Resources are organized in hierarchical manner:

```shell
Tenant Root
└───Management Group
    ├───Subscription
        ├───Resource Group
            ├───Resources
```

This is a clear advantage to organize these Resources in the same hierarchical layout inside Git Repo. Over time, Management Groups and Subscriptions move and/or are renamed. Therefore, organizing Resources in a hierarchical manner allows Contoso to track the lineage over time. It will also allow them to map the path of the Resources based on ResourceID in predictable manner inside Git and reduce miss-configuration.

**AzOpsScope** class will abstract the mapping between Resource identifiers in Azure and the path to Resources stored in the Git repo. This will facilitate a quick conversion between Git and Azure and vice versa. Examining the examples below, important properties to note are scope, type (e.g. Tenant, ManagementGroup, Subscription, Resource Group) and statepath (representing file location inside Git).

Another advantage of the class is recognized when deployment templates are updated in pull request, pipeline can determine at what scope to trigger deployments and appropriate parameters to pass like name, scope etc. In this way, pipeline can be triggered in predictable manner and deployment artefact can be organized at appropriate scope without  including deployment scripts in each pull request throughout the scope of the Azure platform using same Azure AD Tenant. Please check [deploy-templates](../Implementation-Getting-Started.md#deploy-templates) section for further details.

* New-AzTenantDeployment
* New-AzManagementGroupDeployment
* New-AzSubscriptionDeployment
* New-AzResourceGroupDeployment

```powershell
#Example-1
New-AzOpsScope -scope /providers/Microsoft.Management/managementGroups/contoso

scope            : /providers/Microsoft.Management/managementGroups/contoso
type             : managementGroups
name             : contoso
statepath        : C:\Git\Enterprise-scale\azops\3fc1081d-6105-4e19-b60c-1ec1252cf560\contoso\managementgroup.json
managementgroup  : contoso
subscription     :
resourcegroup    :
resourceprovider :
resource         :

#Example-2
New-AzOpsScope -path C:\Git\Enterprise-scale\azops\3fc1081d-6105-4e19-b60c-1ec1252cf560\contoso\connectivity

scope            : /subscriptions/99c2838f-a548-4884-a6e2-38c1f8fb4c0b
type             : subscriptions
name             : 99c2838f-a548-4884-a6e2-38c1f8fb4c0b
statepath        : C:\Git\Enterprise-scale\azops\3fc1081d-6105-4e19-b60c-1ec1252cf560\contoso\connectivity\subscription.json
managementgroup  : contoso
subscription     : connectivity
resourcegroup    :
resourceprovider :
resource         :
```

## Initalization

**Initialize-AzOpsRepository**

This will provide Discovery function to traverse the whole Management Group and Subscription hierarchy by calling:

```powershell
Get-AzManagementGroup -Recurse -expand -GroupName {{root Management Group name or ID}} | ConvertTo-Json -depth 100
```

This will build the relationship association between Management Group and Subscription.

### Deployment

**Invoke-AzOpsGitPush**

All reference customer want to ensure that all platform changes are peer reviewed and approved before deploying them into the production environment. They have decided to implement workflows (a.k.a. deployment pipeline) and use GitHub Actions for that. Contoso has named this workflow as "azops-push" referring to the direction of the change i.e. Git to Azure.  All platform changes will come in the form of pull requests and will be peer reviewed. Once a Pull Request review is completed satisfactorily, the Platform Team will attempt the merge of the pull request into the main branch and trigger a deployment action by calling the Invoke-AzOpsGitPush function.

This function will be the entry point of GitHub Actions when a pull request is approved but before it is merged in the main branch. The main branch represents the truth from an IaC perspective. This quality gate will ensure the main branch remains healthy and only contains artifacts that are successfully deployed in Azure. It will determine the files changed in a pull request by comparing a feature branch with the current main brach. The following actions should be executed inside Invoke-AzOpsGitPush:

* Validate current Azure configuration is the same as what is stored in Git by running Initialize-AzOpsRepository.
* Git will determine if working directory is dirty and exit the deployment task to alert user and run Initialize-AzOpsRepository interactively. All deployments should be halted at this stage as platform is in non-deterministic state from IaC point of view.
* Invoke built-in New-AZ-*Deployment commandlets at appropriate scope.


## Operationalize - Configuration Drift and Reconciliation

**Invoke-AzOpsGitPull**

"Operationalize" Azure environment at-scale for day-to-day activities.

All reference customers have decided to leverage PowerShell 7 and has mandated that all CI tasks must complete successfully on both Windows and Linux hosts simultaneously to ensure complete coverage. No local execution should be necessary after initialization and discovery activity is completed, and they will publish these CI tasks as GitHub Actions.
