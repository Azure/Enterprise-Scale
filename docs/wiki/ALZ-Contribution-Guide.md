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

Whilst each reference implementation is uniquely characterized by its target community, they all aim to deliver against the Azure landing zone [conceptual architecture](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/#azure-landing-zone-conceptual-architecture), [design principles](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-principles) and [design areas](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-areas).

The following is a set of general guidelines for contributing to any of these reference implementations.

## How do we manage contributions

Contributions to each Azure landing zone reference implementation option is moderated by a common committee of maintainers.
The committee is responsible for reviewing and approving all contributions, whether via [**GitHub Issues**](https://github.com/Azure/Enterprise-Scale/issues), [**Pull Requests**](https://github.com/Azure/Enterprise-Scale/pulls), or internally driven development.

The committee is also responsible for reviewing and sponsoring new features or design changes to ensure they meet the needs of our broad community of consumers.

The intent of this approach is to ensures that each reference implementation continues to deliver against the Azure landing zone [conceptual architecture](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/#azure-landing-zone-conceptual-architecture), [design principles](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-principles) and [design areas](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-areas).
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
All we ask is that you follow some simple guidelines, including participating according to our [**code of conduct**](https://github.com/Azure/Enterprise-Scale/blob/main/CODE_OF_CONDUCT.md).

### Reporting bugs

Like all software solutions, the Azure landing zone reference implementation isn't free from bugs.
Moreover, as the Azure platform evolves or our guidance changes there will likely be a need to make updates.

If you believe you have found a bug, please use the following process:

1. Check the [**FAQ**](./FAQ) and [**Known Issues**](https://github.com/Azure/Enterprise-Scale/blob/main/docs/wiki/ALZ-Known-Issues) for a list of common questions and issues.
1. Check existing [**GitHub Issues**](https://github.com/Azure/Enterprise-Scale/issues) to see whether the issue has already been reported.
    1. If the issue is **open**, add a comment rather than create a new one.
    1. If the issue is **closed**, check whether the proposed fix resolves your issue.
1. Report it via our [**GitHub Issues**](https://github.com/Azure/Enterprise-Scale/issues).
1. Select `New issue` and use the `Bug report 🐛` template
1. Ensure you fill out the template with as much information as possible, being sure to cover off what's needed for maintainers and the community to:
    1. Understand your issue :memo:
    1. Reproduce the behavior :computer:
    1. Provide evidence :mag_right:
    1. Optionally, let us know if you would like to contribute a fix via a [**Pull Request**](https://github.com/Azure/Enterprise-Scale/pulls) :wrench:

### Feature requests

We understand that our solutions are going to always be a work in progress, and that customers will need and want to request new features.
This is where you can really make a difference to how the solution is shaped for our community.

If you have an idea you would like to be considered for inclusion, please use the following process:

1. Familiarize yourself with our [conceptual architecture](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/#azure-landing-zone-conceptual-architecture), [design principles](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-principles) and [design areas](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-areas) to ensure the feature aligns with the Azure landing zone guidance.
1. Check existing [**GitHub Issues**](https://github.com/Azure/Enterprise-Scale/issues) to see whether the issue has already been reported.
    1. If the issue is **open**, add a comment rather than create a new one.
    1. If the issue is **closed**, check whether the proposed fix resolves your issue.
1. Report it via our [**GitHub Issues**](https://github.com/Azure/Enterprise-Scale/issues)
1. Select `New issue` and use the `Feature request 🚀` template
1. Ensure you fill out the template with as much information as possible, being sure to cover off what's needed for maintainers and the community to:
    1. Understand your feature and how it aligns to our [conceptual architecture](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/#azure-landing-zone-conceptual-architecture), [design principles](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-principles) and [design areas](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-areas) :memo:
    1. Optionally, let us know if you would like to contribute by adding your requested feature via a [**Pull Request**](https://github.com/Azure/Enterprise-Scale/pulls) :wrench:

> **IMPORTANT:** If you are proposing a change to any of the Azure landing zone guidance, please include a business case explaining why you feel this will benefit our community.

### Report a security vulnerability

Please see our [**security policy**](https://github.com/Azure/Enterprise-Scale/security/policy) for more information.

### Working with ALZ Custom policies

Policies in the Azure Landing Zone reference implementations and repository are custom to Azure environments. They are definitions which are recommended when working with ALZ landing zones. The policies used in the reference implementations are mastered from the Enterprise-Scale repository.

To work with policies, they are located in [src/resources/Microsoft.Authorization/*](https://github.com/Azure/Enterprise-Scale/blob/main/src/resources/Microsoft.Authorization).

To create a new policy, it is worth taking the framework from an already existing policy.

#### Naming convention

In ALZ Custom there is a way to name the custom policies that are used. They are prefixed with one of the following: `Append`, `Audit`, `Deny` or `Deploy`

##### **Append**

When contributing a custom policy based on appending resources at scale, the correct prefix would be `Append` - such as `Append-AppService-httpsonly.json`.

##### **Audit**

Auditing resources at scale via policy is achievable using the correct effect inside the definition. This policy contribution should be prefixed with `Audit` - example, `Audit-MachineLearning-PrivateEndpointId.json`. 

##### **Deny**

Deny policies are used to prevent the creation/action of and on Azure resources. Policies being created and contributed should be prefixed with 'Deny' - example, `Deny-Databricks-Sku.json`.

##### **Deploy**

Deploy follows the DeployIfNotExists (DINE) methodology. Policy contribution should be named prefixed with `Deploy` - example, `Deploy-Custom-Route-Table.json`.

The naming convention should be formatted in the following manner: `{prefix}-{resourceType}-{targetSetting}.json`.  In an example: `Deny-SqlMi-minTLS.json`.

> When creating the naming convention for the definition, it must comply with the [Naming rule and restrictions for Azure resources | Microsoft Authorization](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftauthorization) standard.

Once the `Name` in the file name and `Name` in the policy definition have been set, it is worth noting that they should not be changed as it can impact initiatives and assignments, with the exception of breaking policy changes.

#### Breaking changes

Breaking changes are changes to the policy definition which will adversely impact a policy assignment. This can be a change to the `Name` of the policy definition, or changes to the number of parameters, for example. If this is required, it is recommended to create a new policy definition and deprecate the old one.

In order to implement a breaking change, the following steps should be followed:

- Deprecate the existing policy following our [deprecation guidance](./ALZ-Policies#preview-and-deprecated-policies).
- Create the new policy definition with the breaking change, but append the policy filename and policy `Name` with the date the new policy is created formatted as `_YYYYMMDD`. The underscore is important.
  - Example: add date to the end of the policy name: `deny-subnet-nsg_20230701`.
- Add metadata property to the new policy definition with `replacesPolicy` and the name of the policy being deprecated.
  - Example: `"replacesPolicy": "deny-subnet-nsg"`
- Update initiatives and assignments to use the new policy definition.
- Update the [ALZ Deprecated Services](./wiki/ALZ-Deprecated-Services) with the policy deprecation, replacement policy and justification.

Example snippet from a new policy:

```json
  "name": "Deploy-Sql-vulnerabilityAssessments_20230706",
  "type": "Microsoft.Authorization/policyDefinitions",
  "apiVersion": "2021-06-01",
  "scope": null,
  "properties": {
    "policyType": "Custom",
    "mode": "Indexed",
    "displayName": "Deploy SQL Database Vulnerability Assessments",
    "description": "Deploy SQL Database Vulnerability Assessments when it does not exist in the deployment, and save results to the storage account specified in the parameters.",
    "metadata": {
      "version": "1.0.0",
      "category": "SQL",
      "source": "https://github.com/Azure/Enterprise-Scale/",
      "replacesPolicy": "Deploy-Sql-vulnerabilityAssessments",
      "alzCloudEnvironments": [
        "AzureCloud",
        "AzureChinaCloud",
        "AzureUSGovernment"
      ]
    }
```

#### Metadata and `policies.json`

Inside of the JSON is a `metadata` section which is required for policy creation.

![Policy Metadata](media/policy-metadata-example.png)

| Metadata Value       | Description                                                |
|----------------------|------------------------------------------------------------|
| Version              | Version of the policy definition                           |
| Category             | The category which the policy definition will reside in    |
| Source               | The source repository for the policy definition            |
| alzCloudEnvironments | The cloud environment for which the policy is designed for |

The definition created then needs to be included in the [policies.bicep](https://github.com/Azure/Enterprise-Scale/blob/main/src/templates/policies.bicep) file inside of [src/templates/](https://github.com/Azure/Enterprise-Scale/blob/main/src/templates/) under the correct context. An additional line needs to be created under the respective variable in the file, depending on it being a policy definition or a policy set definition:

![Policies bicep file example 1](media/policies-bicep-example.png)

For a policy definition, additional code should be added inside of the `loadPolicyDefinitions` variable under the correct environment:

`loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Name-Of-The-Policy.json')`

For a policy set definition, additional code should be added inside of the `loadPolicySetDefinitions` variable under the correct environment:

`loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deploy-Sql-Security.json')`

The policy definition files will be compiled into a `policies.json` file from the `policy.bicep` file which was amended.

Once the policy work has been completed, a pull request should be submitted to the repository:

![pr-example](media/pr-example.png) 

#### Versioning

Policy versioning follows the same protocol as built-in policies. More information on that can be found in the [ALZ Policies document in the wiki](./ALZ-Policies#versioning).

#### Deprecation

For policy deprecation, the process is documented in the [Azure Landing Zones - Deprecating Policies](./ALZ-Deprecated-Services) page.

If a policy is part of an initiative, references to policies that are being deprecated should be removed. Policy initiatives are located in the [policySetDefinitions](https://github.com/Azure/Enterprise-Scale/blob/main/src/resources/Microsoft.Authorization/policySetDefinitions/) folder. To find out if a policy is part of an initiative it is recommended to look up the policy definition in [AzAdvertizer](http://azadvertizer.com/) and check for association with initiatives. When identified, go into the necessary initiative and remove references to the definition. Locate the policy definition in the parameters of the initiative and remove reference:

![Example policy def in initiative](media/example-def-in-init.png)

Also find it in the policyDefinitions and remove reference as well:

![Example policy def in initiative 2](media/example-def-in-init-2.png)

#### Escaping policy functions

When working within the policy files, to read parameters which are set at the top level of the policy definition a double escape is needed for ARM. So instead of using `[parameters('someParameter')]` within the policy, you should use `[[parameters('someParameter')]` instead.

> **Note:** When testing the policy manually in the portal or another deployment outside of the ALZ Accelerator (Portal), you will need to remove the double escaping, `[[`, and revert to normal ,`[`'

#### Testing

A new requirement as of FY24-Q1 for all new custom policies is that new policies (with DENY effect at this time) MUST have a Pester test to validate the policy is working as expected. This is to validate that the policy is effective and to prevent any regressions in the future should there be any policy updates. The Pester test should be located in the `/tests/policy` folder in this repo, and should be named the same as the policy definition, but with a `.Tests.ps1` extension. For example, if the policy definition is `Deny-AppService-PrivateEndpoint.json`, the Pester test should be named `Deny-AppService-PrivateEndpoint.Tests.ps1`.

There are many examples available already in the `/tests/policy` for the current list of DENY policies. The preferred and recommended approach is to use PowerShell Az as far as possible, however, there are some situations where REST API will be required (e.g., Deny-MgmtPorts-From-Internet with complex rules or any deployment requiring parameters not available in PowerShell Az modules). Examples of both methods are also available in the current policy test folder - an example that uses both methods [Deny-FileServices-InsecureAuth.Tests.ps1](/tests/policy/Deny-FileServices-InsecureAuth.Tests.ps1).\

We have also included a [sample workflow](./ALZ-Policies-Test-Workflow-Sample) that can be used as a dedicated policy testing workflow in your own environments.

To learn more about how we've implemented policy testing, please refer to [azure-policy-testing](https://github.com/fawohlsc/azure-policy-testing).

#### Default assignments

When working with policies that are assigned by default, these are located under the [eslzArm/managementGroupTemplates/policyAssignments](https://github.com/Azure/Enterprise-Scale/blob/main/eslzArm/managementGroupTemplates/policyAssignments) folder. References to policy definitions are done through the assignments, so if any amendments are done to default assigned policies, they should be amended here too. A wiki to default assignments can be found [in the wiki](./ALZ-Policies).

Policies in `eslzArm.json` file will also need updating if wanting to assign a new policy that is located. The file for this amendment [in eslzArm/eslzArm.json](https://github.com/Azure/Enterprise-Scale/blob/main/eslzArm/eslzArm.json).

### Portal Reference Implementation

The portal reference implementation is a popular UI driven reference implementation for Azure landing zones, and is maintained as part of this repository. It is a great way to get started with Azure landing zones, and is a great way to learn about the underlying Azure landing zone guidance.

When creating new policies that will be assigned by default by the portal reference architecture you are required to also include appropriate information and options in the portal experience (`eslzArm/eslz-portal.json`). Please do include appropriate selectors in line with the section (management group) that the policy is assigned to, and ensure that tooltips include links to the [AzAdvertizer](http://azadvertizer.com/) page for the policy or initiative.

Example for the Key Vault initiative (note the tooltip):

![Example of adding tooltip in portal experience](media/alz-contrib-portal1.png)


### Forking the repository and submitting a Pull Request

To start contributing to this repository it is worth reviewing the developer workflow for contribution [which is documented in GitHub](https://docs.github.com/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork).

## Code of Conduct

We are working hard to build strong and productive collaboration with our passionate community. We heard you loud and clear. Follow the [Code of Conduct](https://github.com/Azure/Enterprise-Scale/blob/main/CODE_OF_CONDUCT.md).
