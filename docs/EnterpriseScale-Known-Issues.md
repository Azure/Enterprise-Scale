# Reference Implementation - Known Issues

The list below summarizes the known issues currently being worked on by the Enterprise-Scale team.

These have been discovered whilst running the reference implementation, and customers may come across them when implementing Enterprise-Scale to build and operationalize their Azure platform.

Some of these issues may be resolved in future release, while others require input from specific Azure product teams.

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
