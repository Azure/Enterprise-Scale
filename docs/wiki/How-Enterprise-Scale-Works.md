## In this Section

- [In this Section](#in-this-section)
- [Enterprise-Scale design principles](#enterprise-scale-design-principles)
  - [:book: Subscription Democratization](#book-subscription-democratization)
  - [:book: Policy Driven Governance](#book-policy-driven-governance)
  - [:book: Single Control and Management Plane](#book-single-control-and-management-plane)
  - [:book: Application Centric and Archetype-neutral](#book-application-centric-and-archetype-neutral)
  - [:book: Azure native design and aligned with platform roadmap](#book-azure-native-design-and-aligned-with-platform-roadmap)
- [Separating platform and landing zones](#separating-platform-and-landing-zones)
- [Platform responsibilities and functions](#platform-responsibilities-and-functions)
- [Landing zone owners responsibilities](#landing-zone-owners-responsibilities)
- [Enterprise-Scale Management Group Structure](#enterprise-scale-management-group-structure)
- [What happens when you deploy Enterprise-Scale?](#what-happens-when-you-deploy-enterprise-scale)

------
This section describes at a high level how Enterprise-Scale reference implementation works. Your landing zones are the output of a multi-subscription environment for all your Azure services, where compliance, guardrails, security, networking, and identity is provided at scale by the platform.

## Enterprise-Scale design principles

The enterprise-scale architecture prescribed in this guidance is based on the design principles described here. These principles serve as a compass for subsequent design decisions across critical technical domains. Familiarize yourself with these principles to better understand their impact and the trade-offs associated with nonadherence.

### :book: Subscription Democratization

Subscriptions should be used as a unit of management and scale aligned with business needs and priorities to support business areas and portfolio owners to accelerate application migrations and new application development. Subscriptions should be provided to business units to support the design, development, and testing and deployment of new workloads and migration of existing workloads.

### :book: Policy Driven Governance

Azure Policy should be used to provide guardrails and ensure continued compliance with your organization's platform, along with the applications deployed onto it. Azure Policy also provides application owners with sufficient freedom and a secure unhindered path to the cloud.

### :book: Single Control and Management Plane

Enterprise-scale architecture shouldn't consider any abstraction layers, such as customer-developed portals or tooling. It should provide a consistent experience for both AppOps (centrally managed operation teams) and DevOps (dedicated application operation teams). Azure provides a unified and consistent control plane across all Azure resources and provisioning channels subject to role-based access and policy-driven controls. Azure can be used to establish a standardized set of policies and controls for governing the entire enterprise application estate in the cloud.

### :book: Application Centric and Archetype-neutral

Enterprise-scale architecture should focus on application-centric migrations and development rather than pure infrastructure lift-and-shift migrations, such as moving virtual machines. It shouldn't differentiate between old and new applications, infrastructure as a service, or platform as a service applications. Ultimately, it should provide a safe and secure foundation for all application types to be deployed onto your Azure platform.

### :book: Azure native design and aligned with platform roadmap

The Enterprise-scale architecture approach advocates using Azure-native platform services and capabilities whenever possible. This approach should align with Azure platform roadmaps to ensure that new capabilities are available within your environments. Azure platform roadmaps should help to inform the migration strategy and enterpriseEnterprise-scale trajectory.

## Separating platform and landing zones

One of the key tenets of Enterprise-Scale is to have a clear separation of the Azure *platform* and the *landing zones*. This allows organizations to scale their Azure architecture alongside with their business requirements, while providing autonomy to their application teams for deploying, migrating and doing net-new development of their workloads into their landing zones. This model fully supports workload autonomy and distinguish between central and federated functions.

## Platform responsibilities and functions

Platform resource are managed by a cross-functional platform team. The team consist mainly out of the following functions. These functions working in close collaboration with the SME functions across the organization:

- **PlatformOps:** Responsible for management and deployment of control plane resource types such as subscriptions, management groups via IaC and the respective CI/CD pipelines. Management of the platform-related identity resources on Microsoft Entra ID and cost management for the platform. Operationalization of the platform for an organization is under the responsibility of the platform function.
- **SecOps:** Responsible for definition and management of Azure Policy and RBAC permissions on the platform for landing zones and platform management groups and subscriptions. Security operations including monitoring and the definition & operation of reporting and auditing dashboard.
- **NetOps:** Definition and management of the common networking components in Azure including the hybrid connectivity and firewall resource to control internet facing networking traffic. NetOps team is responsible to handout virtual networks to landing zone owners or team.

## Landing zone owners responsibilities

Enterprise-scale landing zones support both centralized and federated application DevOps models. The most common model are dedicated **DevOps** teams which are each associated with a single workload. In case of smaller workloads, COTS, or 3rd party applications, a single **AppDevOps** team is responsible for the workload's operation. Independent of the model every DevOps team manages several workload staging environments (DEV, UAT, PROD), deployed to individual landing zones /subscriptions. Each landing zone has a set of RBAC permissions managed with Microsoft Entra PIM provided by the Platform SecOps team.

When the landing zones / subscriptions are handed over to the DevOps team, the team is end-to-end responsible for the workload. They can operate within the security guardrails provided by the platform team independently. If dependencies on central teams or functions are discovered, it is highly recommended to review the process and eliminate these as soon as possible to unblock DevOps teams.

## Enterprise-Scale Management Group Structure

The Management Group structure implemented with Enterprise-Scale is as follows:

- **Top-level Management Group** (directly under the tenant root group) is created with a prefix provided by the organization, which purposely will avoid the usage of the root group to allow organizations to move existing Azure subscriptions into the hierarchy, and also enables future scenarios. This Management Group is parent to all the other Management Groups created by Enterprise-Scale
- **Platform:** This Management Group contains all the *platform* child Management Groups, such as Management, Connectivity, and Identity. Common Azure Policies for the entire platform is assigned at this level

  - **Management:** This Management Group contains the dedicated subscription for management, monitoring, and security, which will host Azure Log Analytics, Azure Automation, and Azure Sentinel. Specific Azure policies are assigned to harden and manage the resources in the management subscription.

  - **Connectivity:** This Management Group contains the dedicated subscription for connectivity, which will host the Azure networking resources required for the platform, such as Azure Virtual WAN/Virtual Network for the hub, Azure Firewall, DNS Private Zones, Express Route circuits, ExpressRoute/VPN Gateways etc. among others. Specific Azure policies are assigned to harden and manage the resources in the connectivity subscription.
  - **Identity:** This Management Group contains the dedicated subscription for identity, which is a placeholder for Windows Server Active Directory Domain Services (AD DS) VMs, or Azure Active Directory Domain Services to enable AuthN/AuthZ for workloads within the landing zones. Specific Azure policies are assigned to harden and manage the resources in the identity subscription.

- **Landing Zones:** This is the parent Management Group for all the landing zone subscriptions and will have workload-agnostic Azure Policies assigned to ensure workloads are secure and compliant.

  - **Online:** This is the dedicated Management Group for Online landing zones, meaning workloads that may require direct internet inbound/outbound connectivity or also for workloads that may not require a VNet.
  - **Corp:** This is the dedicated Management Group for Corp landing zones, meaning workloads that requires connectivity/hybrid connectivity with the corporate network thru the hub in the connectivity subscription.

- **Sandboxes:** This is the dedicated Management Group for subscriptions that will solely be used for testing and exploration by an organization’s application teams. These subscriptions will be securely disconnected from the Corp and Online landing zones.
- **Decommissioned:** This is the dedicated Management Group for landing zones that are being cancelled, which then will be moved to this Management Group before deleted by Azure after 30-60 days.

## What happens when you deploy Enterprise-Scale?

By default, all recommended settings and resources recommendations are enabled and deployed, and you must explicitly disable them if you don't want them to be deployed and configured. These resources and configurations include:

- A scalable Management Group hierarchy aligned to core platform capabilities, allowing you to operationalize at scale using centrally managed Azure RBAC and Azure Policy where platform and workloads have clear separation.

- Azure Policies that will enable autonomy for the platform and the landing zones. The full list of policies leveraged by Enterprise-Scale, their intent, assignment scope, and life-cycle can be viewed [here](./ALZ-Policies).
- An Azure subscription dedicated for **Management**, which enables core platform capabilities at scale using Azure Policy such as:

  - A Log Analytics workspace and an Automation account
  - Azure Security Center monitoring
  - Azure Security Center (Standard or Free tier)

  - Azure Sentinel
  - Diagnostics settings for Activity Logs, VMs, Management Groups and PaaS resources sent to Log Analytics

- When deploying [**Adventure Works**](./ALZ-Deploy-reference-implementations#deploy-a-reference-implementation) or [**Contoso**](./ALZ-Deploy-reference-implementations#deploy-a-reference-implementation): An Azure subscription dedicated for **Connectivity**, which deploys core Azure networking resources such as:

  - A hub virtual network
  - Azure Firewall

  - ExpressRoute Gateway
  - VPN Gateway
  - Azure Private DNS Zones for Private Link

- (Optionally) An Azure subscription dedicated for **Identity** in case your organization requires to have Active Directory Domain Controllers to provide authorization and authentication for workloads deployed into the landing zones.
- (Optionally) Integrate your Azure environment with GitHub, where you provide the Personal Access Token (PAT) to create a new repository and automatically discover and merge your deployment into Git.

- A Landing Zone Management Group for **Corp**-connected applications that require connectivity to on-premises, to other landing zones or to the internet via shared services provided by the hub virtual network.
  - This is where you will create your subscriptions that will host your corp-connected workloads.

- A Landing Zone Management Group for **Online** applications that will be internet-facing, where a virtual network is optional and hybrid connectivity is not required.
  - This is where you will create your subscriptions that will host your online workloads.

- Landing zone subscriptions for Azure-native, internet-facing **Online** applications and resources.

- Landing zone subscriptions for **Corp**-connected applications and resources, including a virtual network that will be connected to the hub via virtual network peering.
- Azure Policies for online- and corp-connected landing zones, which include:
  - Enforce VM monitoring (Windows & Linux)
  - Enforce VMSS monitoring (Windows & Linux)
  - Enforce Azure Arc VM monitoring (Windows & Linux)
  - Enforce DDoS on Virtual Networks
  - Enforce VM backup (Windows & Linux)
  - Enforce secure access (HTTPS) to storage accounts
  - Enforce auditing for Azure SQL
  - Enforce encryption for Azure SQL
  - Prevent IP forwarding
  - Prevent inbound RDP from internet
  - Ensure subnets are associated with network security groups
  - Ensure subnets are associated with user-defined routes
