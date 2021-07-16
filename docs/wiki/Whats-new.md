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

#### Tooling

*No updates, yet.*

#### Policy

*No updates, yet.*

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
