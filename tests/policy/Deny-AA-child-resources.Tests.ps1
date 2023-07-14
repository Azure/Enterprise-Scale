[CmdletBinding()]
param (
    [Parameter()][String]$DeploymentConfigPath = "./src/data/eslzArm.test.deployment.json",
    [Parameter()][String]$esCompanyPrefix
)

Import-Module -Name Az.Automation
Import-Module -Name Az.Resources
Import-Module "$($PSScriptRoot)/../../tests/utils/Policy.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Rest.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Test.Utils.psm1" -Force

Describe "Testing policy 'Deny-AA-child-resources'" -Tag "deny-automation-children" {

    BeforeAll {
        
        # Set the default context for Az commands.
        Set-AzContext -SubscriptionId $env:SUBSCRIPTION_ID -TenantId $env:TENANT_ID -Force

        if (-not [String]::IsNullOrEmpty($DeploymentConfigPath)) {
            Write-Information "==> Loading deployment configuration from : $DeploymentConfigPath"
            $deploymentObject = Get-Content -Path $DeploymentConfigPath | ConvertFrom-Json -AsHashTable

            # Set the esCompanyPrefix from the deployment configuration if not specified
            $esCompanyPrefix = $deploymentObject.TemplateParameterObject.enterpriseScaleCompanyPrefix
            $mangementGroupScope = "/providers/Microsoft.Management/managementGroups/$esCompanyPrefix-corp"
        }

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-AA-child-resources' }
        New-AzPolicyAssignment -Name "TDeny-AA-child" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    Context "Test adding child resources on Automation Account when created or updated" -Tag "deny-automation-children" {

        # TEST TEST TEST
        # It "Should allow compliant Automation Account" -Tag "deny-noncompliant-automation" {
        #     AzTest -ResourceGroup {
        #         param($ResourceGroup)

        #         {
        #             $aa = New-AzAutomationAccount `
        #                -ResourceGroupName $ResourceGroup.ResourceGroupName `
        #                -Name "ContosoAA001" `
        #                -Location "uksouth" `
        #                -DisablePublicNetworkAccess
                       
        #        } | Should -Not -Throw
        #     }
        # }
        
        # It "Should deny non-compliant Automation Account - Runbook" -Tag "deny-noncompliant-automation" {
        #     AzTest -ResourceGroup {
        #         param($ResourceGroup)

        #         {
        #             $aa = New-AzAutomationAccount `
        #                -ResourceGroupName $ResourceGroup.ResourceGroupName `
        #                -Name "ContosoAA001" `
        #                -Location "uksouth" `
        #                -DisablePublicNetworkAccess

        #             New-AzAutomationRunbook `
        #                   -ResourceGroupName $ResourceGroup.ResourceGroupName `
        #                   -AutomationAccountName $aa.AutomationAccountName `
        #                   -Name "ContosoRunbook001"
                       
        #        } | Should -Throw "*disallowed by policy*"
        #     }
        # }

        It "Should deny non-compliant Automation Account - Runbook - via API" -Tag "deny-noncompliant-automation" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $sku = @{
                    name = "Free"
                    family = $null
                    capacity = $null
                }

                $object = @{
                    name = "ContosoAA001"
                    sku = $sku
                    properties = @{
                        publicNetworkAccess = $false
                    }
                    location = "uksouth"
                }
                $payload = ConvertTo-Json -InputObject $object -Depth 100

                # Should be disallowed by policy, so exception should be thrown.
                {
                    $httpResponse = Invoke-AzRestMethod `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -ResourceProviderName "Microsoft.Automation" `
                        -ResourceType "automationAccounts" `
                        -Name "ContosoAA001" `
                        -ApiVersion "2021-06-22" `
                        -Method "PUT" `
                        -Payload $payload
            
                    if ($httpResponse.StatusCode -eq 200 -or $httpResponse.StatusCode -eq 201) {
                        # Automation Account created
                    }
                    else {
                        throw "Operation failed with message: '$($httpResponse.Content)'"
                    }              

                    $object = @{
                        properties = @{
                            runbookType = $false
                        }
                    }
                    $payload = ConvertTo-Json -InputObject $object -Depth 100

                    $httpResponse = Invoke-AzRestMethod `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -ResourceProviderName "Microsoft.Automation" `
                        -ResourceType "runbooks" `
                        -AutomationAccountName "ContosoAA001" `
                        -Name "ContosoRunbook001" `
                        -ApiVersion "2019-06-01" `
                        -Method "PUT" `
                        -Payload $payload
            
                    if ($httpResponse.StatusCode -eq 200 -or $httpResponse.StatusCode -eq 201) {
                        # Automation Account - Runbook created
                    }
                    else {
                        throw "Operation failed with message: '$($httpResponse.Content)'"
                    }

                } | Should -Throw "*disallowed by policy*"
            }
        }

        # It "Should deny non-compliant Automation Account - Variable" -Tag "deny-noncompliant-automation" {
        #     AzTest -ResourceGroup {
        #         param($ResourceGroup)

        #         {
        #             New-AzAutomationAccount `
        #                -ResourceGroupName $ResourceGroup.ResourceGroupName `
        #                -Name "ContosoAA002" `
        #                -Location "uksouth" `
        #                -DisablePublicNetworkAccess

        #             New-AzAutomationRunbook `
        #                   -ResourceGroupName $ResourceGroup.ResourceGroupName `
        #                   -AutomationAccountName "ContosoAA002" `
        #                   -Name "ContosoVariable001" `
        #                   -Encrypted $False `
        #                   -Value "My String"
                       
        #        } | Should -Throw "*disallowed by policy*"
        #     }
        # }
    }

}