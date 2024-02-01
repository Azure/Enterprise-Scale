
# ALZ Azure Resource Provider Recommendations


## What are Resource Providers in Azure?

An Azure resource provider is a set of REST operations that enable functionality for a specific Azure service. For example, the Key Vault service consists of a resource provider named **Microsoft.KeyVault**. The resource provider defines [REST operations](https://learn.microsoft.com/rest/api/keyvault/) for managing vaults, secrets, keys, and certificates.

To deploy a resource in Azure, you must ensure your Azure subscription is registered for the resource provider that is associated with that resource. Registration configures your subscription to work with the resource provider. You can view a list of all resource providers in Azure by service [here](https://learn.microsoft.com/azure/azure-resource-manager/management/azure-services-resource-providers#registration). Learn how to view all your resource providers in the portal [here](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-providers-and-types#view-resource-provider).

## Default Resource Providers

Some resource providers are turned on by Azure by default on all subscriptions during time of subscription creation and are not possible to unregister.  Some examples are Microsoft.SerialConsole, Microsoft.Authorization, and Microsoft.Consumption. You can view a list of providers turned on by default by service [here](https://learn.microsoft.com/azure/azure-resource-manager/management/azure-services-resource-providers#registration).  Resource providers marked with **- registered by default** in the tables are automatically registered for your subscription, and you do not need to worry about them.

## Resource Providers for Enterprise-Scale ALZ Deployment (Empty Subscriptions)

To successfully deploy an Enterprise-Scale with a predefined [template](https://aka.ms/caf/ready/accelerator), along with ensuring other [prerequisites](https://github.com/Azure/Enterprise-Scale/wiki/Deploying-ALZ-Pre-requisites) are complete, ensure these Resource Providers are [registered](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-providers-and-types) in ALL subscriptions associated with your new Landing Zone:

* microsoft.insights
* Microsoft.AlertsManagement
* Microsoft.OperationalInsights
* Microsoft.OperationsManagement
* Microsoft.Automation
* Microsoft.AlertsManagement
* Microsoft.Security
* Microsoft.Network
* Microsoft.EventGrid
* Microsoft.ManagedIdentity
* Microsoft.GuestConfiguration
* Microsoft.Advisor
* Microsoft.PolicyInsights

This list of RPs is all you need to deploy Enterprise Scale for EMPTY subscriptions (only resources listed in the template). If you want to deploy additional resources, please ensure the RPs for those resources are also registered.

Most of the time, if they are not registered prior, Azure should automatically register them for you. However, in some cases, deployment fails if the proper Resource Providers are not registered. 

# Additional Recommended Resource Providers to Register (for common resources)

Some other common Resource Providers to consider having registered in your subscriptions for resources you may deploy are:

* Microsoft.Compute
* Microsoft.Storage
* Microsoft.ResourceHealth
* Microsoft.KeyVault
* Microsoft.Sql
* Microsoft.Capacity
* Microsoft.ManagedServices
* Microsoft.Management
* Microsoft.SecurityInsights
* Microsoft.Blueprint
* Microsoft.Cache
* Microsoft.RecoveryServices
