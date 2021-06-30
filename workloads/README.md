# ARM templates and Bicep files for compliant workload deployments

At this point you have the necessary platform setup and landing zones (subscriptions) created and placed into their respective management groups, being secure, governed, monitored, and enabled for autonomy and are ready for your application teams to do workload deployments, migrations, and net-new development to their landing zones.

The following workloads outlined here provides best-practices, and curated deployment experiences for your application teams to successfully deploy them into their landing zones (online, corp)

This folder contains ARM templates and Bicep files that are developed and composed to ensure organizations can:

- Accelerate adoption and Azure service enablement for their application teams and business units
- Deploy compliant Azure services aligned with the proactive and preventive policies provided by Enterprise-Scale landing zones, aligned with [Azure Security Benchmark](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/enterprise-scale/security-governance-and-compliance#azure-security-benchmark)

## Who should use this library?

Any organization that have deployed Enterprise-Scale reference implementations, or have followed the architecture and design methodology to enable landing zones in their Azure tenant, can start to use this library to deploy compliant workloads into their landing zones.

We support the following scenarios:

- Create TemplateSpecs of each artifact, that you can share with the application teams via RBAC in your tenant
- Deploy directly to a landing zone from this repository, using Azure PowerShell or Azure CLI
- Fork, extend, and internalize the repository for your own use

See each artifact for further details regarding pre-requisites, such as dependencies on the Azure Platform (e.g., virtual networks with address space are created and provided into the landing zones, and policies are in place to ensure core security logs/metrics are stored centrally)

Note: Regardless of how application teams decide to deploy their workloads, Azure Policy will ensure they conform to the guardrails in place, such as ensuring resources are enabled for security, monitoring, backup, and more.
