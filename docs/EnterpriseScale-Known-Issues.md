
# Reference Implementation - Known Issues

The list below summarizes the known issues with reference implementation, when building and operationalize their Azure platform using first-party platform and product capabilities.

## Subscription and Management Group with duplicate Display Name

Area: AzOps

Issue: At present, if your environment contains Management Group or Subscription with duplicate Display Name, initialization of discovery will fail. This is precautionary check to avoid accidental misconfiguration.

Status: There is work in progress to use Resource name instead of Display Name. There will be runtime configuration option to override this behavior. We highly recommend to have unique Display Name for Management Groups and Subscription.

## Subscription Creation

Area: Microsoft.Subscription Resource Provider

Issue: At present, it is not possible to provision new Subscription via ARM templates. Subscription creation requires an Enterprise Enrollment account to be migrated to a new billing account API in the backend.

Status: We are working closely with engineering teams to enable this functionality for the Contoso Tenant. As a workaround, Subscriptions are created using GitHub Actions, having a Service Principal to call the POST API.

## Unable to use policy aliases on Microsoft.Resources/subscriptions

Area: Microsoft.Subscription Resource Provider

Issue: As duplicate Subscription names can exist in Azure, the Display Name of a Subscription cannot be used in policy rules. The Subscription ID must be used instead. This makes it hard to navigate through Subscriptions in policy evaluations, and to target the correct Subscription(s).

Status: To deterministically target the platform Subscriptions with their specific policies, their workaround is to have a dedicated Management Group for each Platform Subscription, child to the platform Management Group

## Management group scoped deployments can deploy to tenant root scope

Area: Azure Resource Manager template deployments

Issue: When doing nested deployment from Management Group scope without having the “scope” property specified on "Microsoft.Resources/deployments", ARM defaults to Tenant root and does a Tenant scope deployment.

Status: No fix as of yet.

## Reference() function not respecting dependency graph [dependsOn]

Area: Azure Resource Manager template deployments

Issue: When doing nested deployments from Tenant scope (e.g., policyAssignment and subsequent roleAssignment for the Managed Identity), the reference() function fails saying the policyAssignment cannot be found, even though it exists. A re-deployment works fine.

Status: No fix as of yet. Workaround is to add a "delayFor" Resource deployment in serial mode with batch size set to 1

## Reference() function runs even though the Resource condition is false

Area: Azure Resource Manager template deployments

Issue: When using “conditions” on Resources, and when it evaluates to false, the reference() function within the Resource properties is still executed which causes the deployment to fail.

Status: No fix as of yet. Workaround is to do N number of additional if() functions to logically navigate (e.g., if reference Resource doesn’t exist, throw json(‘null’).)

## Unsupported number of Tenants in context: x TenantID(s)

Issue: We currently do not support Initialization across multiple Tenants. <br>Clear your AzContext and run `Connect-AzAccount` with the service principal that was created earlier.

Status: No fix as of yet.

## Subscriptions or Management Group with duplicated names

Issue: The discovery process discussed on [this](./Deploy/discover-environment.md) article will fail if there are Subscriptions or Management Groups with duplicated names. 

Status: There is work planned to override Display Name with ResourceName for __Microsoft.Management/managementGroups__ and __Microsoft.Subscription/subscriptions__. Please ensure Subscription names and Management Groups are unique in your Tenant regardless of the hierarchy prior to running the discovery process.