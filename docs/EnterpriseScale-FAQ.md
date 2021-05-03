## FAQ

This page will list frequently asked question for Enterprise-Scale reference implementations
### What does "Landing Zone" map to in Azure in the context of Enterprise-Scale?

From Enterprise-Scale point of view, Subscription is the "Landing Zone" in Azure.
### Why do Enterprise-Scale ARM templates require permission at Tenant root '/' scope?

Management Group creation, Subscription creation, and Subscription placement into Management Groups are Tenant level PUT API and hence it is pre-requisite to grant permission at root scope to use example templates, which will handle end-2-end Resource composition and orchestration.

### Enterprise-Scale deployment UX do not display all subscriptions in subscription picker drop down list

When deploying Enterprise-Scale, the UX is populateing the list of subscriptions to bring in for deployment of the platform subscriptions (management, connectivity, identity), as well as the landing zones (corp and online). When there are 50+ subscriptions, API do not enumerate all subscription in the subscription picker UI. As a workaround, perform the following steps:

1) Go through the portal experience to select all the options that should be on and select any visible subscription as a placeholder to view all options (some options have dependency on a subscription being selected before they are visible). 
2) Once done, go back to the ‘basics’ page, and click ‘edit parameters’
3) Change the value for the specific *subscriptionId parameters per the subscription Id’s the customer want to bring
4) Click Save
5) Click Review + create, and submit the deployment

### Can we take the ARM templates for ESLZ and check them into our repository and deploy it from there, instead of via the Azure Portal?

All ARM templates for the Entperrise-Scale reference implementations are developed for - and optimized for a curated deployment experience in the Azure portal.
We do not recommend nor support customization of these templates, as they are rather complex given the options we provide, which also leads to a lot of logical operators and conditions in the expressions we are using. Further, as they are optimized for portal deployment and to setup the entire Azure tenant with platform and landing zones, there's a lot of sequencing that are happening across the various ARM scopes (management groups, subscriptions, and resource groups). Taking the same templates for day 2 and day N operations will require you to re-deploy the entire tenant for minor changes.

### How long does it take to deploy Enterprise-Scale?

Depending on the reference implementation and which options you enable, it vary from 30 minutes, to 5 minutes.
Example: deploying Adventure Works with all options enabled, including connecvitity with zonal deployment of VPN and ER Gateways, with corp connected (peered) landing zones can take 40 minutes.
Deploying Adventure Works without connectivity will take 5 minutes.

### What's the recommendaiton to get Enterprise-Scale into my repository so I can operationalize the Azure platform post deployment?

We recommend integrating with AzOps (GitHub Actions) during deployment to get your CI/CD pipeline bootstrapped. This will give you all the ARM templates represented at their respective scopes (management group, subscription, resource group) in Git.
For more information, see the following [link](https://github.com/Azure/Enterprise-Scale/wiki/Deploying-Enterprise-Scale#platform-devops-and-automation)