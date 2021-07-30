## In this Section

- [In this Section](#in-this-section)
- [Updates](#updates)
  - [July 2021](#july-2021)
  - [June 2021](#june-2021)

---

Enterprise Scale is updated regularly. This page is where you'll find out about the latest updates to Enterprise Scale for:

- [CAF (Cloud Adoption Framework) Documentation](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/enterprise-scale/) Updates
- Improvements to existing guidance and artifacts
- Azure Policy changes
- Bug fixes
- Tooling updates:
  - [AzOps](https://github.com/azure/azops)
    - [Releases](https://github.com/Azure/AzOps/releases)
  - [Terraform Module for Cloud Adoption Framework Enterprise-scale](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale)
    - [Releases](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/releases)

> **Note:** Please check the latest release notes for each of the tools, as these will contain more detailed notes relating to changes in each of the tools.

This article will be updated as and when changes are made to the above and anything else of relevance for Enterprise Scale. Make sure to check back here often to keep up with new updates and changes.

> **Important:** Previous changes to the above in relation to Enterprise Scale will not be listed here. However going forward, this page will be updated.

## Updates

Here's what's changed in Enterprise Scale:

### July 2021

#### Docs

- Added guidance for Resource Group usage for Azure Networking topologies in [Hub & Spoke](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/traditional-azure-networking-topology) & [Virtual WAN](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/virtual-wan-network-topology) CAF docs - closing issue [#632](https://github.com/Azure/Enterprise-Scale/issues/632)
- Updated [Connectivity to Azure PaaS services](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/connectivity-to-azure-paas-services) CAF docs based on customer feedback around Private Link /Service Endpoints differences and guidance, including ExpressRoute peering options relating to this. Closing issue - [#519 on CAF repository](https://github.com/MicrosoftDocs/cloud-adoption-framework/issues/519)
- Updated [Contoso](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/contoso/Readme.md), [Adventure Works](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/adventureworks/README.md) & [Wingtip Toys](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/wingtip/README.md) reference implementations with new Deploy To Azure buttons for new portal experience
  - Also updated guidance and option availability for each of them respectively
- [User Guide](https://github.com/Azure/Enterprise-Scale/wiki) updated to reflect latest release and new portal experience
- New Article to [Deploy Azure Red Hat OpenShift (ARO) in enterprise-scale landing zones](https://github.com/Azure/Enterprise-Scale/tree/main/workloads/ARO)

#### Tooling

- Portal Experience Updated
  - Merged Contoso, AdventureWorks, and Wingtip into one ESLZ deployment experience via first-party deployment in the portal ("Deploy To Azure" button) experience
    - Support "N" network topologies in same experience (Hub and Spoke, Virtual WAN, Hub and Spoke with NVA)
    - Added option for VNET Peering the Identity subscription's VNET to the Connectivity subscription's Hub VNET
    - Added option for VNET peering Landing Zones to Connectivity subscription when Hub & Spoke is the selected topology (Virtual WAN is excluded due to concurrency issues, at this time) - closing issue [#517](https://github.com/Azure/Enterprise-Scale/issues/517)
    - Navigate policy assignment for identity, when using single vs dedicated subscriptions for platform purposes
    - Optimized the execution graph
- Re-structured the ARM templates for all resource deployments
  - `eslzArm.json` is used to orchestrate the E2E composition of ESLZ, and subsequent resource deployments based on user input from the portal ("Deploy To Azure" button) experience
  - The composite ARM templates can be sequenced on their own, independently of each other (although strict sequencing is required to ensure the same outcome)
    - Guidance coming soon for this
  - Customers can deploy from private repository if they want to sequence at their own pace.
- ~~[AzOps release v1.3.0](https://github.com/Azure/AzOps/releases/tag/1.3.0)~~ 
- ~~[AzOps release v1.3.1](https://github.com/Azure/AzOps/releases/tag/1.3.1)~~
- [AzOps release v1.4.0](https://github.com/Azure/AzOps/releases/tag/1.4.0)

#### Policy

- Various custom ESLZ Azure Policies have moved to Built-In Azure Policies, see below table for more detail:

> You may continue to use the ESLZ custom Azure Policy as it will still function as it does today. However, we recommend you move to assigning the new Built-In version of the Azure Policy. 
> 
> **Please note** that moving to the new Built-In Policy Definition will require a new Policy Assignment and removing the previous Policy Assignment, which will mean compliance history for the Policy Assignment will be lost. However, if you have configured your Activity Logs and Security Center to export to a Log Analytics Workspace; Policy Assignment historic data will be stored here as per the retention duration configured.

**Policy Definitions Updates**

| Custom ESLZ Policy Name | Custom ESLZ Policy Display Name | Custom Category | Built-In Policy Name/ID | Built-In Policy Display Name | Built-In Category | Notes |
| :---------------------: | :-----------------------------: | :-------------: | :---------------------: | :--------------------------: | :---------------: | :---: |
| Deny-PublicEndpoint-Aks | Public network access on AKS API should be disabled | Kubernetes | 040732e8-d947-40b8-95d6-854c95024bf8 | Azure Kubernetes Service Private Clusters should be enabled | Kubernetes | |
| Deny-PublicEndpoint-CosmosDB | Public network access should be disabled for CosmosDB | SQL | 797b37f7-06b8-444c-b1ad-fc62867f335a | Azure Cosmos DB should disable public network access | Cosmos DB | |
| Deny-PublicEndpoint-KeyVault | Public network access should be disabled for KeyVault | Key Vault | 55615ac9-af46-4a59-874e-391cc3dfb490 | [Preview]: Azure Key Vault should disable public network access | Key Vault | |
| Deny-PublicEndpoint-MySQL | Public network access should be disabled for MySQL | SQL | c9299215-ae47-4f50-9c54-8a392f68a052 | Public network access should be disabled for MySQL flexible servers | SQL | |
| Deny-PublicEndpoint-PostgreSql | Public network access should be disabled for PostgreSql | SQL | 5e1de0e3-42cb-4ebc-a86d-61d0c619ca48 | Public network access should be disabled for PostgreSQL flexible servers | SQL | |
| Deny-PublicEndpoint-Sql | Public network access on Azure SQL Database should be disabled | SQL | 1b8ca024-1d5c-4dec-8995-b1a932b41780 | Public network access on Azure SQL Database should be disabled | SQL | |
| Deny-PublicEndpoint-Storage | Public network access onStorage accounts should be disabled | Storage | 34c877ad-507e-4c82-993e-3452a6e0ad3c | Storage accounts should restrict network access | Storage | |
| Deploy-Diagnostics-AKS | Deploy Diagnostic Settings for Kubernetes Service to Log Analytics workspace | Monitoring | 6c66c325-74c8-42fd-a286-a74b0e2939d | Deploy - Configure diagnostic settings for Azure Kubernetes Service to Log Analytics workspace | Kubernetes | |
| Deploy-Diagnostics-Batch | Deploy Diagnostic Settings for Batch to Log Analytics workspace | Monitoring | c84e5349-db6d-4769-805e-e14037dab9b5 | Deploy Diagnostic Settings for Batch Account to Log Analytics workspace | Monitoring | |
| Deploy-Diagnostics-DataLakeStore | Deploy Diagnostic Settings for Azure Data Lake Store to Log Analytics workspace | Monitoring | d56a5a7c-72d7-42bc-8ceb-3baf4c0eae03 | Deploy Diagnostic Settings for Data Lake Analytics to Log Analytics workspace | Monitoring | |
| Deploy-Diagnostics-EventHub | Deploy Diagnostic Settings for Event Hubs to Log Analytics workspace | Monitoring | 1f6e93e8-6b31-41b1-83f6-36e449a42579 | Deploy Diagnostic Settings for Data Lake Analytics to Log Analytics workspace | Monitoring | |
| Deploy-Diagnostics-KeyVault | Deploy Diagnostic Settings for Key Vault to Log Analytics workspace | Monitoring | bef3f64c-5290-43b7-85b0-9b254eef4c47 | Deploy Diagnostic Settings for Key Vault to Log Analytics workspace | Monitoring | |
| Deploy-Diagnostics-LogicAppsWF | Deploy Diagnostic Settings for Logic Apps Workflow runtime to Log Analytics workspace | Monitoring | b889a06c-ec72-4b03-910a-cb169ee18721 | Deploy Diagnostic Settings for Logic Apps to Log Analytics workspace | Monitoring | ~~This is currently not assigned as per [#691](https://github.com/Azure/Enterprise-Scale/issues/691)~~ |
| Deploy-Diagnostics-RecoveryVault | Deploy Diagnostic Settings for Recovery Services vaults to Log Analytics workspace | Monitoring | c717fb0c-d118-4c43-ab3d-ece30ac81fb3 | Deploy Diagnostic Settings for Recovery Services Vault to Log Analytics workspace for resource specific categories | Backup | |
| Deploy-Diagnostics-SearchServices | Deploy Diagnostic Settings for Search Services to Log Analytics workspace | Monitoring | 08ba64b8-738f-4918-9686-730d2ed79c7d | Deploy Diagnostic Settings for Search Services to Log Analytics workspace | Monitoring | |
| Deploy-Diagnostics-ServiceBus | Deploy Diagnostic Settings for Service Bus namespaces to Log Analytics workspace | Monitoring | 04d53d87-841c-4f23-8a5b-21564380b55e | Deploy Diagnostic Settings for Service Bus to Log Analytics workspace | Monitoring | |
| Deploy-Diagnostics-SQLDBs | Deploy Diagnostic Settings for SQL Databases  to Log Analytics workspace | Monitoring | b79fa14e-238a-4c2d-b376-442ce508fc84 | Deploy - Configure diagnostic settings for SQL Databases to Log Analytics workspace | SQL | |
| Deploy-Diagnostics-StreamAnalytics | Deploy Diagnostic Settings for Stream Analytics to Log Analytics workspace | Monitoring | 237e0f7e-b0e8-4ec4-ad46-8c12cb66d673 | Deploy Diagnostic Settings for Stream Analytics to Log Analytics workspace | Monitoring | |
| Deploy-DNSZoneGroup-For-Blob-PrivateEndpoint | Deploy DNS Zone Group for Storage-Blob Private Endpoint | Network | TBC | TBC | TBC | This policy is still rolling out to the Built-In Definitions at this time. We'll be here very soon! |
| Deploy-DNSZoneGroup-For-File-PrivateEndpoint | Deploy DNS Zone Group for Storage-File Private Endpoint | Network | TBC | TBC | TBC | This policy is still rolling out to the Built-In Definitions at this time. We'll be here very soon! |
| Deploy-DNSZoneGroup-For-KeyVault-PrivateEndpoint | Deploy DNS Zone Group for Key Vault Private Endpoint | Network | ac673a9a-f77d-4846-b2d8-a57f8e1c01d4 | [Preview]: Configure Azure Key Vaults to use private DNS zones | Key Vault |
| Deploy-DNSZoneGroup-For-Queue-PrivateEndpoint | Deploy DNS Zone Group for Storage-Queue Private Endpoint | Network | TBC | TBC | TBC | This policy is still rolling out to the Built-In Definitions at this time. We'll be here very soon! |
| Deploy-DNSZoneGroup-For-Sql-PrivateEndpoint | Deploy DNS  Zone Group for SQL Private Endpoint | Network | TBC | TBC | TBC | This policy is still rolling out to the Built-In Definitions at this time. We'll be here very soon! |
| Deploy-DNSZoneGroup-For-Table-PrivateEndpoint | Deploy DNS  Zone Group for Storage-Table Private Endpoint | Network | TBC | TBC | TBC | This policy is still rolling out to the Built-In Definitions at this time. We'll be here very soon! |
| Deploy-LA-Config | Deploy the configurations to the Log Analytics in the subscription | Monitoring | ***Policy Removed*** | ***Policy Removed*** | TBC | This policy has been removed as it is handled as a resource deployment in the ARM templates, portal experience and Terraform module. |
| Deploy-Log-Analytics | Deploy the Log Analytics in the subscription | Monitoring | 8e3e61b3-0b32-22d5-4edf-55f87fdb5955 | Configure Log Analytics workspace and automation account to centralize logs and monitoring | Monitoring | |

**Policy Initiatives Updates**

| Custom ESLZ Policy Name | Custom ESLZ Policy Display Name | Custom Category | New Policy Name/ID | New Policy Display Name | New Category | Notes |
| :---------------------: | :-----------------------------: | :-------------: | :---------------------: | :--------------------------: | :---------------: | :---: |
| Deploy-Diag-LogAnalytics | Deploy Diagnostic Settings to Azure Services | N/A | Deploy-Diagnostics-LogAnalytics | Deploy Diagnostic Settings to Azure Services | Monitoring | Moved to using a mix of Built-In (as above) and custom policy definitions |
| Deny-PublicEndpoints | Public network access should be disabled for PAAS services | Network | Deny-PublicPaaSEndpoints | Public network access should be disabled for PaaS services | N/A | Moved to using Built-In policy definitions only (as above) |
| ***New Policy*** | ***New Policy*** | N/A | Deploy-Private-DNS-Zones | Configure Azure PaaS services to use private DNS zones | Network | |

- Moved several of the diagnostics Policies to built-in, and updating the diagnostics Initiative 
  - This means there's a new resource name as update of existing one is not be allowed due to removal of parameters
- Added Policy Initiative for enforcing Private DNS Zone Association with Private Link (using built-in)
- Added Policy Initiative for denying Public Endpoints (using built-in)
- Updated description and display name for all Policy Assignments

#### Other

*No updates, yet.*

### June 2021

#### Docs

- ["What's New?"](./Whats-new) page created
- Azure DDoS Standard design considerations and recommendations added to CAF docs ([Virtual WAN](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/virtual-wan-network-topology) & [Hub & Spoke](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/traditional-azure-networking-topology)) - closing issue [#603](https://github.com/Azure/Enterprise-Scale/issues/603)
- [Connectivity to other cloud providers](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/connectivity-to-other-providers) CAF document released
- [Testing approach for enterprise-scale](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/enterprise-scale/testing-approach) CAF document released
- Updated [pricing section](https://github.com/Azure/Enterprise-Scale/wiki/What-is-Enterprise-Scale#pricing) on "What is Enterprise Scale" wiki page to provide further clarity.
- Updated [DNS for on-premises and Azure resources](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/dns-for-on-premises-and-azure-resources) - related to issue [#609](https://github.com/Azure/Enterprise-Scale/issues/609)
- Update [Hub & Spoke](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/traditional-azure-networking-topology) guidance related to BGP propagation on UDRs for transit connectivity - to close issue [#618](https://github.com/Azure/Enterprise-Scale/issues/618)
- Added guidance to [Management group and subscription organization - CAF Docs](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/enterprise-scale/management-group-and-subscription-organization#configure-subscription-tenant-transfer-restrictions) for [Azure Subscription Policies](https://docs.microsoft.com/azure/cost-management-billing/manage/manage-azure-subscription-policy), which allow you to control Azure Subscription Tenant transfers to/from your AAD Tenant.

#### Tooling

- [AzOps release v1.2.0](https://github.com/Azure/AzOps/releases/tag/1.2.0)
- [Terraform Module for Cloud Adoption Framework Enterprise-scale release v0.3.3](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/releases/tag/v0.3.3)

#### Policy

- Updated `Deny-Subnet-Without-UDR` policy, to v1.1.0, to allow exclusion of subnets like the `AzureBastionSubnet` - closing issue [#604](https://github.com/Azure/Enterprise-Scale/issues/604)
  - Also updated [ESLZ-Policies.md](https://github.com/Azure/Enterprise-Scale/blob/main/docs/ESLZ-Policies.md) with changes
- Updated `Deny-Subnet-Without-Nsg` policy, to v1.1.0, to allow exclusion of subnets like the `GatewaySubnet`, `AzureFirewallSubnet` and `AzureFirewallManagementSubnet` - closing issue [#456](https://github.com/Azure/Enterprise-Scale/issues/456)
  - Also updated [ESLZ-Policies.md](https://github.com/Azure/Enterprise-Scale/blob/main/docs/ESLZ-Policies.md) with changes
- Updated `Deny-VNet-Peering` and `Deny-VNET-Peer-Cross-Sub` policies `mode` to `All` from `Indexed`. - closing issue [#583](https://github.com/Azure/Enterprise-Scale/issues/583)
  - Also updated [ESLZ-Policies.md](https://github.com/Azure/Enterprise-Scale/blob/main/docs/ESLZ-Policies.md) with changes

#### Other

- Contoso Reference Implementation Update - Virtual WAN Hub default CIDR changed from `/16` to `/23` - closing issue [#440](https://github.com/Azure/Enterprise-Scale/issues/440)
