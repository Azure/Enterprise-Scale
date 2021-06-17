## In this Section

- [In this Section](#in-this-section)
- [Updates](#updates)
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

### June 2021

#### Docs

- ["What's New?"](./Whats-new) page created
- Azure DDoS Standard design considerations and recommendations added to CAF docs ([Virtual WAN](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/virtual-wan-network-topology) & [Hub & Spoke](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/traditional-azure-networking-topology)) - closing issue [#603](https://github.com/Azure/Enterprise-Scale/issues/603)
- [Connectivity to other cloud providers](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/connectivity-to-other-providers) CAF document released
- [Testing approach for enterprise-scale](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/enterprise-scale/testing-approach) CAF document released
- Updated [pricing section](https://github.com/Azure/Enterprise-Scale/wiki/What-is-Enterprise-Scale#pricing) on "What is Enterprise Scale" wiki page to provide further clarity.

#### Tooling

- [AzOps release v1.2.0](https://github.com/Azure/AzOps/releases/tag/1.2.0)
- [Terraform Module for Cloud Adoption Framework Enterprise-scale release v0.3.3](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/releases/tag/v0.3.3)

#### Other

- Contoso Reference Implementation Update - Virtual WAN Hub default CIDR changed from `/16` to `/23` - closing issue [#440](https://github.com/Azure/Enterprise-Scale/issues/440)
