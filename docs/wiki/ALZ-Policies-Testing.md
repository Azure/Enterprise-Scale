# Azure Landing Zone Policy Testing Framework

## Overview

The ALZ Policy Testing Framework is a set of tools and scripts that can be used to test Azure Policies do what is expected and prevent breaking regressions. The framework is designed to be used with pipelines as part of CI/CD processes to test policies as they are developed and integrated to ultimately improve the quality and stability of policies going into production environments.

This framework is based on the work done by @fawohlsc in this repo [azure-policy-testing](https://github.com/fawohlsc/azure-policy-testing), and is built on the well established PowerShell testing framework [Pester](https://pester.dev/).

For ALZ, the focus is on testing Azure Policy definitions that have a DENY effect, as these can be very disruptive to organizations if a regression is introduced, and helps us improve the quality of the policies we are developing and deploying to production environments. The framework can be extended to test other policy effects, but this is not the focus of this framework.

> **_NOTE:_** The ALZ team are considering adding support for testing Azure Policy definitions that use other effects like Audit, DeployIfNotExists.

For authoring tests we standardized on using Az PowerShell native commands as much as possible as it is simpler to implement and read, however, there are circumstances where you will need to use REST APIs as not all features are exposed through Az PowerShell. To keep things simple, we have leveraged the `Invoke-AzRestMethod` function that wraps the REST API calls and make it easier to use in the Pester tests.

### Prerequisites

- An empty (dedicated) Azure subscription
  - If following the same process as outlined below, you will also need to ensure this subscription is added to the "Corp" management group in the Azure Landing Zone
- [Pester](https://pester.dev/docs/introduction/installation)
- [Az PowerShell Module](https://learn.microsoft.com/en-us/powershell/azure/install-azure-powershell?view=azps-11.0.0&viewFallbackFrom=azps-6.2.0)
- [Invoke-AzRestMethod](https://learn.microsoft.com/en-us/powershell/module/az.accounts/invoke-azrestmethod?view=azps-11.0.0)

### How it works

The ALZ policy testing framework is designed to be used with GitHub Actions, but can be used with any CI/CD pipeline that supports PowerShell, or can be run directly on an ad hoc basis. The ALZ policy testing framework is designed to be used with the following workflow:

1. A pull request is created to update a policy definition
2. The pull request triggers a GitHub Action workflow
3. The workflow runs the defined Pester tests against the policy definition
4. The workflow reports the results of the tests back to the pull request checks
5. The pull request is reviewed and handled based on the results of the tests

### How to use it

#### 1. Create a new GitHub Action workflow

Create a new GitHub Action workflow in the `.github/workflows` folder of your repository. The workflow should be triggered on pull request events and should run on the `main` branch. The workflow should also allow being triggered manually to allow for testing of policies outside of pull requests.

[Sample GitHub Action Workflow to run Policy tests](ALZ-Policies-Test-Workflow-Sample.md)

#### 2. Create a new Pester test file

Create a new Pester test file in the `tests/policy` folder of your repository. The test file should be named the same as the policy definition file it is testing, but with a `.tests.ps1` extension. For example, if the policy definition file is named `azurepolicy.json`, the test file should be named `azurepolicy.tests.ps1`.

#### 3. Write the Pester tests

Write the Pester tests in the test file. The tests should cover the following scenarios:

- Conditions that should be true when the policy is evaluated, so it is compliant
- Conditions that should be false when the policy is evaluated, so it is non-compliant

It is important to test all the conditions evaluated in the policy. For example, if the policy is evaluating the `location` of a resource, you should test the following scenarios:

- Resource is deployed in a location that is compliant with the policy
- Resource is deployed in a location that is non-compliant with the policy

See the [How to write Pester tests for policies](#how-to-write-pester-tests-for-policies) section for more details on how to write Pester tests for policies.

### Where is the testing framework?

The testing framework is located in the [ALZ repository](https://aka.ms/alz/repo) in the `tests` folder. The framework consists of the following folders:

- `policy` - Contains the Pester tests for the policies
- `utils` - Contains the utility functions used by the Pester tests

### How to write Pester tests for policies

For the purposes of this guide, we'll focus on the Policy test for `Deny-MgmtPorts-Internet` policy as it demonstrates using both Az PowerShell and REST API calls in the Pester test. The policy definition file is located in the `policy` folder of the [ALZ repository](https://aka.ms/alz/repo) in the `policy` folder.

The policy tests are designed to run in an empty subscription(s) to ensure that the policy is evaluated in isolation and not impacted by other policies or resources in the subscription.

> **_NOTE:_** Because we are testing Azure policies in the context of Azure Landing Zone, we are using a dedicated subscription in the "Corp" landing zone that is added under the Corp management group, where we retrieve the deployed policy definition ID and create a new policy assignment to test the policy (because we do not assign all policies by default, and some get assigned to different scopes).
> You can extend this methodology to test policies outside of Azure Landing Zone by deploying the policy you want to test and assigning it to the scope you want to test (e.g. subscription, resource group, etc.

The policy test has 4 main sections (aligned with how Pester works):

#### BeforeAll: This section is used to setup the environment for the tests.

```powershell
        # Set the default context for Az commands.
        Set-AzContext -SubscriptionId $env:SUBSCRIPTION_ID -TenantId $env:TENANT_ID -Force

        if (-not [String]::IsNullOrEmpty($DeploymentConfigPath)) {
            Write-Information "==> Loading deployment configuration from : $DeploymentConfigPath"
            $deploymentObject = Get-Content -Path $DeploymentConfigPath | ConvertFrom-Json -AsHashTable

            # Set the esCompanyPrefix from the deployment configuration if not specified
            $esCompanyPrefix = $deploymentObject.TemplateParameterObject.enterpriseScaleCompanyPrefix
            $mangementGroupScope = "/providers/Microsoft.Management/managementGroups/$esCompanyPrefix-corp"
        }

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-MgmtPorts-From-Internet' }
        New-AzPolicyAssignment -Name "TDeny-MgmtPorts-Internet" -Scope $mangementGroupScope -PolicyDefinition $definition -PolicyParameterObject @{
            "ports" = @("3389", "22")
        }
```

As part of the setup before running the test, we need to ensure we have the correct Azure context set, and that the policy is assigned to the correct scope. Because these steps are running as part of Azure Landing Zone pull request testing, the policies we want to test get deployed prior to running these test. In this case, we retrieve the policy definition and assign it to the management group scope, passing in the policy parameters to ensure the policy is evaluated correctly.

If you want to extend this methodology to test policies independent of deploying ALZ, you could extend this section to also deploy the policy you want to test, and then do the policy assignment.

#### DENY - group of tests to validate scenarios that where the policy effect is applied and deployment should fail.

As an example, using Az PowerShell:

```Powershell
        It "Should deny non-compliant port '3389'" -Tag "deny-noncompliant-nsg-port" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $networkSecurityGroup = New-AzNetworkSecurityGroup `
                -Name "nsg-test" `
                -ResourceGroupName $ResourceGroup.ResourceGroupName `
                -Location $ResourceGroup.Location

                # Should be disallowed by policy, so exception should be thrown.
                {
                    $networkSecurityGroup | Add-AzNetworkSecurityRuleConfig `
                        -Name RDP-rule `
                        -Description "Allow RDP" `
                        -Access Allow `
                        -Protocol Tcp `
                        -Direction Inbound `
                        -Priority 200 `
                        -SourceAddressPrefix * `
                        -SourcePortRange * `
                        -DestinationAddressPrefix * `
                        -DestinationPortRange 3389 # Incompliant.
                    | Set-AzNetworkSecurityGroup
                } | Should -Throw "*disallowed by policy*"
            }
        }
```

In this example, we are creating a new Network Security Group (NSG) and adding a rule to allow RDP traffic on port 3389. The policy we're testing is configured to deny traffic on port 3389, so we expect this operation to fail. We use the `Should -Throw` command to validate that the operation failed with the expected error message.

#### ALLOW - group of tests to validate scenarios that are compliant with the policy conditions and should succeed.

As an example, using REST API with `Invoke-AzRestMethod`:

```Powershell
        It "Should allow compliant port ranges* - API" -Tag "allow-compliant-nsg-port" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                #Destination port ranges to test
                $portRanges =  @("23","3390-3392","8080")

                # Create Payload for NSG
                $securityRules = @(
                    @{
                        name = "Web-rule"
                        properties = @{
                            description = "Allow Web2"
                            protocol = "Tcp"
                            sourcePortRange = "*"
                            destinationPortRange = "443"
                            sourceAddressPrefix = "*"
                            destinationAddressPrefix = "*"
                            access = "Allow"
                            priority = 300
                            direction = "Inbound"
                        }
                    },
                    @{
                        name = "Multi-rule"
                        properties = @{
                            description = "Allow Mgmt3"
                            protocol = "Tcp"
                            sourcePortRange = "*"
                            destinationPortRanges = $portRanges
                            sourceAddressPrefix = "*"
                            destinationAddressPrefix = "*"
                            access = "Allow"
                            priority = 310
                            direction = "Inbound"
                        }
                    }
                )

                $object = @{
                    properties = @{
                        securityRules = $securityRules
                    }
                    location = "uksouth"
                }

                $payload = ConvertTo-Json -InputObject $object -Depth 100

                # Should be disallowed by policy, so exception should be thrown.
                {
                    $httpResponse = Invoke-AzRestMethod `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -ResourceProviderName "Microsoft.Network" `
                        -ResourceType "networkSecurityGroups" `
                        -Name "testNSG99" `
                        -ApiVersion "2022-11-01" `
                        -Method "PUT" `
                        -Payload $payload
            
                if ($httpResponse.StatusCode -eq 200 -or $httpResponse.StatusCode -eq 201) {
                    # NSG created
                }
                # Error response describing why the operation failed.
                else {
                    throw "Operation failed with message: '$($httpResponse.Content)'"
                }              
                } | Should -Not -Throw
            }
        }
```

In this example, we are creating a new Network Security Group (NSG) and adding a rule to allow traffic on port 443. The policy we're testing is configured to deny traffic on port 3389, so we expect this operation to succeed. We use the `Should -Not -Throw` command to validate that the operation succeeded.

#### AfterAll: This section is used to clean up the environment after the tests are completed.

```Powershell
    Remove-AzPolicyAssignment -Name "TDeny-MgmtPorts-Internet" -Scope $mangementGroupScope -Confirm:$false
```

In this example, we are removing the policy assignment after the tests are completed (if you're testing outside of an ALZ deployment, you can also use this to remove the deployed policy).