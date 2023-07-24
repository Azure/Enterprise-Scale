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

Describe "Testing policy 'Deny-FileServices-InsecureAuth'" -Tag "deny-files-auth" {

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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-FileServices-InsecureAuth' }
        New-AzPolicyAssignment -Name "TDeny-Files-auth" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    Context "Test insercure authentication enabled on Storage Account - File Services when created" -Tag "deny-files-auth" {

        It "Should deny non-compliant Storage Account - File Services - Insecure Auth" -Tag "deny-noncompliant-files" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "alztest$Random" 

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

                {
                    # "versions": "SMB2.1;SMB3.0;SMB3.1.1",
                    # "authenticationMethods": "NTLMv2;Kerberos",
                    # "kerberosTicketEncryption": "RC4-HMAC;AES-256",
                    # "channelEncryption": "AES-128-CCM;AES-128-GCM;AES-256-GCM"

                    $protocolSettings = @{
                        smb = @{
                            authenticationMethods = "NTLMv2" # Not valid
                            channelEncryption = "AES-256-GCM" # Valid
                            kerberosTicketEncryption = "AES-256" # Valid
                            versions = "SMB3.1.1" #Valid
                        }
                    }

                    $object = @{
                        properties = @{
                            protocolSettings = $protocolSettings
                        }
                    }
                    $payload = ConvertTo-Json -InputObject $object -Depth 100
    
                    # Should be disallowed by policy, so exception should be thrown.
                    $httpResponse = Invoke-AzRestMethod `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -ResourceProviderName "Microsoft.Storage" `
                        -ResourceType  @('storageAccounts','fileServices') `
                        -Name @($name, 'default') `
                        -ApiVersion "2022-09-01" `
                        -Method "PUT" `
                        -Payload $payload
            
                    if ($httpResponse.StatusCode -eq 200) {
                        # Storage Account created
                    }
                    # Error response describing why the operation failed.
                    else {
                        throw "Operation failed with message: '$($httpResponse.Content)'"
                    } 

               } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should allow compliant Storage Account - File Services - Insecure Auth" -Tag "allow-compliant-files" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "alztest$Random" 

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

                {
                    # "versions": "SMB2.1;SMB3.0;SMB3.1.1",
                    # "authenticationMethods": "NTLMv2;Kerberos",
                    # "kerberosTicketEncryption": "RC4-HMAC;AES-256",
                    # "channelEncryption": "AES-128-CCM;AES-128-GCM;AES-256-GCM"

                    $protocolSettings = @{
                        smb = @{
                            authenticationMethods = "Kerberos" # Valid
                            channelEncryption = "AES-256-GCM" # Valid
                            kerberosTicketEncryption = "AES-256" # Valid
                            versions = "SMB3.1.1" # Valid
                        }
                    }

                    $object = @{
                        properties = @{
                            protocolSettings = $protocolSettings
                        }
                    }
                    $payload = ConvertTo-Json -InputObject $object -Depth 100
    
                    # Should be disallowed by policy, so exception should be thrown.
                    $httpResponse = Invoke-AzRestMethod `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -ResourceProviderName "Microsoft.Storage" `
                        -ResourceType  @('storageAccounts','fileServices') `
                        -Name @($name, 'default') `
                        -ApiVersion "2022-09-01" `
                        -Method "PUT" `
                        -Payload $payload
            
                    if ($httpResponse.StatusCode -eq 200) {
                        # Storage Account created
                    }
                    # Error response describing why the operation failed.
                    else {
                        throw "Operation failed with message: '$($httpResponse.Content)'"
                    } 

               } | Should -Not -Throw
            }
        }
    }

    AfterAll {
        Remove-AzPolicyAssignment -Name "TDeny-Files-auth" -Scope $mangementGroupScope -Confirm:$false
    }
}