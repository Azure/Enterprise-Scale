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
Import-Module "$($PSScriptRoot)/../../tests/utils/Generic.Utils.psm1" -Force

Describe "Testing policy 'Deny-StorageAccount-CustomDomain'" -Tag "deny-storage-custdom" {

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

                $random = GenerateRandomString -Length 13
                $name = "alztest$Random" 

                {
                    New-AzStorageAccount `
                       -ResourceGroupName $ResourceGroup.ResourceGroupName `
                       -Name $name `
                       -Location "uksouth" `
                       -SkuName "Standard_LRS" `
                       -Kind "StorageV2" `
                       -MinimumTlsVersion "TLS1_2" `
                       -AllowBlobPublicAccess $false `
                       -EnableHttpsTrafficOnly  $true `
                       -PublicNetworkAccess "Disabled" `
                       -CustomDomainName "$name.blob.core.windows.net" `
                       -UseSubDomain $true
                       
               } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should deny non-compliant Storage Account - Custom Domain - domain name set" -Tag "deny-noncompliant-storage" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "alztest$Random" 

                # Should be disallowed by policy, so exception should be thrown.
                {
                    New-AzStorageAccount `
                       -ResourceGroupName $ResourceGroup.ResourceGroupName `
                       -Name $name `
                       -Location "uksouth" `
                       -SkuName "Standard_LRS" `
                       -Kind "StorageV2" `
                       -MinimumTlsVersion "TLS1_2" `
                       -AllowBlobPublicAccess $false `
                       -EnableHttpsTrafficOnly  $true `
                       -PublicNetworkAccess "Disabled" `
                       -CustomDomainName "$name.blob.core.windows.net" `
                       -UseSubDomain $false

                } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should allow compliant Storage Account - Custom Domain" -Tag "allow-compliant-storage" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "alztest$Random" 

                {
                     New-AzStorageAccount `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -Name $name `
                        -Location "uksouth" `
                        -SkuName "Standard_LRS" `
                        -Kind "StorageV2" `
                        -MinimumTlsVersion "TLS1_2" `
                        -AllowBlobPublicAccess $false `
                        -EnableHttpsTrafficOnly  $true `
                        -PublicNetworkAccess "Disabled"
                        
                } | Should -Not -Throw
            }
        }
    }

    Context "Test custom domain enabled on Storage Account when updated" -Tag "deny-storage-custdom" {

        It "Should deny non-compliant Storage Account - Custom Domain - both properties set" -Tag "deny-noncompliant-storage" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "alztest$Random" 

                # Should be disallowed by policy, so exception should be thrown.
                {
                    New-AzStorageAccount `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -Name $name `
                        -Location "uksouth" `
                        -SkuName "Standard_LRS" `
                        -Kind "StorageV2" `
                        -MinimumTlsVersion "TLS1_2" `
                        -AllowBlobPublicAccess $false `
                        -EnableHttpsTrafficOnly  $true `
                        -PublicNetworkAccess "Disabled"

                    Set-AzStorageAccount `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -Name $name `
                        -MinimumTlsVersion "TLS1_2" `
                        -AllowBlobPublicAccess $false `
                        -EnableHttpsTrafficOnly $true `
                        -PublicNetworkAccess "Disabled" `
                        -CustomDomainName "$name.blob.core.windows.net" `
                        -UseSubDomain $true
                        
                } | Should -Throw "*disallowed by policy*"
            }
        }
    }
        
    AfterAll {
        Remove-AzPolicyAssignment -Name "TDeny-STA-custdom" -Scope $mangementGroupScope -Confirm:$false
    }
}