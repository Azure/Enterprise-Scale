## In this Section

- [What is Enterprise-Scale reference implementation?](#what-is-enterprise-scale-reference-implementation)
- [Pricing](#pricing)
- [What if I already have an existing Azure footprint](#what-if-i-already-have-an-existing-azure-footprint)

---
Enterprise-Scale architecture provides prescriptive guidance coupled with Azure best practices, and it follows 5 design principles across the 8 critical design areas for organizations to define their target state for their Azure architecture. Enterprise-Scale will continue to evolve alongside the Azure platform roadmap and is ultimately defined by the various design decisions that organizations must make to define their Azure journey.

The Enterprise-Scale architecture is modular by design and allow organizations of any size to start with the foundational landing zones that support their application portfolios, and the architecture enables organizations to start as small as needed and scale alongside their business requirements regardless of scale point.

## What is Enterprise-Scale reference implementation?

The Enterprise-Scale reference implementations support Azure adoption at scale and provides guidance and architecture based on the authoritative design for the Azure platform as a whole.

Enterprise-Scale reference implementations are tying together all the Azure platform primitives and creates a proven, well-defined Azure architecture based on a multi-subscription design, leveraging native platform capabilities to ensure organizations can create and operationalize their landing zones in Azure at scale.

The following table outlines key customer requirements in terms of landing zones, and how it is they are being addressed with Enterprise-Scale:

| **Key customer landing zone requirement**                    | **Enterprise-Scale reference implementations**               |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| Timelines to reach security and compliance requirements for a workload | Enabling all recommendations during setup, will ensure resources are compliant from a monitoring and security perspective |
| Provides a baseline architecture using multi-subscription design | Yes, for the entire Azure tenant regardless of customer’s scale-point |
| Best-practices from cloud provider                           | Yes, proven and validated with customers                     |
| Be aligned with cloud provider’s platform roadmap            | Yes                                                          |
| UI Experience and simplified setup                           | Yes, Azure portal                                            |
| All critical services are present and properly configured according to recommend best practices for identity & access management, governance, security, network and logging | Yes, using a multi-subscription design, aligned with Azure platform roadmap |
| Automation capabilities (IaC/DevOps)                         | Yes: ARM, Azure Policy, GitHub/Azure DevOps CI/CD pipeline options included |
| Provides long-term self-sufficiency                          | Yes, enterprise-scale architecture -> 1:N landing zones. Approach & architecture prepare the customer for long-term self-sufficiency;, the RIs reference implementations are there to get you started |
| Enables migration velocity across the organization           | Yes, enterpriseEnterprise-scale Scale architecture -> 1:N landing zones., Architecture includes designs for segmentation and separation of duty to empower teams to act within appropriate landing zones |
| Achieves operational excellence                              | Yes. Enables autonomy for platform and application teams with a policy driven governance and management |

## Pricing

There’s no cost associated with Enterprise-Scale, and you only pay for the Azure services that are being enabled, and the services your organization will deploy into the landing zones. For example, you don’t pay for the management groups or the policies that are being assigned, but policy to enable Azure Security Center on the landing zone subscriptions will generate cost on those subscriptions.

## What if I already have an existing Azure footprint?

Enterprise-Scale reference implementation will meet you where you are, and the design has catered for existing subscriptions and workloads in Azure.

See the following [article](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/transition) to learn more how you can transition into Enterprise-Scale.