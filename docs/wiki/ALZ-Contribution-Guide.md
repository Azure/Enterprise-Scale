# Contributing to Azure landing zones (Enterprise-Scale)

Firstly, thank you for taking the time to contribute!

The Azure landing zone reference implementations are designed to help customers accelerate their cloud adoption journey.
By contributing, you can help our community get the best out of these reference implementations.

We actively encourage community contributions as we realize the unique and diverse requirements of our customers can help drive a better outcome for everyone.

## What are the reference implementations

To meet the diverse needs of our community, we offer the following reference implementation options:

- [ALZ ARM portal experience (this repository)](https://github.com/Azure/Enterprise-Scale)
- [ALZ Bicep modules](https://github.com/Azure/ALZ-Bicep)
- [ALZ Terraform module](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale)

Whilst each reference implementation is uniquely characterized by its target community, they all aim to deliver against the Azure landing zone [conceptual architecture](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/#azure-landing-zone-conceptual-architecture), [design principles](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-principles) and [design areas](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-areas).

The following is a set of general guidelines for contributing to any of these reference implementations.

## How do we manage contributions

Contributions to each Azure landing zone reference implementation option is moderated by a common committee of maintainers.
The committee is responsible for reviewing and approving all contributions, whether via **GitHub Issues** [[ARM]](https://github.com/Azure/Enterprise-Scale/issues) [[Bicep]](https://github.com/Azure/ALZ-Bicep/issues) [[Terraform]](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/issues), **Pull Requests** [[ARM]](https://github.com/Azure/Enterprise-Scale/pulls) [[Bicep]](https://github.com/Azure/ALZ-Bicep/pulls) [[Terraform]](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/pulls), or internally driven development.

The committee is also responsible for reviewing and sponsoring new features or design changes to ensure they meet the needs of our broad community of consumers.

The intent of this approach is to ensures that each reference implementation continues to deliver against the Azure landing zone [conceptual architecture](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/#azure-landing-zone-conceptual-architecture), [design principles](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-principles) and [design areas](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-areas).
This also helps us to drive towards consistency across the reference implementation options, where possible.

The committee currently consists of Microsoft employees only.
It is expected that over time, community contributions will grow and new community members will join as committee members.
Membership is heavily dependent on the level of contribution and expertise: individuals who contribute in meaningful ways to the project will be recognized accordingly.

At any point in time, a committee member can nominate a strong community member to join the committee.
Nominations should be submitted in the form of RFCs detailing why that individual is qualified and how they will contribute.
After the RFC has been discussed, a unanimous vote will be required for the new committee member to be confirmed.

## How can I contribute?

As an open source project, the reference implementation works best when it reflects the needs of our community of consumers.
As such, we welcome contributions however big or small.
All we ask is that you follow some simple guidelines, including participating according to our **code of conduct** [[ARM]](https://github.com/Azure/Enterprise-Scale/blob/main/CODE_OF_CONDUCT.md) [[Bicep]](https://github.com/Azure/ALZ-Bicep/blob/main/CODE_OF_CONDUCT.md) [[Terraform]](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/blob/main/CODE_OF_CONDUCT.md).

### Reporting bugs

Like all software solutions, the Azure landing zone reference implementation isn't free from bugs.
Moreover, as the Azure platform evolves or our guidance changes there will likely be a need to make updates.

If you believe you have found a bug, please use the following process:

1. Check the **FAQ** [[ARM]](./FAQ) [[Bicep]](https://github.com/Azure/ALZ-Bicep/wiki/FAQ) [[Terraform]](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Frequently-Asked-Questions) and **Known Issues** [[ARM]](./ALZ-Known-Issues) [[Terraform]](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Troubleshooting)  for a list of common questions and issues.
1. Check existing **GitHub Issues** [[ARM]](https://github.com/Azure/Enterprise-Scale/issues) [[Bicep]](https://github.com/Azure/ALZ-Bicep/issues) [[Terraform]](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/issues) to see whether the issue has already been reported.
    1. If the issue is **open**, add a comment rather than create a new one.
    1. If the issue is **closed**, check whether the proposed fix resolves your issue.
1. Report it via our **GitHub Issues** [[ARM]](https://github.com/Azure/Enterprise-Scale/issues) [[Bicep]](https://github.com/Azure/ALZ-Bicep/issues) [[Terraform]](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/issues)
1. Select `New issue` and use the `Bug report 🐛` template
1. Ensure you fill out the template with as much information as possible, being sure to cover off what's needed for maintainers and the community to:
    1. Understand your issue :memo:
    1. Reproduce the behavior :computer:
    1. Provide evidence :mag_right:
    1. Optionally, let us know if you would like to contribute a fix via a **Pull Request** [[ARM]](https://github.com/Azure/Enterprise-Scale/pulls) [[Bicep]](https://github.com/Azure/ALZ-Bicep/pulls) [[Terraform]](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/pulls) :wrench:

### Feature requests

We understand that our solutions are going to always be a work in progress, and that customers will need and want to request new features.
This is where you can really make a difference to how the solution is shaped for our community.

If you have an idea you would like to be considered for inclusion, please use the following process:

1. Familiarize yourself with our [conceptual architecture](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/#azure-landing-zone-conceptual-architecture), [design principles](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-principles) and [design areas](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-areas) to ensure the feature aligns with the Azure landing zone guidance.
1. Check existing **GitHub Issues** [[ARM]](https://github.com/Azure/Enterprise-Scale/issues) [[Bicep]](https://github.com/Azure/ALZ-Bicep/issues) [[Terraform]](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/issues) to see whether the issue has already been reported.
    1. If the issue is **open**, add a comment rather than create a new one.
    1. If the issue is **closed**, check whether the proposed fix resolves your issue.
1. Report it via our **GitHub Issues** [[ARM]](https://github.com/Azure/Enterprise-Scale/issues) [[Bicep]](https://github.com/Azure/ALZ-Bicep/issues) [[Terraform]](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/issues)
1. Select `New issue` and use the `Feature request 🚀` template
1. Ensure you fill out the template with as much information as possible, being sure to cover off what's needed for maintainers and the community to:
    1. Understand your feature and how it aligns to our [conceptual architecture](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/#azure-landing-zone-conceptual-architecture), [design principles](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-principles) and [design areas](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-areas) :memo:
    1. Optionally, let us know if you would like to contribute by adding your requested feature via a **Pull Request** [[ARM]](https://github.com/Azure/Enterprise-Scale/pulls) [[Bicep]](https://github.com/Azure/ALZ-Bicep/pulls) [[Terraform]](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/pulls) :wrench:

> **IMPORTANT:** If you are proposing a change to any of the Azure landing zone guidance, please include a business case explaining why you feel this will benefit our community.

### Report a security vulnerability

Please see our **security policy** for more information.
[[ARM]](https://github.com/Azure/Enterprise-Scale/security/policy) [[Bicep]](https://github.com/Azure/ALZ-Bicep/security/policy) [[Terraform]](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/security/policy)

### Contribution scope

The following is the scope of contributions to this repository:

As the Azure platform evolves and new services and features are validated in production with customers, the design guidelines will be updated in the overall architecture context.

With new Services, Resources, Resource properties and API versions, the implementation guide and reference implementation must be updated as appropriate.
Primarily, the code contribution would be centered on Azure Policy definitions and Azure Policy assignments for the reference implementation.

Submit a pull request for documentation updates using the following template 'placeholder'.

### How to submit Pull Request to upstream repo

1. Create a new branch based on upstream/main by executing following command

    ```shell
    git checkout -b feature upstream/main
    ```

2. Checkout the file(s) from your working branch that you may want to include in PR

    ```shell
    #substitute file name as appropriate. below example
    git checkout feature: .\.docs\Deploy\Deploy-lz.md
    ```

3. Push your Git branch to your origin

    ```shell
    git push origin -u
    ```

4. Create a pull request from upstream to your remote main

## Code of Conduct

We are working hard to build strong and productive collaboration with our passionate community. We heard you loud and clear. We are working on set of principles and guidelines with Do's and Don'ts.
