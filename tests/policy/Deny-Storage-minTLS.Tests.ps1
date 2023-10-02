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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-Storage-minTLS' }
        New-AzPolicyAssignment -Name "TDeny-STA-minTLS" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    Context "Test minimum TLS version enabled on Storage Account when created" -Tag "deny-storage-mintls" {
        
        It "Should deny non-compliant Storage Account - Minimum TLS version - via API" -Tag "deny-noncompliant-storage" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "alztest$Random" 

                $sku = @{
                    name = "Standard_LRS"
                    tier = "Standard"
                }

                $object = @{
                    kind = "StorageV2"
                    sku = $sku
                    properties = @{
                        minimumTlsVersion = "TLS1_0"
                        allowBlobPublicAccess = $false
                        publicNetworkAccess = "Disabled"
                    }
                    location = "uksouth"
                }

                $payload = ConvertTo-Json -InputObject $object -Depth 100

                # Should be disallowed by policy, so exception should be thrown.
                {
                    $httpResponse = Invoke-AzRestMethod `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -ResourceProviderName "Microsoft.Storage" `
                        -ResourceType "storageAccounts" `
                        -Name $name `
                        -ApiVersion "2022-09-01" `
                        -Method "PUT" `
                        -Payload $payload
            
                    if ($httpResponse.StatusCode -eq 200) {
                        # Storage Account created
                    }
                    elseif ($httpResponse.StatusCode -eq 202) {
                        # Storage Account provisioning is asynchronous, so wait for it to complete.
                        $asyncOperation = $httpResponse | Wait-AsyncOperation
                        if ($asyncOperation.Status -ne "Succeeded") {
                            throw "Asynchronous operation failed with message: '$($asyncOperation)'"
                        }
                    } 
                    # Error response describing why the operation failed.
                    else {
                        throw "Operation failed with message: '$($httpResponse.Content)'"
                    }              
                } | Should -Throw "*disallowed by policy*"
            }
        }

        # Secure transfer should be enabled by default as part of this policy check even though there is a dedicated policy for this. Should throw an exception if the other policy is not assigned.
        It "Should deny non-compliant Storage Account - HTTPS Traffic only" -Tag "deny-noncompliant-storage" {
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
                        -EnableHttpsTrafficOnly  $false `
                        -PublicNetworkAccess "Disabled"
                } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should deny non-compliant Storage Account - TLS version" -Tag "deny-noncompliant-storage" {
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
                        -MinimumTlsVersion "TLS1_1" `
                        -AllowBlobPublicAccess $false `
                        -EnableHttpsTrafficOnly  $true `
                        -PublicNetworkAccess "Disabled"             
                } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should allow compliant Storage Account - Minimum TLS version" -Tag "allow-compliant-storage" {
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

    Context "Test minimum TLS version enabled on Storage Account when updated" -Tag "deny-storage-mintls" {

        It "Should deny non-compliant Storage Account - Minimum TLS version" -Tag "deny-noncompliant-storage" {
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
                        -MinimumTlsVersion "TLS1_0" `
                        -AllowBlobPublicAccess $false `
                        -EnableHttpsTrafficOnly $true `
                        -PublicNetworkAccess "Disabled"   
                        
                } | Should -Throw "*disallowed by policy*"
            }
        }
    }
    
    AfterAll {
        Remove-AzPolicyAssignment -Name "TDeny-STA-minTLS" -Scope $mangementGroupScope -Confirm:$false
    }
}