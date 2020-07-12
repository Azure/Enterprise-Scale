
# Contents

This article describes how to deploy Landing Zones under the respective Management Group scope.

# Create Landing Zones

In a Enterprise-Scale implementation, all platform Resources in the __Connectivity__ and __Management__ Subscriptions are deployed via Azure Policy. Enterprise-Scale includes both, policy definitions and assignments required to deploy the necessary Resources for the reference implementation. While it is possible to deploy both, Azure Policy definition and assignments using Enterprise-Scale deployment process via GitHub Actions as described in this [article](./deploy-new-policy-assignment.md), Enterprise-Scale provides flexibility for how the assignments can be done in the platform Subscriptions.

All platform Azure Resources in a Landing Zones following the Enterprise-Scale guidance are fully controlled and provisioned through Azure Policy. More information on the [Policy Driven Approach](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/design-principles) can be found in the Enterprise-Scale design principles section of this document.

Before continuing, please ensure that you have completed all prerequisites in the previous sections. Specially these steps:

1. Ensure the default management structure exist for example as described in the [Contoso reference implementation](../reference/contoso/Readme.md).
2. Ensure you have [setup Git](setup-github.md).
3. All the platform infrastructure has been deployed.

---

## Create a Landing Zone

It is now time to turn the lights ON, there is only one step required!

1. Create or move a Subscription under the Landing Zone Management Group.
   Once all the required definitions (Roles, Policies and PolicySet) and assignments (Roles and Policies) are deployed, Subscriptions can be created or moved to the Landing Zones Management Group or any child Management Group below.

> Important: When moving existing Subscriptions under the Landing Zone Management Group hierarchy, the Subscription and all contained Resources will be updated to match the assigned state of compliance.