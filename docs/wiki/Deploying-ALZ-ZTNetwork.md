## Azure landing zone portal accelerator deployment with Zero Trust network principles

This section will describe how to deploy the Azure landing zone portal accelerator with Zero Trust Principles. For more information on Zero Trust security model and principles visit [Embrace proactive security with Zero Trust](https://www.microsoft.com/security/business/zero-trust). Let's review the Zero Trust aligned networking configurations in the Azure landing zone portal accelerator.

## Deploy networking topology

Hub and spoke is the best option for Zero Trust ...

## Enable DDoS Protection Standard

## Deploy Azure Firewall Premium

## Ensure the Selected Defaults


## 1. Pre-requisites

To provision your Azure environment with the deployment experience in the Azure portal, your user/service principal must have Owner permission at the Azure Active Directory Tenant root. See the following [instructions](./Deploying-Enterprise-Scale-Pre-requisites) on how to grant access before you proceed.

### Optional pre-requsites

The deployment experience in Azure portal allows you to bring in existing (preferably empty) subscriptions dedicated for platform management, connectivity and identity. It also allows you to bring existing subscriptions that can be used as the initial landing zones for your applications.

To learn how to create new subscriptions using Azure portal, please visit this [link](https://azure.microsoft.com/en-us/blog/create-enterprise-subscription-experience-in-azure-portal-public-preview/).

To learn how to create new subscriptions programmatically, please visit this [link](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/programmatically-create-subscription).

## 2. Launch the Azure landing zone portal accelerator deployment experience

In the *Deploying Azure landing zone Architecture in your own environment* [article](https://github.com/Azure/Enterprise-Scale#deploying-enterprise-scale-architecture-in-your-own-environment), when you click on *Deploy to Azure* for the selected Azure landing zone reference implementation, it will start the deployment experience in the Azure portal into your default Azure tenant. In case you have access to multiple tenants, ensure you are selecting the right one.

Azure landing zone portal accelerator can be deployed both from the Azure portal directly, or from [GitHub](https://github.com/Azure/Enterprise-Scale#deploying-enterprise-scale-architecture-in-your-own-environment)

![Graphical user interface, text, application  Description automatically generated](./media/clip_image004.jpg)

## 3. Deployment settings

On the first page, select the *cloud environment*. This should default to the correct Azure Cloud, *only* change this if you believe the value to be incorrect. Next, select the Region. This region will primarily be used to place the deployment resources in an Azure region, but also used as the initial region for some of the resources that are deployed, such as Azure Log Analytics and Azure automation. Now proceed to *Azure core setup*.

![Graphical user interface, text, application, email  Description automatically generated](./media/clip_image010.jpg)

## 4. Azure core setup

Provide a prefix that will be used to create the management group hierarchy and platform resources, and or this scenario select **Dedicated** subscriptions for platform resources (please note that dedicates subscriptions are recommended).

![ESLZ-Company-Prefix](./media/ESLZ-Company-Prefix.JPG)

## 5. Platform management, security, and governance

On the *Platform management, security, and governance* blade, you will configure the core components to enable platform monitoring and security. The options you enable will also be enforced using Azure Policy to ensure resources, landing zones, and configuration are continuously compliant as your deployments scales with business demand. To enable this, you must provide a dedicated (empty) subscription that will be used to host the requisite infrastructure.

![Graphical user interface, text, application  Description automatically generated](./media/clip_image014.jpg)

Please note that if you enable the "Deploy Azure Security Center and enable security monitoring for your platform and resources" option, you **must** to provide an email address to get email notifications from Azure Security Center.

![Azure Security Center Email Contact](./media/clip_image014asc.jpg)

## 6. Platform DevOps and Automation

Azure landing zone portal accelerator provides an integrated CICD pipeline via [AzOps](https://github.com/Azure/AzOps) that can be used with GitHub Actions. For detailed steps for setting up this configuration, refer to the [Deploy Platform DevOps and Automation](./Deploying-ALZ-Platform-DevOps) article.


## 7. Network topology and connectivity
On the *Network topology and connectivity* blade, you will configure the core networking platform resources, such as hub virtual network, gateways (VPN and/or ExpressRoute), Azure Firewall, DDoS Network Protection and Azure Private DNS Zones for Azure PaaS services. To deploy and configure these network resources, you must:

* In the Deploy network topology option, select either "Hub and spoke with Azure Firewall" or "Hub and spoke with your own third-party NVA".  For this example, we will select the "Hub and spoke with Azure Firewall".
* Provide a dedicated (empty) subscription that will be used to host the requisite networking infrastructure.
* Provide the address space to be assigned to the hub virtual network
* Select an Azure region where the hub virtual network will be created

 ![img](./media/clip_image036a.png)

Depending on your requirements, you may choose to deploy additional network infrastructure for your Azure landing zones architecture. The optional resources include:

* DDoS Network Protection
* Azure Private DNS Zones for Azure PaaS services
* VPN and ExpressRoute Gateways
  * If you choose to deploy either or both of these gateways, you will have the option to select the subnet to be dedicated for these resources, if you decide to deploy them as regional or zone-redundant gateways, as well as choose the right SKU based on your requirements
* If you choose to deploy Azure Firewall, you will have the option to
  * Select the subnet
  * Select to deploy Azure Firewall as regional or zone redundant (recommended)
  * Select the Firewall SKU (Standard or Premium). It is recommended to choose the Azure Firewall [Premium](https://docs.microsoft.com/azure/firewall/premium-features) SKU if your organization requires next generation firewall capabilities such as TLS inspection or network intrusion detection and prevention system (IDPS).
  * Indicate if you want to enable DNS Proxy in Azure Firewall. 

 ![img](./media/clip_image036b.png)


## 8. Identity
On the *Identity* blade you can specify if you want to assign recommended policies to govern identity and domain controllers. If you decide to enable this feature, you do need to provide an empty subscription for this. You can then select which policies you want to get assigned, and you will need to provide the address space for the virtual network that will be deployed on this subscription. Please note that this virtual network will be connected to the hub virtual network via VNet peering. 

 ![img](./media/clip_image036c.png)

## 9. Landing zone configuration

You can optionally bring in N number of subscriptions that will be bootstrapped as landing zones, governed by Azure Policy. You indicate which subscriptions will be bootstrapped as landing zones with a virtual network deployed and connected to the hub virtual network for corp connectivity. Virtual networks on these subscriptions will be connected to the hub virtual network using VNet peering, and if you deployed and enabled Azure Firewall as DNS proxy, DNS settings on these VNets will be configured with the Azure Firewall private IP address.

You can also indicate which subscriptions you would like to be bootstrapped as landing zones but without corp connectivity. Finally, you can select which policy you want to assign broadly to all of your landing zones.

As part of the policies that you can assign to your landing zones, the Azure landing zone portal accelerator will allow you to protect your landing zones with a DDoS Network Protection plan, and for corp connected landing zones, you will have the option to prevent usage of public endpoints for Azure PaaS services as well as ensure that private endpoints to Azure PaaS services are integrated with Azure Private DNS Zones. 

![Graphical user interface, application  Description automatically generated](./media/clip_image037.jpg)

## 10. Review + create

*Review + Create* page will validate your permission and configuration before you can click deploy. Once it has been validated successfully, you can click *Create*

![Graphical user interface, text, application, email  Description automatically generated](./media/clip_image039.jpg)

## 11. Post deployment activities

Once Azure landing zone portal accelerator has deployed, you can grant your application teams/business units access to their respective landing zones. Whenever there’s a need for a new landing zone, you can place them into their respective management groups (Online or Corp) given the characteristics of assumed workloads and their requirements.
