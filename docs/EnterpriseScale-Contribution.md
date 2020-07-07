
## Contribution Guide

### Enterprise-Scale Committee
The Enterprise-Scale Committee and its members (aka Committee Members) are the primary caretakers of the Enterprise-Scale and AzOps repos including language, design, and reference implementations.

### Current Committee Members

- Uday Pandya @uday31in
- Kristian Nese @krnese
- Victor Arzate @victorar
- Johan Dahlbom @daltondhcp
- Lyon Till @ljtill
- Niels Buit @nielsams
- Hansjoerg Scherer @hjscherer 
- Callum Coffin @CalCof

### Committee Member Responsibilities

Committee Members are responsible for reviewing and approving RFCs proposing new features or design changes.

The initial Enterprise Committee consists of Microsoft employees. It is expected that over time, community will grow and new community members will join Committee Members. Membership is heavily dependent on the level of contribution and expertise: individuals who contribute in meaningful ways to the project will be recognized accordingly.

At any point in time, a Committee Member can nominate a strong community member to join the Committee. Nominations should be submitted in the form of RFCs detailing why that individual is qualified and how they will contribute. After the RFC has been discussed, a unanimous vote will be required for the new Committee Member to be confirmed.

### Contribution scope for Enterprise-Scale

The following is the scope of contributions to this repository:

As the Azure platform evolves and new services and features are validated in production with customers, the design guidelines will be updated in the overall architecture context.

With new Services, Resources, Resource properties and API versions, the implementation guide and reference implementation must be updated as appropriate.
Primarily, the code contribution would be centered on Azure Policy definitions and Azure Policy assignments for for Contoso Implementation.

Submit a pull request for documentation updates using the following template 'placeholder'.

#### How to submit Pull Request to upstream repo

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

#### Writing ARM Templates for reference implementation

First, let's assert that there is no right or wrong way writing ARM templates and parameters files.

ARM is a language and everyone has different "style of writing". Very seldom composition of the template and parameters file are the same amongst group of developers. There is no clear style definition to govern and separate code from the config. In other words, what goes in template Vs. what is in the parameter files. Available guidance on when to use parameters and object as parameters (without any schema) are subject to interpretation and there is no one authoring "style" fits all.

To simplify development and unit testing at-scale with multiple developers contributing, we have adopted to specific style of writing ARM templates by decoupling template from its parameter file completely.

We have opted for minimalist "one template to rule them all" approach. This will externalize all Resource properties as a complex object in parameter file and we can enforce strict schema validation on parameter file based on Resource schema that platform already publishes. This drives clear separation between template and parameters. Parameter file is essentially RESTful representation of the Resource when calling `Get-AzResource` or `az resource show`.

- Template.json

```json
"resources": [{
        "condition": "[bool(equals(variables('resourceType'),'Microsoft.Authorization/policyDefinitions'))]",
        "type": "Microsoft.Authorization/policyDefinitions",
        "name": "[variables('policyDefinitions').name]",
        "apiVersion": "[variables('apiversion')[variables('resourceType')]]",
        "location": "[deployment().location]",
        "properties": "[variables('policyDefinitions').Properties]"
    }],
```

This is generic multi-resource template available [here](https://raw.githubusercontent.com/Azure/AzOps/main/template/template.json) to ensure bug fixes are incorporated with latest API Version.

- Template.parameters.json

```json
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "input": {
            "value": {
                <copy-paste-value-of-powershell/cli-output-here>
            }
        }
    }
}
```

Retrieve Resource definition by calling `Get-AzResource` function and giving resourceID to existing Resource.

```powershell
#Replace resourceId in below command before executing it
Get-AzResource -ResourceId '/providers/Microsoft.Management/managementGroups/contoso/providers/Microsoft.Authorization/policyDefinitions/DINE-Diagnostics-ActivityLog' | ConvertTo-Json -depth 100
```

Following Pros and Cons are considered when making design decision.

- Pros

  - No more writing of ARM templates! The last ARM template is written.
  - Consistent Resource export throughout the lifecycle of the Resource regardless of how the Resource is created and updated - Portal, CLI, PowerShell or 3rd Party tools
  - Easier to detect drift between configuration stored in Git vs what is current configuration – we are essentially comparing two JSON documents.
  - Managing implicit dependencies between simple Resources at client side or server side. Azure doesn't have many circular dependency between Resources and it is possible to workout implicit dependencies based on Resource schema already published. For example, a Virtual Machine might have dependency on Key Vault but Key Vaults do not depend on Virtual Machines.<br>_e.g. PolicyDefinition -> Policy Assignment -> Role Assignment -> Remediation or Virtual Network -> ExpressRoute or KV -> Azure SQL_

- Cons

  - Unable to track template deployments using azure-partner-customer-usage-attribution. This is Not in the scope of Enterprise-Scale.

Again to re-iterate, there is nothing wrong with existing ARM templates used for Resource deployments and there is no expectation to re-write those. Pipeline will continue to honour deployment of those ARM templates and detect configuration drift. However we will not be able to reconcile those templates as platform do not allow exporting deployment template in a way that can facilitate reconciliation. For that reason, any templates submit for PR must conform to ***"what-you-export"*** is ***"what-you-deploy"***.

- Dos
  - Read the next section before submitting PR
- Don'ts
  - Submit PR with template and parameters file to deploy Resources e.g. Key Vault, Log Analytics, Virtual Network without wrapping them inside Policy (Microsoft.Authorization/policyDefinitions).

#### Contributing Policy Definitions, Policy Assignment, Role Definition and Role Assignment for for Contoso Implementation

Once you have parameter file ready for your Resource that conforms to the standards mentioned in above section, please consider the scope at which this Resource should be deployed - Management Group or Subscription (either Connectivity, Management or Identity Subscription). Although pipeline has an ability to deploy template at any of the given 4 scopes - we will not use Resource Group level deployment as a part of Landing Zone template. Minimum bar is Subscription level deployment template wrapped inside policyDefinition.

- Dos
  - If you have Resource to deploy inside Landing Zone, wrap them inside Deploy-If-Not-Exist (DINE) policies and assignment for this should be at Management Group scope.

  - Policy should ideally have existenceScope targeted at Subscription scope if deployment count of Resources inside Landing Zone is exactly one e.g. Virtual Network inside Landing Zone or vHUB for new Azure region
  - All policy definition should ideally be created at the root defined in e2e template.

- Don'ts
  - Submit PR with template and parameters file to deploy Resources e.g. Key Vault.
  - Create your own Management Group hierarchy outside of what is described in e2e Landing Zone

Example:

```json
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "input": {
      "value": {
        "Name": "Tailspin",
        "DisplayName": "Tailspin",
        "ParentId": "/providers/Microsoft.Management/managementGroups/3fc1081d-6105-4e19-b60c-1ec1252cf560",
        "Children": [
          {
            "Id": "/providers/Microsoft.Management/managementGroups/Tailspin-bu1",
            "Name": "Tailspin-bu1",
            "DisplayName": "Tailspin-bu1",
            "properties": {
              "policyAssignments" :[
              ],
              "roleAssignments": [
              ]
            }
          }
        ],
        "properties": {
          "policyDefinitions": [
                <<copy-paste of JSON representation of the Resource>>
          ],
          "policyAssignments" :[
          ],
          "roleDefinitions": [
          ],
          "roleAssignments": [
          ]
        }
      }
    }
  }
}
```

#### Contributing New Azure Policy definitions for reference implementations

To contribute with policy definitions that adheres to the Enterprise-Scale architecture, use the following tools and recommendations:

[Azure Policy extension for Visual Studio](https://docs.microsoft.com/en-us/azure/governance/policy/how-to/extension-for-vscode)

Use this extension to look up policy aliases ad review Resources and policies

#### Explore available Resource properties with associated policy aliases

##### Azure Powershell

```powershell
# List all available providers
Get-AzPolicyAlias -ListAvailable

# Get aliases for a specific Resource provider
(Get-AzPolicyAlias -NamespaceMatch 'Microsoft.Network').aliases.name
```

##### Azure CLI

```cli
# List all available providers
az provider list --query [*].namespace

# Get aliases for a specific Resource provider
az provider show --namespace Microsoft.Network --expand "resourceTypes/aliases" --query "resourceTypes[].aliases[].name"
```

#### Contributing New Azure Policy Assignment

For all policy assignment, the following must be considered:

- Be specific with the intent of the assignment; does it belong to the Platform Subscriptions (i.e. Connectivity, Management and Identity), or to the Management Groups?
- What is the Resource distribution within the Subscriptions?
- What are the regions being used, and are multiple regions allowed/used per Subscription?
- What Resource types are allowed that might/might not impact where the policy is being assigned?
- For multiple policies serving same/similar purpose, can they be bundled into a policy initiative?
- What is the rationale of the policy effect? Should an audit policy be translated to an enforcement instead?
- For deployIfNotExists policies, are you following the principle of least privileges of access for the RBAC definition being used?

### Code of Conduct

We are working hard to build strong and productive collaboration with our passionate community. We heard you loud and clear. We are working on set of principles and guidelines with Do's and Don'ts.
