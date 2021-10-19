## Enterprise-Scale deployment without hybrid connectivity

This section will describe how to deploy an Enterprise-Scale Landing Zones platform without connectivity to on-premises datacenters and branch offices. Please refer to [WingTip reference implementation](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/wingtip/README.md) for further details on this reference architecture.

## Pre-requisites

To provision your Enterprise-Scale Landing Zones environment with the deployment experience in the Azure portal, your user/service principal must have Owner permission at the Azure Active Directory Tenant root. See the following [instructions](./Deploying-Enterprise-Scale-Pre-requisites) on how to grant access before you proceed.

### Optional pre-requsites

The deployment experience in Azure portal allows you to bring in existing (preferably empty) subscriptions dedicated for platform management. It also allows you to bring existing subscriptions that can be used as the initial landing zones for your applications.

To learn how to create new subscriptions using Azure portal, please visit this [link](https://azure.microsoft.com/en-us/blog/create-enterprise-subscription-experience-in-azure-portal-public-preview/).

To learn how to create new subscriptions programmatically, please visit this [link](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/programmatically-create-subscription).

## Launch Enterprise-Scale Landing Zones deployment experience

In the *Deploying Enterprise-Scale Architecture in your own environment* [article](https://github.com/Azure/Enterprise-Scale#deploying-enterprise-scale-architecture-in-your-own-environment), when you click on *Deploy to Azure* for the selected Enterprise-Scale reference implementation, it will start the deployment experience in the Azure portal into your default Azure tenant. In case you have access to multiple tenants, ensure you are selecting the right one.

Enterprise-Scale can be deployed both from the Azure portal directly, or from [GitHub](https://github.com/Azure/Enterprise-Scale#deploying-enterprise-scale-architecture-in-your-own-environment)

![Graphical user interface, text, application  Description automatically generated](./media/clip_image004.jpg)

## Deployment location

On the first page, select the *Region*. This region will primarily be used to place the deployment resources in an Azure region, but also used as the initial region for some of the resources that are deployed, such as Azure Log Analytics and Azure automation.

![Graphical user interface, text, application, email  Description automatically generated](./media/clip_image010.jpg)

## Enterprise-Scale core setup

Provide a prefix that will be used to create the management group hierarchy and platform resources, and select if you would use dedicated subscriptions or a single subscription for platform resources (please note that dedicates subscriptions are recommended). For this scenario, select **Dedicated**.

![ESLZ-Company-Prefix](./media/ESLZ-Company-Prefix.JPG)

## Platform management, security, and governance

On the *Platform management, security, and governance* blade, you will configure the core components to enable platform monitoring and security. The options you enable will also be enforced using Azure Policy to ensure resources, landing zones, and more are continuously compliant as your deployments scales and grows. To enable this, you must provide a dedicated (empty) subscription that will be used to host the requisite infrastructure.

![Graphical user interface, text, application  Description automatically generated](./media/clip_image014.jpg)

Please note that if you enable the "Deploy Azure Security Center and enable security monitoring for your platform and resources" option, you will need to provide an email address to get email notifications from Azure Security Center.

![Azure Security Center Email Contact](./media/clip_image014asc.jpg)

## Platform DevOps and Automation

Enterprise-Scale Landing Zones provides an integrated CICD pipeline via AzOps that can be used with GitHub Actions. For detailed steps for setting up this configuration, refer to the [Deploy Enterprise-Scale Landing Zones Platform DevOps and Automation](./Deploying-Enterprise-Scale-Platform-DevOps) article.

## Network topology and connectivity
On the *Network topology and connectivity* blade, you can configure the core networking platform resources, such as hub virtual network, gateways (VPN and/or ExpressRoute), Azure Firewall, DDoS Protection Standard and Azure Private DNS Zones for Azure PaaS services. To deploy and configure these network resources, you must select a network topology.

*For this scenario since we don't require network connectivity to on-premises, select "No"*

![Network](https://user-images.githubusercontent.com/79409563/137819649-d1bb97eb-fda7-446a-b9cd-9f447306d3f6.jpg)

## Identity
On the *Identity* blade you can specify if you want to assign recommended policies to govern identity and domain controllers. If you decide to enable this feature, you do need to provide an empty subscription for this. You can then select which policies you want to get assigned, and if you are deploying a network topology in the *Network topology and connectivity* blade, you will need to provide the address space for the virtual network that will be deployed on this subscription. Please note that, if the virtual network is deployed on this subscription, it will be connected to the hub virtual network via VNet peering. 

*For this scenario since we are not deploying a network topology and hybrid connectivity, we will select the "No" option.* 

![Identity](https://user-images.githubusercontent.com/79409563/137819658-2efaed58-14f0-46f6-81f5-ff1e6859e9d3.jpg)

*However, if you are intending to deploy Domain Controllers on this subscription, select the "Yes" option, and indicate which of the recommended policies you would like to be assigned to the Identity management group.*

## Landing zone configuration

You can optionally bring in N number of subscriptions that will be bootstrapped as landing zones, governed by Azure Policy. You can indicate which subscriptions you would like to be bootstrapped as landing zones for corp connectivity and for online only. Please note that as in this scenario we are not deploying a network topology in the *Network topology and connectivity* blade, the corp landing zones will not be connected via VNet peering to a hub virtual network. Finally, you can select which policies you want to assign broadly to all of your landing zones.

![Landingzone](https://user-images.githubusercontent.com/79409563/137821031-d161e83c-b02a-4414-94aa-b237a26bbc2b.jpg)

## Review + create

*Review + Create* page will validate your permission and configuration before you can click deploy. Once it has been validated successfully, you can click *Create*

![Graphical user interface, text, application, email  Description automatically generated](./media/clip_image039.jpg)

## Post deployment activities

Once Enterprise-Scale has been deployed, you can grant your application teams/business units access to their respective landing zones. Whenever there is a need for a new landing zone, you can place them into their respective management groups (Online or Corp) given the characteristics of assumed workloads and their requirements.
