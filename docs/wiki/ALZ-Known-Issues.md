# Reference Implementation - Known Issues

The list below summarizes the known issues currently being worked on by the Enterprise-Scale team.

These have been discovered whilst running the reference implementation, and customers may come across them when implementing Enterprise-Scale to build and operationalize their Azure platform.

Some of these issues may be resolved in future release, while others require input from specific Azure product teams.

## Deploying Automation Account with CMK controls enabled

### Area

Automation Account

### Issue

There is a very rare scenario, that if you have enabled the Customer Managed Key initiative and you run a redeployment of ALZ through the portal accelerator (including Log Analytics) you will get a policy compliance failure:

```
"Azure Automation accounts should use customer-managed keys to encrypt data at rest"
```
This is due to the additional requirements needed to enable CMK for Automation Accounts, and have it fully configured.

### Status

As a workaround to avoid this scenario, create an exemption on the intiative [Enforce-Encryption-CMK](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Encryption-CMK.html), and if you want to maximize granularity, only exempt the specific policy: [Azure Automation accounts should use customer-managed keys to encrypt data at rest](https://www.azadvertizer.net/azpolicyadvertizer/56a5ee18-2ae6-4810-86f7-18e39ce5629b.html) - Policy ID 56a5ee18-2ae6-4810-86f7-18e39ce5629b

## Deploying the reference implementation fails due to 'Policy <name> cannot be found (404)'

### Area
ARM backend storage

### Issue
When deploying to a region that is paired (e.g., EastUS, which is paired with WestUS), resources deployed in deployment 1 who's referenced in deployment 2 may fail due to replication latency in ARM backend storage. This will cause the overall deployment to fail

### Status
While this is being fixed, it is recommended to re-run the deployment of the reference implementation with the same input parameter, and the deployment should succeed.

## Unsupported number of Tenants in context: x TenantID(s)

### Issue
We currently do not support Initialization across multiple Tenants. <br>Clear your AzContext and run `Connect-AzAccount` with the service principal that was created earlier.

### Status
No fix as of yet.
