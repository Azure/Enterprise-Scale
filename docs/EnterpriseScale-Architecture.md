
# Enterprise-Scale Architecture

The principle challenges facing enterprise customers adopting Azure are 1) how to allow applications (legacy or modern) to seamlessly move at their own pace, and 2) how to provide secure and streamlined operations, management, and governance across the entire platform and all encompassed applications. To address these challenges, customers require a forward looking and Azure-native design approach, which in the context of this playbook is represented by the Enterprise-Scale architecture.

## What is the Enterprise-Scale Architecture

The Enterprise-Scale architecture represents the strategic design path and target technical state for the customer's Azure environment. It will continue to evolve in lockstep with the Azure platform and is ultimately defined by the various design decisions the customer organization must make to define their Azure journey.

It is important to highlight that not all enterprises adopt Azure in the same way, and as a result the Enterprise-Scale architecture may vary between customers. Ultimately, the technical considerations and design recommendations presented within this playbook may yield different trade-offs based on the customer scenario. Some variation is therefore expected, but provided core recommendations are followed, the resultant target architecture will position the customer on a path to sustainable scale.

## Landing Zones Definition

Within the context of the Enterprise-Scale architecture, a "Landing Zone" is a logical construct capturing everything that must be true to enable application migrations and development at an Enterprise-Scale in Azure. It considers all platform Resources that are required to support the customer's application portfolio and does not differentiate between IaaS or PaaS.

Every large enterprise software estate will encompass a myriad of application archetypes and each Landing Zone essentially represents the common elements, such as networking and IAM, that are shared across instances of these archetypes and must be in place to ensure that migrating applications have access to requisite components when deployed. Each Landing Zone must consequently be designed and deployed in accordance with the requirements of archetypes within the customer's application portfolio.

The principle purpose of the "Landing Zones" is therefore to ensure that when an application lands on Azure, the required "plumbing" is already in place, providing greater agility and compliance with enterprise security and governance requirements.

---
_Using an analogy, this is similar to how city utilities such as water, gas, and electricity are accessible before new houses are constructed. In this context, the network, IAM, policies, management, and monitoring are shared 'utility' services that must be readily available to help streamline the application migration process._
***

# Design Principles

The Enterprise-Scale architecture is based on the [five design principles](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/design-principles). These principles serve as a compass for subsequent design decisions across critical technical domains. Readers and users of the reference implementation are strongly advised to familiarize themselves with these principles to better understand their impact and the trade-offs associated with non-adherence.

* [Subscription democratization](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/design-principles?branch#subscription-democratization)
* [Policy-driven governance](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/design-principles#policy-driven-governance)
* [Single control and management plane](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/design-principles#single-control-and-management-plane)
* [Application-centric and archetype-neutral](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/design-principles?#application-centric-and-archetype-neutral)
* [Aligning Azure-native design and road maps](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/design-principles#aligning-azure-native-design-and-road-maps)

# Design Guidelines

At the centre of the Enterprise-Scale architecture lies a critical design path, comprised of fundamental design topics with heavily interrelated and dependent design decisions. This repository provides design guidance across these architecturally significant technical domains to support the critical design decisions which must occur to define the Enterprise-Scale architecture. For each of the considered domains, readers should review provided considerations and recommendations, using them to structure and drive designs within each area.

## Critical Design Areas

The [eight critical design areas](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/design-guidelines#critical-design-areas) are intended to support the translation of customer requirements to Azure constructs and capabilities, to address the mismatch between on-premises infrastructure and cloud-design which typically creates dissonance and friction with respect to the Enterprise-Scale definition and Azure adoption.

The impact of decisions made within these critical areas will reverberate across the Enterprise-Scale architecture and influence other decisions. Readers and reference implementation users are strongly advised to familiarize themselves with these eight areas, to better understand the consequences of encompassed decisions, which may later produce trade-offs within related areas.

* [Enterprise enrollment and Azure AD Tenants](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/enterprise-enrollment-and-azure-ad-tenants)
* [Identity and access management](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/identity-and-access-management)
* [Management Group and Subscription organization](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/management-group-and-subscription-organization)
* [Network topology and connectivity](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/network-topology-and-connectivity)
* [Management and monitoring](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/management-and-monitoring)
* [Business continuity and disaster recovery](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/business-continuity-and-disaster-recovery)
* [Security, governance and compliance](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/security-governance-and-compliance)
* [Platform automation and DevOps](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/platform-automation-and-devops)
