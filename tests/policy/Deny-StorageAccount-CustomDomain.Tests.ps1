[CmdletBinding()]
param (
    [Parameter()][String]$DeploymentConfigPath = "./src/data/eslzArm.test.deployment.json",
    [Parameter()][String]$esCompanyPrefix
)

Import-Module -Name Az.Storage
Import-Module -Name Az.Resources
Import-Module "$($PSScriptRoot)/../../tests/utils/Policy.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Rest.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Test.Utils.psm1" -Force

Describe "Testing policy 'Deny-Storage-minTLS'" -Tag "deny-storage-mintls" {

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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-StorageAccount-CustomDomain' }
        New-AzPolicyAssignment -Name "TDeny-STA-custdom" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    Context "Test custom domain enabled on Storage Account when created" -Tag "deny-storage-custdom" {

        It "Should deny non-compliant Storage Account - Custom Domain - both properties set" -Tag "deny-noncompliant-storage" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                {
                    New-AzStorageAccount `
                       -ResourceGroupName $ResourceGroup.ResourceGroupName `
                       -Name "testalzsta9999901" `
                       -Location "uksouth" `
                       -SkuName "Standard_LRS" `
                       -Kind "StorageV2" `
                       -MinimumTlsVersion "TLS1_2" `
                       -AllowBlobPublicAccess $false `
                       -EnableHttpsTrafficOnly  $true `
                       -PublicNetworkAccess "Disabled" `
                       -CustomDomainName "testalzsta9999901.blob.core.windows.net" `
                       -UseSubDomain $true
                       
               } | Should -Not -Throw
            }
        }

        # Secure transfer should be enabled by default as part of this policy check even though there is a dedicated policy for this. Should throw an exception if the other policy is not assigned.
        It "Should deny non-compliant Storage Account - Custom Domain - domain name set" -Tag "deny-noncompliant-storage" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                # Should be disallowed by policy, so exception should be thrown.
                {
                    New-AzStorageAccount `
                       -ResourceGroupName $ResourceGroup.ResourceGroupName `
                       -Name "testalzsta9999901" `
                       -Location "uksouth" `
                       -SkuName "Standard_LRS" `
                       -Kind "StorageV2" `
                       -MinimumTlsVersion "TLS1_2" `
                       -AllowBlobPublicAccess $false `
                       -EnableHttpsTrafficOnly  $true `
                       -PublicNetworkAccess "Disabled" `
                       -CustomDomainName "testalzsta9999901.blob.core.windows.net" `
                       -UseSubDomain $false
                } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should deny non-compliant Storage Account - Custom Domain - sub domain set" -Tag "deny-noncompliant-storage" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                # Should be disallowed by policy, so exception should be thrown.
                {
                    New-AzStorageAccount `
                    -ResourceGroupName $ResourceGroup.ResourceGroupName `
                    -Name "testalzsta9999901" `
                    -Location "uksouth" `
                    -SkuName "Standard_LRS" `
                    -Kind "StorageV2" `
                    -MinimumTlsVersion "TLS1_2" `
                    -AllowBlobPublicAccess $false `
                    -EnableHttpsTrafficOnly  $true `
                    -PublicNetworkAccess "Disabled" `
                    -UseSubDomain $true
                } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should allow compliant Storage Account - Custom Domain" -Tag "allow-compliant-storage" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                {
                     New-AzStorageAccount `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -Name "testalzsta9999902" `
                        -Location "uksouth" `
                        -SkuName "Standard_LRS" `
                        -Kind "StorageV2" `
                        -MinimumTlsVersion "TLS1_2" `
                        -AllowBlobPublicAccess $false `
                        -EnableHttpsTrafficOnly  $true `
                        -PublicNetworkAccess "Disabled" `
                        -UseSubDomain $false
                        
                } | Should -Not -Throw
            }
        }
    }

    Context "Test custom domain enabled on Storage Account when updated" -Tag "deny-storage-custdom" {

        It "Should deny non-compliant Storage Account - Custom Domain - both properties set" -Tag "deny-noncompliant-storage" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                # Should be disallowed by policy, so exception should be thrown.
                {
                    New-AzStorageAccount `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -Name "testalzsta9999903" `
                        -Location "uksouth" `
                        -SkuName "Standard_LRS" `
                        -Kind "StorageV2" `
                        -MinimumTlsVersion "TLS1_2" `
                        -AllowBlobPublicAccess $false `
                        -EnableHttpsTrafficOnly  $true `
                        -PublicNetworkAccess "Disabled"

                    Set-AzStorageAccount `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -Name "testalzsta9999903" `
                        -MinimumTlsVersion "TLS1_0" `
                        -AllowBlobPublicAccess $false `
                        -EnableHttpsTrafficOnly $true `
                        -PublicNetworkAccess "Disabled" `
                        -CustomDomainName "testalzsta9999901.blob.core.windows.net" `
                        -UseSubDomain $true
                        
                } | Should -Throw "*disallowed by policy*"
            }
        }
    }
}