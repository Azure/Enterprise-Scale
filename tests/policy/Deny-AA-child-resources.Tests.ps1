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

        It "Should deny non-compliant Automation Account - Runbook" -Tag "deny-noncompliant-automation" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                {
                    New-AzAutomationAccount `
                       -ResourceGroupName $ResourceGroup.ResourceGroupName `
                       -Name "ContosoAA001" `
                       -Location "uksouth"

                    New-AzAutomationRunbook `
                          -ResourceGroupName $ResourceGroup.ResourceGroupName `
                          -AutomationAccountName "ContosoAA001" `
                          -Name "ContosoRunbook001"
                       
               } | Should -Throw "*disallowed by policy*"
            }
        }
    }

}