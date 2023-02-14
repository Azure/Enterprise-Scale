# Create Landing Zone(s)

It is now time to turn the lights ON :bulb:

At this point you have the necessary platform setup configured to support one or many Landing Zone(s) with the required definitions (Roles, Policies and PolicySet) and assignments (Roles and Policies).

Provisioning Landing Zone(s) will mean either **creating a new subscription** or **moving an existing subscription** to the desired Management Group and the platform will do the rest. In large environments with 10s and 100s of Landing Zones, the platform team can also delegate Landing Zone(s) to the respective business units and/or application portfolio owners while being confident that security, compliance and monitoring requirements are being met. Furthermore, the platform team may also delegate the necessary access permissions such as:

1) IAM roles to create new subscriptions
2) Place subscriptions in the appropriate Management Groups for business units and/or application portfolio owners to provide self-service access to create their own Landing Zone(s).

## Create or move a Subscription under the Landing Zone Management Group

Depending upon the reference implementation that's deployed, navigate to the appropriate Management Group under the "Landing Zones" Management Group and create or move an existing subscription. This can be done via the Azure Portal or PowerShell/CLI.

Business units and/or application portfolio owners can use their preferred tool chain - ARM, PowerShell, Terraform, Portal, CLI etc. for subsequent resource deployments within their respective Landing Zone(s).

### Create new subscriptions into the **Landing zones** > **Corp** or **Online** Management Group

1. In the Azure portal, navigate to Subscriptions
2. Click 'Add', and complete the required steps in order to create a new subscription.
3. When the subscription has been created, go to Management Groups and move the subscription into the **Landing zones** > **Corp** or **Online** Management Group
4. Assign RBAC permissions for the application team/user(s) who will be deploying resources in to the newly created subscription

### Move existing subscriptions into the **Landing zones** > **Corp** or **Online** Management Group

1. In the Azure portal, navigate to Management Groups
2. Locate the subscription you want to move, and move it in to the **Landing zones** > **Corp** or **Online** Management Group
3. Assign RBAC permissions for the application team/user(s) who will be deploying resources in to the subscription

## Create Enterprise-Scale Landing Zones using the Azure Portal

The following deployment experiences can be leveraged to create multiple landing zones (subscriptions) and target individual Management Groups (e.g., 'online', 'corp' etc.).

To use the ARM templates below to create new subscriptions, you must have Management Group Contributor or Owner permissions on the Management Group where you will invoke the deployment and also on the targeted Management Groups for the new subscriptions, as well as subscription write permissions on the billing account.

| Agreement types | ARM Template | Description
|:-------------------------|:-------------|:--------------|
| Enterprise Agreement (EA) |[![Deploy To Azure](https://learn.microsoft.com/azure/templates/media/deploy-to-azure.svg)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Flzs%2FarmTemplates%2Feslz.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Flzs%2FarmTemplates%2Fportal-eslz.json) | Create 'N' number of subscriptions into multiple Management Groups
| Enterprise Agreement (EA) |[![Deploy To Azure](https://learn.microsoft.com/azure/templates/media/deploy-to-azure.svg)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fexamples%2Flanding-zones%2Fsubscription-with-rbac%2FsubscriptionWithRbac.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fexamples%2Flanding-zones%2Fsubscription-with-rbac%2Fportal-subscriptionWithRbac.json)| Create a subscription with RBAC for SPN
