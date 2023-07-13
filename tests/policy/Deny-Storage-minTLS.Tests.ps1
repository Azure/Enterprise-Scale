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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-Storage-minTLS' }
        New-AzPolicyAssignment -Name "TDeny-STA-minTLS" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    Context "Test minimum TLS version enabled on Storage Account when created" -Tag "deny-storage-mintls" {
        
        It "Should deny non-compliant Storage Account - Minimum TLS version" -Tag "deny-noncompliant-storage" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

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
                        -Name "testalzsta9999901" `
                        -ApiVersion "2022-09-01" `
                        -Method "PUT" `
                        -Payload $payload
            
                    if ($httpResponse.StatusCode -eq 200) {
                        # Storage Account created
                    }
                    elseif ($httpResponse.StatusCode -eq 202) {
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

        # It "Should allow compliant Storage Account - HTTPS Traffic only" -Tag "allow-noncompliant-storage" {
        #     AzTest -ResourceGroup {
        #         param($ResourceGroup)

        #         $sku = @{
        #             name = "Standard_LRS"
        #             tier = "Standard"
        #         }

        #         $object = @{
        #             kind = "StorageV2"
        #             sku = $sku
        #             properties = @{
        #                 minimumTlsVersion = "TLS1_2"
        #                 allowBlobPublicAccess = false
        #                 supportsHttpsTrafficOnly = false
        #                 publicNetworkAccess = "Disabled"
        #             }
        #             location = "uksouth"
        #         }

        #         $payload = ConvertTo-Json -InputObject $object -Depth 100

        #         # Should be disallowed by policy, so exception should be thrown.
        #         {
        #             $httpResponse = Invoke-AzRestMethod `
        #                 -ResourceGroupName $ResourceGroup.ResourceGroupName `
        #                 -ResourceProviderName "Microsoft.Storage" `
        #                 -ResourceType "storageAccounts" `
        #                 -Name "testalzsta9999901" `
        #                 -ApiVersion "2022-09-01" `
        #                 -Method "PUT" `
        #                 -AsJob `
        #                 -Payload $payload
            
        #             if ($httpResponse.StatusCode -eq 200) {
        #                 # App Service - API created
        #             }
        #             elseif ($httpResponse.StatusCode -eq 202) {
        #                 $asyncOperation = $httpResponse | Wait-AsyncOperation
        #                 if ($asyncOperation.Status -ne "Succeeded") {
        #                     throw "Asynchronous operation failed with message: '$($asyncOperation)'"
        #                 }
        #             }
        #             # Error response describing why the operation failed.
        #             else {
        #                 throw "Operation failed with message: '$($httpResponse.Content)'"
        #             }              
        #         } | Should -Throw "*disallowed by policy*"
        #     }
        # }

        # It "Should allow compliant Storage Account - Minimum TLS version" -Tag "allow-noncompliant-storage" {
        #     AzTest -ResourceGroup {
        #         param($ResourceGroup)

        #         $sku = @{
        #             name = "Standard_LRS"
        #             tier = "Standard"
        #         }

        #         $object = @{
        #             kind = "StorageV2"
        #             sku = $sku
        #             properties = @{
        #                 minimumTlsVersion = "TLS1_2"
        #                 allowBlobPublicAccess = false
        #                 publicNetworkAccess = "Disabled"
        #             }
        #             location = "uksouth"
        #         }

        #         $payload = ConvertTo-Json -InputObject $object -Depth 100

        #         # Should be disallowed by policy, so exception should be thrown.
        #         {
        #             $httpResponse = Invoke-AzRestMethod `
        #                 -ResourceGroupName $ResourceGroup.ResourceGroupName `
        #                 -ResourceProviderName "Microsoft.Storage" `
        #                 -ResourceType "storageAccounts" `
        #                 -Name "testalzsta9999901" `
        #                 -ApiVersion "2022-09-01" `
        #                 -Method "PUT" `
        #                 -AsJob `
        #                 -Payload $payload
            
        #             if ($httpResponse.StatusCode -eq 200) {
        #                 # App Service - API created
        #             }
        #             elseif ($httpResponse.StatusCode -eq 202) {
        #                 $asyncOperation = $httpResponse | Wait-AsyncOperation
        #                 if ($asyncOperation.Status -ne "Succeeded") {
        #                     throw "Asynchronous operation failed with message: '$($asyncOperation)'"
        #                 }
        #             }
        #             # Error response describing why the operation failed.
        #             else {
        #                 throw "Operation failed with message: '$($httpResponse.Content)'"
        #             }              
        #         } | Should -Not -Throw
        #     }
        # }
    }

    # Context "Test minimum TLS version enabled on Storage Account when updated" -Tag "deny-storage-mintls" {

    #     It "Should deny non-compliant Storage Account - Minimum TLS version" -Tag "deny-noncompliant-storage" {
    #         AzTest -ResourceGroup {
    #             param($ResourceGroup)

    #             $sku = @{
    #                 name = "Standard_LRS"
    #                 tier = "Standard"
    #             }

    #             $object = @{
    #                 kind = "StorageV2"
    #                 sku = $sku
    #                 properties = @{
    #                     minimumTlsVersion = "TLS1_0"
    #                     allowBlobPublicAccess = false
    #                     publicNetworkAccess = "Disabled"
    #                 }
    #                 location = "uksouth"
    #             }

    #             $payload = ConvertTo-Json -InputObject $object -Depth 100

    #             $sta = Get-AzStorageAccount -ResourceGroupName $ResourceGroup.ResourceGroupName -Name "testalzsta9999901"

    #             # Should be disallowed by policy, so exception should be thrown.
    #             if ($sta -ne $null) {
    #                 {
    #                     $httpResponse = Invoke-AzRestMethod `
    #                         -ResourceGroupName $ResourceGroup.ResourceGroupName `
    #                         -ResourceProviderName "Microsoft.Storage" `
    #                         -ResourceType "storageAccounts" `
    #                         -Name "testalzsta9999901" `
    #                         -ApiVersion "2022-09-01" `
    #                         -Method "PATCH" `
    #                         -AsJob `
    #                         -Payload $payload
                
    #                     if ($httpResponse.StatusCode -eq 200) {
    #                         # Storage Account created
    #                     }
    #                     elseif ($httpResponse.StatusCode -eq 202) {
    #                         # Storage Account provisioning is asynchronous, so wait for it to complete.
    #                         $asyncOperation = $httpResponse | Wait-AsyncOperation
    #                         if ($asyncOperation.Status -ne "Succeeded") {
    #                             throw "Asynchronous operation failed with message: '$($asyncOperation)'"
    #                         }
    #                     }
    #                     # Error response describing why the operation failed.
    #                     else {
    #                         throw "Operation failed with message: '$($httpResponse.Content)'"
    #                     }              
    #                 } | Should -Throw "*disallowed by policy*"
    #             }
    #         }
    #     }
    # }
}