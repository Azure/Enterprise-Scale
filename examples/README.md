# Example ARM templates for Enterprise-scale landing zones

This isn't yet another example ARM template library. This folder contains **only** ARM templates for organizations to deploy platform resources using infrastructure-as-code. 

The following resources are in scope to illustrate how to build and operate the Azure platform:

* Microsoft.Management/managementGroups
* Microsoft.Management/managementGroups/subscriptions
* Microsoft.Subscription/aliases
* Microsoft.Authorization/policyDefinitions
* Microsoft.Authorization/policySetDefinitions
* Microsoft.Authorization/policyAssignments
* Microsoft.Authorization/roleDefinitions
* Microsoft.Authorization/roleAssignments

Further; platform resource in the context of Enterprise-scale are deployed primarily to tenant and management group, and subscription scopes.

How-to documentation to deploy these templates using a platform CI/CD pipeline AzOps:  

- [Deploy your own ARM templates with AzOps GitHub Actions](../docs/Deploy/deploy-new-arm.md)
- [Enable Service Principal to create landing zones](../docs/Deploy/enable-subscription-creation.md)
- [Landing zone creation](./landing-zones)
