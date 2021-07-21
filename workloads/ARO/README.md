# Deploy ARO (Azure Red Hat Openshift) into an landing zone

This article provides prescriptive guidance  for deploying Azure Red Hat OpenShift (ARO) clusters in enterprise-scale landing zones environment.

Additionally ARM templates and sample scripts are provided to support a deployment.

## Pre-requsites

Before getting started with this guidance, ensure that:

- Enterprise-scale landing zones has been deployed, either by using the Hub and Spoke or Virtual-WAN reference implementations, or Enterprise-scale landing zones was deployed as per [architectural guidance](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/) in the Cloud Adoption Framework.
- There is at least one landing zone under the corp management group, which is peered to the hub VNet where ARO cluster will be deployed.

Before ARO gets deployed to this landing zone, ensure the following required infrastructure is additionally configured:

### Identity

The following identities are required when installing an ARO cluster following the least-privilege principle:

| Identity | Required privileges | Scope or resource | Description  |
|:---------|:--------------------|:------------------|:--------|
| ARO cluster SPN | Network contributor | LZ VNet | SPN required during ARO installation |
| ARO first party SPN | Network contributor | LZ VNet | Azure Red Hat OpenShift RP SPN |
| User for ARO installation | Contributor | Cluster RG | Azure AD user identity performing the installation |

### Network

| Resource | Description |
|:---------|:--------------------|

