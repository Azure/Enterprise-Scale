# Reference Implementation - Known Issues

The list below summarizes the known issues currently being worked on by the Enterprise-Scale team.

These have been discovered whilst running the reference implementation, and customers may come across them when implementing Enterprise-Scale to build and operationalize their Azure platform.

Some of these issues may be resolved in future release, while others require input from specific Azure product teams.

##  Management Group API Failures

### Issue
AzOps discovery can fail at random when the API either doesn't respond, or responds with an unexpected result (due to eventual consistency). This can cause tasks such as `Invoke-AzOpsRepository` to fail.

This is likely to surface itself within Enterprise-Scale as a failed `AzOps` or `Auto-AzOps-Pull` GitHub Action, and will surface itself with an error message like the following examples:

#### Example 1
```bash
[YYYY-MM-DD HH:mm:ss.ffff] (Get-AzOpsGitPullRefresh) Invoking repository initialization
Write-AzOpsLog: /action/entrypoint.ps1:73
Line |
  73 |              Write-AzOpsLog -Level Error -Topic "entrypoint" -Message  …
     |              ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | [YYYY-MM-DD HH:mm:ss.ffff] (entrypoint) The property 'Id'
     | cannot be found on this object. Verify that the property
     | exists.
```

#### Example 2
```bash
[YYYY-MM-DD HH:mm:ss.ffff] (Get-AzOpsGitPullRefresh) Invoking repository initialization
Write-AzOpsLog: /action/entrypoint.ps1:73
Line |
  73 |              Write-AzOpsLog -Level Error -Topic "entrypoint" -Message  …
     |              ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | [YYYY-MM-DD HH:mm:ss.ffff] (entrypoint) Cannot validate
     | argument on parameter 'ManagementGroup'. The running command
     | stopped because the preference variable
     | "ErrorActionPreference" or common parameter is set to Stop:
     | The operation was canceled.
```

### Status
Recommended workaround is to re-run the pipeline. This can be triggered via another push or pull request, or manually by selecting "Re-run jobs" from within the failed workflow.

This is under active investigation with the Management Group API product team.

## Subscription Creation

### Area
Microsoft.Subscription Resource Provider

### Issue
At present, it is not possible to provision new Subscription via ARM templates. Subscription creation requires an Enterprise Enrollment account to be migrated to a new billing account API in the backend.

### Status
We are working closely with engineering teams to enable this functionality for the Contoso Tenant. As a workaround, Subscriptions are created using GitHub Actions, having a Service Principal to call the POST API.

## Unable to use policy aliases on Microsoft.Resources/subscriptions

### Area
Microsoft.Subscription Resource Provider

### Issue
As duplicate Subscription names can exist in Azure, the Display Name of a Subscription cannot be used in policy rules. The Subscription ID must be used instead. This makes it hard to navigate through Subscriptions in policy evaluations, and to target the correct Subscription(s).

### Status
To deterministically target the platform Subscriptions with their specific policies, their workaround is to have a dedicated Management Group for each Platform Subscription, child to the platform Management Group

## Management group scoped deployments can deploy to tenant root scope

### Area
Azure Resource Manager template deployments

### Issue
When doing nested deployment from Management Group scope without having the “scope” property specified on "Microsoft.Resources/deployments", ARM defaults to Tenant root and does a Tenant scope deployment.

### Status
No fix as of yet.

## Reference() function not respecting dependency graph [dependsOn]

### Area
Azure Resource Manager template deployments

### Issue
When doing nested deployments from Tenant scope (e.g., policyAssignment and subsequent roleAssignment for the Managed Identity), the reference() function fails saying the policyAssignment cannot be found, even though it exists. A re-deployment works fine.

### Status
No fix as of yet. Workaround is to add a "delayFor" Resource deployment in serial mode with batch size set to 1

## Reference() function runs even though the Resource condition is false

### Area
Azure Resource Manager template deployments

### Issue
When using “conditions” on Resources, and when it evaluates to false, the reference() function within the Resource properties is still executed which causes the deployment to fail.

### Status
No fix as of yet. Workaround is to do N number of additional if() functions to logically navigate (e.g., if reference Resource doesn’t exist, throw json(‘null’).)

## Unsupported number of Tenants in context: x TenantID(s)

### Issue
We currently do not support Initialization across multiple Tenants. <br>Clear your AzContext and run `Connect-AzAccount` with the service principal that was created earlier.

### Status
No fix as of yet.
