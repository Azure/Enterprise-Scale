## Enterprise-Scale deployment with Azure VWAN network topology

This section will describe how to deploy an Enterprise-Scale Landing Zones platform with connectivity to on-premises datacenters and branch offices based on an Azure Virtual WAN (VWAN) network topology. Please refer to [Contoso reference implementation](https://github.com/Azure/Enterprise-Scale/tree/main/docs/reference/contoso/Readme.md) for further details on this reference architecture.

## 1. Pre-requisites

To provision your Enterprise-Scale Landing Zones environment with the deployment experience in the Azure portal, your user/service principal must have Owner permission at the Azure Active Directory Tenant root. See the following [instructions](./Deploying-Enterprise-Scale-Pre-requisites) on how to grant access before you proceed.

### Optional pre-requsites

The deployment experience in Azure portal allows you to bring in existing (preferably empty) subscriptions dedicated for platform management, connectivity and identity. It also allows you to bring existing subscriptions that can be used as the initial landing zones for your applications.

To learn how to create new subscriptions using Azure portal, please visit this [link](https://azure.microsoft.com/en-us/blog/create-enterprise-subscription-experience-in-azure-portal-public-preview/).

To learn how to create new subscriptions programmatically, please visit this [link](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/programmatically-create-subscription).

## 2. Launch the Enterprise-Scale Landing Zones deployment experience

In the *Deploying Enterprise-Scale Architecture in your own environment* [article](https://github.com/Azure/Enterprise-Scale#deploying-enterprise-scale-architecture-in-your-own-environment), when you click on *Deploy to Azure* for the selected Enterprise-Scale reference implementation, it will start the deployment experience in the Azure portal into your default Azure tenant. In case you have access to multiple tenants, ensure you are selecting the right one.

Enterprise-Scale can be deployed both from the Azure portal directly, or from [GitHub](https://github.com/Azure/Enterprise-Scale#deploying-enterprise-scale-architecture-in-your-own-environment)

![Graphical user interface, text, application  Description automatically generated](./media/clip_image004.jpg)

## 3. Deployment location

On the first page, select the *Region*. This region will primarily be used to place the deployment resources in an Azure region, but also used as the initial region for some of the resources that are deployed, such as Azure Log Analytics and Azure automation.

![Graphical user interface, text, application, email  Description automatically generated](./media/clip_image010.jpg)

## 4. Enterprise-Scale core setup

Provide a prefix that will be used to create the management group hierarchy and platform resources, and select if you would use dedicated subscriptions or a single subscription for platform resources (please note that dedicates subscriptions are recommended). For this scenario, select **Dedicated**.

![ESLZ-Company-Prefix](./media/ESLZ-Company-Prefix.JPG)

## 5. Platform management, security, and governance

On the *Platform management, security, and governance* blade, you will configure the core components to enable platform monitoring and security. The options you enable will also be enforced using Azure Policy to ensure resources, landing zones, and more are continuously compliant as your deployments scales and grows. To enable this, you must provide a dedicated (empty) subscription that will be used to host the requisite infrastructure.

![Graphical user interface, text, application  Description automatically generated](./media/clip_image014.jpg)

Please note that if you enable the "Deploy Azure Security Center and enable security monitoring for your platform and resources" option, you will need to provide an email address to get email notifications from Azure Security Center.

![Azure Security Center Email Contact](./media/clip_image014asc.jpg)

## 6. Platform DevOps and Automation

Enterprise-Scale Landing Zones provides an integrated CICD pipeline via [AzOps](https://github.com/Azure/AzOps) that can be used with GitHub Actions. For detailed steps for setting up this configuration, refer to the [Deploy Enterprise-Scale Landing Zones Platform DevOps and Automation](./Deploying-Enterprise-Scale-Platform-DevOps) article.

## 7. Network topology and connectivity
On the *Network topology and connectivity* blade, you will configure the core networking platform resources, such as hub virtual network, gateways (VPN and/or ExpressRoute), Azure Firewall, DDoS Protection Standard and Azure Private DNS Zones for Azure PaaS services. To deploy and configure these network resources, you must select a network topology. For this scenario:

* Select "Virtual WAN (Microsoft managed)") as the network topology
* Provide a dedicated (empty) subscription that will be used to host the requisite networking infrastructure.
* Provide the address space to be assigned to the vWAN hub
* Select an Azure region where the first vWAN hub will be created

Depending on your requirements, you may choose to deploy additional network infrastructure for your Enterprise-Scale landing zones platform. The optional resources include:

* DDoS Protection Standard
* VPN and ExpressRoute Gateways
  * If you choose to deploy either or both of these gateways, you will have the option to select the scale unit based on your requirements
* Azure Firewall
  * If you choose to deploy Azure Firewall, you will have the option to select the Firewall SKU (Standard or Premium) as well as indicate if you want to enable DNS Proxy in Azure Firewall. It is recommended to choose the Azure Firewall [Premium](https://docs.microsoft.com/azure/firewall/premium-features) SKU if your organization requires next generation firewall capabilities such as TLS inspection or network intrusion detection and prevention system (IDPS).

![vwan](https://user-images.githubusercontent.com/79409563/136395890-e4d04751-49f1-4c65-8278-f109f6a2d578.JPG)

## 8. Identity
On the *Identity* blade you can specify if you want to assign recommended policies to govern identity and domain controllers. If you decide to enable this feature, you do need to provide an empty subscription for this. You can then select which policies you want to get assigned, and you will need to provide the address space for the virtual network that will be deployed on this subscription. Please note that this virtual network will be connected to the hub virtual network via VNet peering. 

 ![img](./media/clip_image036c.png)

## 9. Landing zone configuration

You can optionally bring in N number of subscriptions that will be bootstrapped as landing zones, governed by Azure Policy. You indicate which subscriptions will be bootstrapped as landing zones with a virtual network deployed and connected to the hub virtual network for corp connectivity. Virtual networks on these subscriptions will be connected to the hub virtual network using VNet peering, and if you deployed and enabled Azure Firewall as DNS proxy, DNS settings on these VNets will be configured with the Azure Firewall private IP address.

You can also indicate which subscriptions you would like to be bootstrapped as landing zones but without corp connectivity. Finally, you can select which policy you want to assign broadly to all of your landing zones.

As part of the policies that you can assign to your landing zones, the Enterprise-Scale Landing Zones deployment experience will allow you to protect your landing zones with a DDoS Standard plan, and for corp connected landing zones, you will have the option to prevent usage of public endpoints for Azure PaaS services as well as ensure that private endpoints to Azure PaaS services are integrated with Azure Private DNS Zones. 

![Graphical user interface, application  Description automatically generated](./media/clip_image037.jpg)

## 10. Review + create

*Review + Create* page will validate your permission and configuration before you can click deploy. Once it has been validated successfully, you can click *Create*

![Graphical user interface, text, application, email  Description automatically generated](./media/clip_image039.jpg)

## 11. Post deployment activities

Once Enterprise-Scale has deployed, you can grant your application teams/business units access to their respective landing zones. Whenever there’s a need for a new landing zone, you can place them into their respective management groups (Online or Corp) given the characteristics of assumed workloads and their requirements.
