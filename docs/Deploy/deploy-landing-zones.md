
# Contents

This article describes how to deploy Landing Zones under the respective Management Group scope.

# Create Landing Zones

In a Enterprise-Scale implementation, all platform resources in the __Connectivity__ and __Management__ Subscriptions are deployed via Azure Policy. Enterprise-Scale includes both, policy definitions and assignments required to deploy the necessary resources for the reference implementation. While it is possible to deploy both, Azure Policy definition and assignments using Enterprise-Scale deployment process via GitHub Actions as described in this article, Enterprise-Scale provides flexibility for how the assignments can be done in the platform subscriptions.

All platform Azure resources in a Landing Zones following the Enterprise-Scale guidance are fully controlled and provisioned through Azure Policy. More information on the [Policy Driven Approach](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/design-principles) can be found in the Enterprise-Scale design principals section of this document.

Before continuing, please ensure that you have completed all prerequisites in the previous sections. Specially the below steps:

1. Ensure the default management structure exist for example as described in the [Contoso reference implementation](../reference/contoso/Readme.md)
2. Ensure you have [setup Git](setup-github.md).
3. All the platform infrastructure has been deployed following [these instructions](./Deploy-platform-infra.md).

---

## Create a Landing Zone

It is now time to turn the lights ON, there is only one step required!

1. Create or move a Subscription under the Landing Zone Management Group.
   Once all the required definitions (roles, policies and policySet) and the assignment (roles and policies) are deployed, subscriptions can be created or moved to the Landing Zones management group or any other scope below.

> Important: Existing Subscription and Azure resource in it, will be moved into a compliant state when moved under the Landing Zone scope.
