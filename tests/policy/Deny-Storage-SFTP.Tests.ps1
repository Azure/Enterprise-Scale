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

Describe "Testing policy 'Deny-Storage-SFTP'" -Tag "deny-storage-sftp" {

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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-Storage-SFTP' }
        New-AzPolicyAssignment -Name "TDeny-STA-sftp" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    Context "Test SFTP enabled on Storage Account when created" -Tag "deny-storage-sftp" {

        It "Should deny non-compliant Storage Account - SFTP" -Tag "deny-noncompliant-storage" {
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
                       -EnableSftp $true
                       
               } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should allow compliant Storage Account - SFTP" -Tag "allow-compliant-storage" {
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

    Context "Test SFTP on Storage Account when updated" -Tag "deny-storage-SFTP" {

        It "Should deny non-compliant Storage Account - SFTP" -Tag "deny-noncompliant-storage" {
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
                        -EnableSftp $true
                        
                } | Should -Throw "*disallowed by policy*"
            }
        }
    }
        
    AfterAll {
        Remove-AzPolicyAssignment -Name "TDeny-STA-sftp" -Scope $mangementGroupScope -Confirm:$false
    }
}