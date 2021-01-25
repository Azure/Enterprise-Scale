# Deploy AKS into an online landing zone

The ARM template provided in this folder can be used to create new AKS clusters into the online landing zones (i.e., no requirement for hybrid connectivity, nor connectivity to corp network).

## Pre-requsites

The user/developer who's deploying this ARM template must be an Owner - or have Microsoft.Authorization/roleAssignments/write permission on landing zone subscription since a managed identity is being created and granted permission to the resources.

## Policy Driven Governance

One of the design principles of Enterprise-Scale is to use Policy Driven Governance to ensure autonomy and a secure, compliant goal state for the Azure platform and the landing zones (subscriptions). When AKS and requisite resources are being deployed, these policies will ensure a compliant, secure, and governed AKS cluster.

## What will be deployed?

By default, all recommendations are enabled and you must explicitly disable them if you don't want it to be deployed and configured.

- A new AKS cluster into a new or existing Resource Group in the online landing zone subscription
- Azure Policies that will enable autonomy for the platform and the landing zones.
- Azure Container Registry
- Kubenet default virtual network components (the cluster will not be able to connect to corp network)
- Container Monitoring enabled by Azure Monitor and Log Analytics. Create a new - or use an existing Log Analytics workspace for application observability. Note that platform related logs should be captured centrally and be enabled via Azure Policy.

| Landing zone | ARM Template |
|:-------------------------|:-------------|
| Online |[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fworkloads%2FAKS%2FarmTemplates%2Fonline-aks.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fworkloads%2FAKS%2FarmTemplates%2Fportal-online-aks.json) | 