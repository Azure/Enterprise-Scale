## FAQ

This page will list frequently asked question for Enterprise-scale design as well as Contoso Implementation.

### Enterprise-scale Design

**What does "Landing Zone" map to in Azure in the context of Enterprise-Scale?**

From Enterprise-Scale point of view, Subscription is the "Landing Zone" in Azure.

### Reference implementation

**Why do Enterprise-Scale ARM templates require permission at Tenant root '/' scope?**

Management Group creation, Subscription creation, and Subscription placement into Management Groups are Tenant level PUT API and hence it is pre-requisite to grant permission at root scope to use example templates, which will handle end-2-end Resource composition and orchestration.

**Portal deployment do not display all subscriptions in subscription picker drop down list**

When deploying ESLZ how, Portal Deployment populates the list of subscriptions to bring in for deployment of the platform subscriptions (management, connectivity, identity). When there are 50+ subscriptions, API do not enumerate all subscription in the subscription picker UI. To continue with portal based deployment:

1) Go through the portal experience to select all the options that should be on and select any visible subscription as a placeholder to view all options (some options have dependency on a subscription being selected before they are visible). 
2) Once done, go back to the ‘basics’ page, and click ‘edit parameters’
3) Change the value for the specific *subscriptionId parameters per the subscription Id’s the customer want to bring
4) Click Save
5) Click Review + create, and submit the deployment
