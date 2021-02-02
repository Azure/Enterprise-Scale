# Create Landing Zone(s)

It is now time to turn the lights ON :bulb:

At this point you have necessary platform setup and configured to support one or many Landing Zone(s) with required definitions (Roles, Policies and PolicySet) and assignments (Roles and Policies).

Provisioning Landing Zone(s) will mean either **creating new subscription** or **moving existing subscription** to desired management group and platform will do the rest. In large environments with 10s and 100s of Landing Zones, platform team can also delegate Landing Zone(s) to respective business units and/or application portfolio owners while being confident of security, compliance and monitoring. Furthermore, platform team may also delegate necessary access permissions 1) IAM roles to create new subscription and 2) place subscription in the appropriate management groups for business units and/or application portfolio owners to provide self-service access to create their own Landing Zone(s).

## Create or move a Subscription under the Landing Zone Management Group

Depending upon reference implementations deployed, navigate to appropriate management group under "Landing Zones" management group and create or move existing subscription. This can be done via Azure Portal or PowerShell/CLI.

Business units and/or application portfolio owners can use their preferred tool chain - ARM, PowerShell, Terraform, Portal, CLI etc. for subsequent resource deployments within their Landing Zone(s).

### Create new subscriptions into the **Landing zones** > **Corp** or **Online** management group

1. In Azure portal, navigate to Subscriptions
2. Click 'Add', and complete the required steps in order to create a new subscription.
3. When the subscription has been created, go to Management Groups and move the subscription into the **Landing zones** > **Corp** or **Online** management group
4. Assign RBAC permissions for the application team/user(s) who will be deploying resources to the newly created subscription

### Move existing subscriptions into the **Landing zones** > **Corp** or **Online** management group

1. In Azure portal, navigate to Management Groups
2. Locate the subscription you want to move, and move it to the **Landing zones** > **Corp** or **Online** management group
3. Assign RBAC permissions for the application team/user(s) who will be deploying resources to the subscription

## Create Enterprise-Scale landing zones using Azure Portal

The following deployment experiences can be leveraged to create multiple landing zones (subscriptions) and target individual management groups (e.g., 'online', 'corp' etc.).

To deploy the ARM templates below to create new subscriptions, you must have Management Group Contributor or Owner permission on the Management Group where you will invoke the deployment and the targeted Management Groups for the new subscriptions, as well as subscription write permissions on the billing account.

| Agreement types | ARM Template | Description
|:-------------------------|:-------------|:--------------|
| Enterprise Agreement (EA) |[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Flzs%2FarmTemplates%2Feslz.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Flzs%2FarmTemplates%2Fportal-eslz.json) | Create N subscriptions into multiple management groups
| Enterprise Agreement (EA) |[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fexamples%2Flanding-zones%2Fsubscription-with-rbac%2FsubscriptionWithRbac.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fexamples%2Flanding-zones%2Fsubscription-with-rbac%2Fportal-subscriptionWithRbac.json)| Create subscription with RBAC for SPN


