# Deploy Enterprise-Scale Reference implementation in your own environment

This section will guide you through the process of deploying an Enterprise-Scale reference implementation in your own environment.

## What is an Enterprise-Scale Reference Implementation?

The Enterprise-Scale design principles and reference implementations can be adopted by all customers no matter what the size or history of their Azure estate. The following reference implementations target the most common customer scenarios for adopting Enterprise-Scale.

## Deploy a Reference Implementation

| Reference implementation | Description | ARM Template | Link |
|:-------------------------|:-------------|:-------------|------|
| Contoso | On-premises connectivity using Azure vWAN |[![Deploy To Azure](https://learn.microsoft.com/azure/templates/media/deploy-to-azure.svg)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2FeslzArm%2FeslzArm.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2FeslzArm%2Feslz-portal.json) | [Detailed description](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/contoso/Readme.md) |
| AdventureWorks | On-premises connectivity with Hub & Spoke  |[![Deploy To Azure](https://learn.microsoft.com/azure/templates/media/deploy-to-azure.svg)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2FeslzArm%2FeslzArm.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2FeslzArm%2Feslz-portal.json) | [Detailed description](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/adventureworks/README.md) |
| WingTip | Azure without hybrid connectivity |[![Deploy To Azure](https://learn.microsoft.com/azure/templates/media/deploy-to-azure.svg)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2FeslzArm%2FeslzArm.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2FeslzArm%2Feslz-portal.json) | [Detailed description](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/wingtip/README.md) |
| Trey Research | For small enterprises | [![Deploy To Azure](https://learn.microsoft.com/azure/templates/media/deploy-to-azure.svg)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fes-lite.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fportal-es-lite.json) | [Detailed description](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/treyresearch/README.md) |

An Enterprise-Scale reference implementation is rooted in the principle that **Everything in Azure is a Resource**. All of the reference scenarios leverage native **Azure Resource Manager (ARM)** to describe and manage their resources as part of their target state architecture at-scale.

Reference implementations enable security, monitoring, networking, and any other plumbing needed for landing zones (i.e. subscriptions) autonomously through policy enforcement. Companies will deploy the Azure environment with ARM templates to create the necessary structure for management and networking to declare a desired goal state. All scenarios will apply the principle of "Policy-Driven Governance" for landing zones by using Azure Policy. The benefits of a policy-driven approach are many but the most significant are:

1. The platform can provide an orchestration capability to bring target resources (in this case a subscription) to a desired goal state.

2. Continuous conformance to ensure all platform-level resources are compliant. Because the platform is aware of the goal state, the platform can assist with the monitoring and remediation of resources throughout their life-cycle.

3. The platform enables autonomy regardless of the customer's scale point.

To know and learn more about ARM templates used for above reference implementation, please follow [this](https://github.com/Azure/Enterprise-Scale/blob/main/docs/Deploy/es-schema.md) article.
