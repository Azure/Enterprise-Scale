
## File -> New -> Region

Companies wants to leverage new Azure regions and deploy the workload closer to the user; and, they will be adding new Azure regions as business demand arises. As a part of Enterprise-Scale design principle of policy-driven governance, they will be assigning policies in their environment with a number of regions they would like to use and policies will ensure their Azure Environment is setup correctly:

### Management

All reference customers have decided to use a single Log Analytics workspace. When the first region is enabled, they will deploy Log Analytics workspace in their management subscription. No action will be required when enabling subsequent Azure regions as Azure Policy will ensure all platform logging is routed to the workspace. Azure Policy is extensively used for various management operations. Refer to [How does Azure Policies in Enterprise-scale Landing Zone help?](./azpol.md) to learn more about various management and deployment operations enabled in Enterprise Scale landing zone via Azure Policy .

### Networking

Here customers are taking different architecture designs. The following examples are for the Contoso reference implementation:

A policy will continuously check if a Virtual WAN VHub already exist in "Connectivity" subscription for all enabled regions and create one if it does not. Configure Virtual WAN VHub to secure internet traffic from secured connections (spoke VNets inside Landing Zone) to the internet via Azure Firewall.

For all Azure Virtual WAN VHubs, Policies will ensure that Azure Firewall is deployed and linked to the existing global Azure Firewall Policy as well as the creation of a regional Firewall policy, if needed.


An Azure Policy will also deploy default NSGs and UDRs in Landing Zones and, while NSG will be linked to all subnets, UDR will only be linked to VNet injected PaaS services subnets. The Azure Policy will ensure that the right NSG and UDR rules are configured to allow control plane traffic for VNet injected services to continue to work but only for those Azure PaaS services that have been approved as per the [Service Enablement Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/enterprise-scale/security-governance-and-compliance#whitelist-the-service-framework) described in this document. This is required as, when landing zone VNets get connected to Virtual WAN VHub, they will get the default route (0.0.0.0/0) configured to point to their regional Azure Firewall, hence UDR and NSG rules are required to protect and manage control plane traffic for VNet injected PaaS services (such as SQL MI).

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

1) Create Microsoft Entra Group for Subscriptions access
2) Create Microsoft Entra PIM Entitlement for the scope

# File -> New -> Sandbox

Sandbox Subscriptions are for experiment and validation only. Sandbox Subscriptions will not be allowed connectivity to Production and Policy will prevent the connectivity to on-premises Resources.

## File -> Delete -> Sandbox/Landing Zone

Subscription will be moved to a decommissioned Management Group. Decommissioned Management Group policies will deny creation of new services and a Subscription cancellation request will be sent.
