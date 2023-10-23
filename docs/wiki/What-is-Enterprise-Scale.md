## In this Section

- [In this Section](#in-this-section)
- [What is Enterprise-Scale reference implementation?](#what-is-enterprise-scale-reference-implementation)
- [Pricing](#pricing)
- [What if I already have an existing Azure footprint?](#what-if-i-already-have-an-existing-azure-footprint)

---
Enterprise-Scale architecture provides prescriptive guidance coupled with Azure best practices, and it follows 5 design principles across the 8 critical design areas for organizations to define their target state for their Azure architecture. Enterprise-Scale will continue to evolve alongside the Azure platform roadmap and is ultimately defined by the various design decisions that organizations must make to define their Azure journey.

The Enterprise-Scale architecture is modular by design and allow organizations of any size to start with the foundational landing zones that support their application portfolios, and the architecture enables organizations to start as small as needed and scale alongside their business requirements regardless of scale point.

## What is Enterprise-Scale reference implementation?

The Enterprise-Scale reference implementations support Azure adoption at scale and provides guidance and architecture based on the authoritative design for the Azure platform as a whole.

Enterprise-Scale reference implementations are tying together all the Azure platform primitives and create a proven, well-defined Azure architecture based on a multi-subscription design, leveraging native platform capabilities to ensure organizations can create and operationalize their landing zones in Azure at scale.

The following table outlines key customer requirements in terms of landing zones, and how it is they are being addressed with Enterprise-Scale:

| **Key customer landing zone requirement**                                                                                                                                     | **Enterprise-Scale reference implementations**                                                                                                                                                        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Timelines to reach security and compliance requirements for a workload                                                                                                        | Yes. Enabling all recommendations during setup will ensure resources are compliant from a monitoring and security perspective                                                                         |
| Provides a baseline architecture using multi-subscription design                                                                                                              | Yes. For the entire Azure tenant regardless of customer's scale-point                                                                                                                                 |
| Best-practices from cloud provider                                                                                                                                            | Yes. Proven and validated with customers                                                                                                                                                              |
| Be aligned with cloud provider's platform roadmap                                                                                                                             | Yes.                                                                                                                                                                                                   |
| UI Experience and simplified setup                                                                                                                                            | Yes. Via the Azure portal                                                                                                                                                                             |
| All critical services are present and properly configured according to recommended best practices for identity & access management, governance, security, network, monitoring and logging | Yes. Using a multi-subscription design, aligned with Azure platform roadmap                                                                                                                           |
| Automation capabilities (IaC/DevOps)                                                                                                                                          | Yes. ARM/Bicep, Terraform, Azure Policy, GitHub/Azure DevOps CI/CD pipeline options included                                                                                                                           |
| Provides long-term self-sufficiency                                                                                                                                           | Yes. Enterprise-scale architecture -> 1:N landing zones. Approach & architecture prepare the customer for long-term self-sufficiency. The RIs reference implementations are there to get you started |
| Enables migration velocity across the organization                                                                                                                            | Yes. Enterprise-scale Scale architecture -> 1:N landing zones. Architecture includes designs for segmentation and separation of duty to empower teams to act within appropriate landing zones        |
| Achieves operational excellence                                                                                                                                               | Yes. Enables autonomy for platform and application teams with a policy-driven governance and management                                                                                               |
## Pricing

There’s no cost associated with Enterprise-Scale itself, as it is just an architecture that is constructed using existing Azure products and services. Therefore you only pay for the Azure products and services that you choose to enable, and also the products and services your organization will deploy into the landing zones for your workloads.

For example, you don’t pay for the Management Groups or the Azure Policies that are being assigned, but assigning a policy to enable Azure Defender (previously known as Azure Security Center Standard) on all landing zone subscriptions will generate cost on those subscriptions for the Azure Defender service as detailed [here](https://azure.microsoft.com/pricing/details/azure-defender/).

> As the pricing page for Azure Defender shows, charges only occur when resources that are protected by Azure Defender are deployed into the landing zones. 
>  
> Therefore an empty landing zone or landing zone with resources that are not covered by Azure Defender will incur no costs for the service.

Another example are some of the networking resources that we provide prescriptive deployment guidance for as part on Enterprise-Scale:

- [VPN Gateways](https://azure.microsoft.com/pricing/details/vpn-gateway/)
- [ExpressRoute Gateways & Circuits](https://azure.microsoft.com/pricing/details/expressroute/)
- [Azure Firewalls](https://azure.microsoft.com/pricing/details/azure-firewall/)
- [Virtual WANs](https://azure.microsoft.com/pricing/details/virtual-wan/)
- [DDoS Network Protection](https://azure.microsoft.com/pricing/details/ddos-protection/)

Each of these resources have an associated cost that varies based on how they are deployed, configured and consumed as part of your Enterprise-Scale deployment.

> A difference for the networking resources is that they have costs that are incurred once deployed, as well as how they are consumed, e.g. bandwidth and traffic processed.

Therefore it is important to complete the design process following the Enterprise-Scale [Design Principles](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/enterprise-scale/design-principles) and [Design Guidelines](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/enterprise-scale/design-guidelines) as part of your implementation of Enterprise-Scale. From reading and making design decisions from the guidance provided, you will know all of the Azure resources that are to be deployed/enabled as part of your deployment and with this information you will be able to determine any costs for the associated resources using the [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/).

## What if I already have an existing Azure footprint?

Enterprise-Scale reference implementation will meet you where you are, and the design has catered for existing subscriptions and workloads in Azure.

See the following [article](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/enterprise-scale/transition) to learn more how you can transition into Enterprise-Scale.
