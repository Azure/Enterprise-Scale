# Deploy Enterprise-Scale Reference implementation in your own environment

This section will guide you through the process of deploying Enterprise-Scale reference implementation in your own environment.

## What is Enterprise-Scale Reference Implementation?

Enterprise-Scale design principles and implementation can be adopted by all customers no matter what size and history their Azure estate. The following customer reference implementations target different and most common customer scenarios for a Enterprise-Scale adoption.

## Deploy Reference Implementation

| Reference implementation | Description | ARM Template | Link |
|:-------------------------|:-------------|:-------------|------|
| Contoso | On-premises connectivity using Azure vWAN |[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Fcontoso%2FarmTemplates%2Fes-vwan.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Fcontoso%2FarmTemplates%2Fes-portal.json) | [Detailed description](./reference/contoso/Readme.md) |
| AdventureWorks | On-premises connectivity with Hub & Spoke  |[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Fadventureworks%2FarmTemplates%2Fes-hubspoke.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Fadventureworks%2FarmTemplates%2Fes-portal.json) | [Detailed description](./reference/adventureworks/README.md) |
| WingTip | Azure without hybrid connectivity |[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Fwingtip%2FarmTemplates%2Fes-foundation.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Fwingtip%2FarmTemplates%2Fes-portal.json) | [Detailed description](./reference/wingtip/README.md) |
| Trey Research | For small Enterprises | [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fes-lite.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fdocs%2Freference%2Ftreyresearch%2FarmTemplates%2Fportal-es-lite.json) | [Detailed description](./reference/treyresearch/README.md) |


Enterprise-Scale reference implementation is rooted in the principle that **Everything in Azure is a Resource**. All reference customers scenarios leverage native **Azure Resource Manager (ARM)** to describe and manage their resources as part of their target state architecture at-scale.

Reference implementations enables security, monitoring, networking, and any other plumbing needed for landing zones (i.e. Subscriptions) autonomously through policy enforcement. Companies will deploy the Azure environment with ARM templates to create the necessary structure for management and networking to declare a desired goal state. All scenarios will apply the principle of "Policy Driven Governance" for landing zones using policy. The core benefits of a policy-driven approach are manyfold but the most significant ones are:

1. Platform can provide an orchestration capability to bring target Resources (in this case a subscription) to a desired goal state.

2. Continuous conformance to ensure all platform-level Resources are compliant. Because the platform is aware of the goal state, the platform can assist with the monitoring and remediation of Resources throughout their life-cycle.

3. Platform enables autonomy regardless of the customer's scale point.

To know and learn more about ARM templates used for above reference implementation, please follow [this](./Deploy/es-schema.md) article.
