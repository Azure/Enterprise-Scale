[CmdletBinding()]
param (
    [Parameter()][String]$DeploymentConfigPath = "./src/data/eslzArm.test.deployment.json",
    [Parameter()][String]$esCompanyPrefix
)

Import-Module -Name Az.Network
Import-Module -Name Az.Resources
Import-Module "$($PSScriptRoot)/../../tests/utils/Policy.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Rest.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Test.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Generic.Utils.psm1" -Force

Describe "Testing policy 'Deny-Private-DNS-Zones'" -Tag "deny-pvt-dns" {

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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-Private-DNS-Zones' }
        New-AzPolicyAssignment -Name "TDeny-pvt-dns" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    Context "Test Private DNS when created" -Tag "deny-pvt-dns" {

        It "Should deny non-compliant Private DNS" -Tag "deny-pvt-dns" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                {
                    New-AzPrivateDnsZone -Name "alztest.com" -ResourceGroupName $ResourceGroup.ResourceGroupName

                } | Should -Throw "*disallowed by policy*"
            }
        }
    }

    AfterAll {
        Remove-AzPolicyAssignment -Name "TDeny-pvt-dns" -Scope $mangementGroupScope -Confirm:$false
    }
}
