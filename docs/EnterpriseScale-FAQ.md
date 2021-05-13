## FAQ

This page will list frequently asked question for Enterprise-Scale reference implementations.

### What does "Landing Zone" map to in Azure in the context of Enterprise-Scale?

From Enterprise-Scale point of view, subscriptions are the "Landing Zones" in Azure.

### Why do Enterprise-Scale ARM templates require permission at Tenant root '/' scope?

Management Group creation, Subscription creation, and Subscription placement into Management Groups are APIs that operates at the tenant root (/). So in order to create the management group hierarchy, the subscriptions, and organize them accordingly into the management groups, the initial deployment must also be invoked at the tenant root (/) scope.
Once you have deployed Enterprise-Scale, you can remove the Owner permission from the tenant root (/) scope, as you will be Owner at the intermediate root management group that Enterprise-Scale is creating.

### Enterprise-Scale Landing Zones deployment UX do not display all subscriptions in subscription picker drop down list

When deploying Enterprise-Scale, the UX is populateing the list of subscriptions to bring in for deployment of the platform subscriptions (management, connectivity, identity), as well as the landing zones (corp and online). When there are 50+ subscriptions, API do not enumerate all subscription in the subscription picker UI. As a workaround, perform the following steps:

1) Go through the portal experience to select all the options that should be on and select any visible subscription as a placeholder to view all options (some options have dependency on a subscription being selected before they are visible). 
2) Once done, go back to the ‘basics’ page, and click ‘edit parameters’
3) Change the value for the specific *subscriptionId parameters per the subscription Id’s the customer want to bring
4) Click Save
5) Click Review + create, and submit the deployment

### Can we take the ARM templates for Enterprise-Scale reference implementations and check them into our repository and deploy it from there, instead of via the Azure Portal?

All ARM templates for the Enterprise-Scale Landing Zones reference implementations are developed for - and optimized for a curated self-service deployment experience in the Azure portal.
We do not recommend nor support customization of these templates, as they are rather complex given the options we provide, which also leads to a lot of logical operators and conditions in the expressions we are using. Further, as they are optimized for portal deployment and to setup the entire Azure tenant with platform and landing zones, there's a lot of sequencing that are happening across the various ARM scopes (management groups, subscriptions, and resource groups). Taking the same templates for day 2 and day N operations will require you to re-deploy the entire tenant for minor changes, and also require permanent Owner permission on the tenant root (/) scope.

### What if we don't want to deploy using the Azure Portal experience, but prefer to deploy using infrastructure as code?

We provide two options:

* 1st party Enterprise-Scale Landing Zones reference implementation (this repository) leads with the portal experience based on ARM templates, and also enable you to integrate and bootstrap the CI/CD pipeline during the deployment. The outcome of that is that you will have a GitHub repository with GitHub Actions, or Azure DevOps pipeline with *all* the resource deployments organized as composite ARM templates, represented at their respective scopes (management groups, subscriptions, resource groups). See the [Enterprise-Scale Landing Zones User Guide](https://github.com/Azure/Enterprise-Scale/wiki/Deploying-Enterprise-Scale#reference-implementation-deployment) for more information of how this is being done.

* 3rd party Enterprise-Scale Landing Zones [Terraform module](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale#terraform-module-for-cloud-adoption-framework-enterprise-scale), that has parity with 1st party implementation, where you can deploy, manage, and operationalize the Azure platform.

### What if I have already deployed Enterprise-Scale Landing Zones without the CI/CD integration, do I have to start over to have infrastructure as code?

Absolutely not! We acknowledge that infrastructure as code is a journey, and that organizations need to transition/start with IaC when they are ready. At any point in time, you can integrate [AzOps](https://github.com/Azure/AzOps-Accelerator) to your environment, and get the representation of your Azure environment into Git and start using the existing ARM templates, and bring your own ARM templates to ongoing deployment and operations.

### How long does it take to deploy Enterprise-Scale?

Depending on the reference implementation and which options you enable, it vary from 40~ minutes, to 5~ minutes.
Examples:

* Deploying Adventure Works with all options enabled, including connecvitity with zonal deployment of VPN and ER Gateways, with corp connected (peered) landing zones can take 40~ minutes.

* Deploying Adventure Works (also Wingtip) without connectivity will take 5~ minutes.

### Why are there custom policy definitions as part of Enterprise-Scale Landing Zones?

We work with - and learn from our customers and partners, and ensures that we evolve and enhance the reference implementations to meet customer requirements. The primary approach of the policies as part of Entperprise-Scale is to be proactive (deployIfNotExist, and modify), and preventive (deny), and we are continiously moving these policies to built-ins.