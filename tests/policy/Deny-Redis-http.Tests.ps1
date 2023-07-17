[CmdletBinding()]
param (
    [Parameter()][String]$DeploymentConfigPath = "./src/data/eslzArm.test.deployment.json",
    [Parameter()][String]$esCompanyPrefix
)

Import-Module -Name Az.RedisCache
Import-Module -Name Az.Resources
Import-Module "$($PSScriptRoot)/../../tests/utils/Policy.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Rest.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Test.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Generic.Utils.psm1" -Force

Describe "Testing policy 'Deny-Redis-http'" -Tag "deny-redis-http" {

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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-Redis-http' }
        New-AzPolicyAssignment -Name "TDeny-Redis-http" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    Context "Test secure connections enabled on Azure Cache for Redis when created" -Tag "deny-redis-http" {

        It "Should deny non-compliant Azure Cache for Redis - EnableNonSslPort" -Tag "deny-noncompliant-redis" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 5
                $name = "alztest$Random" 

                {
                    New-AzRedisCache `
                       -ResourceGroupName $ResourceGroup.ResourceGroupName `
                       -Name $name `
                       -Location "uksouth" `
                       -EnableNonSslPort $true `
                       -MinimumTlsVersion "TLS1_2"
                       
               } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should deny non-compliant Azure Cache for Redis - TLS version" -Tag "deny-noncompliant-redis" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 5
                $name = "alztest$Random" 

                {
                    New-AzRedisCache `
                       -ResourceGroupName $ResourceGroup.ResourceGroupName `
                       -Name $name `
                       -Location "uksouth" `
                       -EnableNonSslPort $false `
                       -MinimumTlsVersion "TLS1_0"
                       
               } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should allow compliant Azure Cache for Redis" -Tag "allow-compliant-redis" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 5
                $name = "alztest$Random" 

                {
                    New-AzRedisCache `
                       -ResourceGroupName $ResourceGroup.ResourceGroupName `
                       -Name $name `
                       -Location "uksouth" `
                       -EnableNonSslPort $false `
                       -MinimumTlsVersion "TLS1_2"
                        
                } | Should -Not -Throw
            }
        }
    }

    Context "Test secure connections enabled on Azure Cache for Redis when updated" -Tag "deny-redis-http" {

        It "Should deny non-compliant Azure Cache for Redis" -Tag "deny-noncompliant-redis" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 5
                $name = "alztest$Random" 

                # Should be disallowed by policy, so exception should be thrown.
                {
                    New-AzRedisCache `
                       -ResourceGroupName $ResourceGroup.ResourceGroupName `
                       -Name $name `
                       -Location "uksouth" `
                       -EnableNonSslPort $false `
                       -MinimumTlsVersion "TLS1_2"

                    Set-AzRedisCache `
                       -Name $name `
                       -EnableNonSslPort $true `
                       -MinimumTlsVersion "TLS1_1.1"
                        
                } | Should -Throw "*disallowed by policy*"
            }
        }
    }
}