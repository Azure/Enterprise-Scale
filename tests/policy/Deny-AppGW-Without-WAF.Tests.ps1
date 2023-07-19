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

Describe "Testing policy 'Deny-AppGW-Without-WAF'" -Tag "deny-appgw-waf" {

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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-AppGW-Without-WAF' }
        New-AzPolicyAssignment -Name "TDeny-AppGw-WAF" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    Context "Test WAF enabled on Application Gateway when created" -Tag "deny-appgw-waf" {

        # It "Should deny non-compliant Storage Account - File Services - Insecure Auth" -Tag "deny-noncompliant-files" {
        #     AzTest -ResourceGroup {
        #         param($ResourceGroup)

        #         $random = GenerateRandomString -Length 13
        #         $name = "alztest$Random" 

        #         New-AzStorageAccount `
        #             -ResourceGroupName $ResourceGroup.ResourceGroupName `
        #             -Name $name `
        #             -Location "uksouth" `
        #             -SkuName "Standard_LRS" `
        #             -Kind "StorageV2" `
        #             -MinimumTlsVersion "TLS1_2" `
        #             -AllowBlobPublicAccess $false `
        #             -EnableHttpsTrafficOnly  $true `
        #             -PublicNetworkAccess "Disabled"

        #         {
        #             # "versions": "SMB2.1;SMB3.0;SMB3.1.1",
        #             # "authenticationMethods": "NTLMv2;Kerberos",
        #             # "kerberosTicketEncryption": "RC4-HMAC;AES-256",
        #             # "channelEncryption": "AES-128-CCM;AES-128-GCM;AES-256-GCM"

        #             $protocolSettings = @{
        #                 smb = @{
        #                     authenticationMethods = "NTLMv2" # Not valid
        #                     channelEncryption = "AES-256-GCM" # Valid
        #                     kerberosTicketEncryption = "AES-256" # Valid
        #                     versions = "SMB3.1.1" #Valid
        #                 }
        #             }

        #             $object = @{
        #                 properties = @{
        #                     protocolSettings = $protocolSettings
        #                 }
        #             }
        #             $payload = ConvertTo-Json -InputObject $object -Depth 100
    
        #             # Should be disallowed by policy, so exception should be thrown.
        #             $httpResponse = Invoke-AzRestMethod `
        #                 -ResourceGroupName $ResourceGroup.ResourceGroupName `
        #                 -ResourceProviderName "Microsoft.Storage" `
        #                 -ResourceType  @('storageAccounts','fileServices') `
        #                 -Name @($name, 'default') `
        #                 -ApiVersion "2022-09-01" `
        #                 -Method "PUT" `
        #                 -Payload $payload
            
        #             if ($httpResponse.StatusCode -eq 200) {
        #                 # Storage Account created
        #             }
        #             # Error response describing why the operation failed.
        #             else {
        #                 throw "Operation failed with message: '$($httpResponse.Content)'"
        #             } 

        #        } | Should -Throw "*disallowed by policy*"
        #     }
        # }

        # It "Should allow compliant Application Gateway with WAF enabled" -Tag "allow-appgw-waf" {
        #     AzTest -ResourceGroup {
        #         param($ResourceGroup)

        #         $random = GenerateRandomString -Length 13
        #         $name = "alztest$Random" 

        #         New-AzStorageAccount `
        #             -ResourceGroupName $ResourceGroup.ResourceGroupName `
        #             -Name $name `
        #             -Location "uksouth" `
        #             -SkuName "Standard_LRS" `
        #             -Kind "StorageV2" `
        #             -MinimumTlsVersion "TLS1_2" `
        #             -AllowBlobPublicAccess $false `
        #             -EnableHttpsTrafficOnly  $true `
        #             -PublicNetworkAccess "Disabled"

        #         {
        #             # "versions": "SMB2.1;SMB3.0;SMB3.1.1",
        #             # "authenticationMethods": "NTLMv2;Kerberos",
        #             # "kerberosTicketEncryption": "RC4-HMAC;AES-256",
        #             # "channelEncryption": "AES-128-CCM;AES-128-GCM;AES-256-GCM"

        #             $protocolSettings = @{
        #                 smb = @{
        #                     authenticationMethods = "Kerberos" # Valid
        #                     channelEncryption = "AES-256-GCM" # Valid
        #                     kerberosTicketEncryption = "AES-256" # Valid
        #                     versions = "SMB3.1.1" # Valid
        #                 }
        #             }

        #             $object = @{
        #                 properties = @{
        #                     protocolSettings = $protocolSettings
        #                 }
        #             }
        #             $payload = ConvertTo-Json -InputObject $object -Depth 100
    
        #             # Should be disallowed by policy, so exception should be thrown.
        #             $httpResponse = Invoke-AzRestMethod `
        #                 -ResourceGroupName $ResourceGroup.ResourceGroupName `
        #                 -ResourceProviderName "Microsoft.Storage" `
        #                 -ResourceType  @('storageAccounts','fileServices') `
        #                 -Name @($name, 'default') `
        #                 -ApiVersion "2022-09-01" `
        #                 -Method "PUT" `
        #                 -Payload $payload
            
        #             if ($httpResponse.StatusCode -eq 200) {
        #                 # Storage Account created
        #             }
        #             # Error response describing why the operation failed.
        #             else {
        #                 throw "Operation failed with message: '$($httpResponse.Content)'"
        #             } 

        #        } | Should -Not -Throw
        #     }
        # }

        It "Should allow compliant Application Gateway with WAF enabled" -Tag "allow-appgw-waf" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "alztest$Random" 

                # Setting up all the requirements for an Application Gateway with WAF enabled
                $NSG = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroup $ResourceGroup -Location "uksouth"
                $Subnet = New-AzVirtualNetworkSubnetConfig -Name "Subnet01" -AddressPrefix 10.0.0.0/24 -NetworkSecurityGroup $NSG
                $VNet = New-AzVirtualNetwork -Name "VNet01" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.0.0.0/16 -Subnet $Subnet
                $VNet = Get-AzVirtualNetwork -Name "VNet01" -ResourceGroupName $ResourceGroup.ResourceGroupName
                $Subnet = Get-AzVirtualNetworkSubnetConfig -Name "Subnet01" -VirtualNetwork $VNet 
                $GatewayIPconfig = New-AzApplicationGatewayIPConfiguration -Name "GatewayIp01" -Subnet $Subnet
                $Pool = New-AzApplicationGatewayBackendAddressPool -Name "Pool01" -BackendIPAddresses 10.10.10.1, 10.10.10.2, 10.10.10.3
                $PoolSetting = New-AzApplicationGatewayBackendHttpSetting -Name "PoolSetting01"  -Port 80 -Protocol "Http" -CookieBasedAffinity "Disabled"
                $FrontEndPort = New-AzApplicationGatewayFrontendPort -Name "FrontEndPort01"  -Port 80
                $PublicIp = New-AzPublicIpAddress -ResourceGroupName $ResourceGroup.ResourceGroupName -Name "PublicIpName01" -Location "uksouth" -AllocationMethod "Static"
                $FrontEndIpConfig = New-AzApplicationGatewayFrontendIPConfig -Name "FrontEndConfig01" -PublicIPAddress $PublicIp
                $Listener = New-AzApplicationGatewayHttpListener -Name "ListenerName01"  -Protocol "Http" -FrontendIpConfiguration $FrontEndIpConfig -FrontendPort $FrontEndPort
                $Rule = New-AzApplicationGatewayRequestRoutingRule -Name "Rule01" -RuleType basic -BackendHttpSettings $PoolSetting -HttpListener $Listener -BackendAddressPool $Pool -Priority 101
                $Sku = New-AzApplicationGatewaySku -Name "WAF_v2" -Tier WAF_v2 -Capacity 1
                $wafconfig = New-AzApplicationGatewayWebApplicationFirewallConfiguration -Enabled $true -FirewallMode "Detection" -RuleSetType "OWASP" -RuleSetVersion "3.0" -RequestBodyCheck $true -MaxRequestBodySize 10000000 -FileUploadLimit 10000000 -ResourceGroupName $ResourceGroup.ResourceGroupName -Name "WAFConfig01"

                # Deploying the compliant Application Gateway with WAF enabled
                New-AzApplicationGateway `
                    -Name $name `
                    -ResourceGroupName $ResourceGroup.ResourceGroupName `
                    -Location "uksouth" `
                    -BackendAddressPools $Pool `
                    -BackendHttpSettingsCollection $PoolSetting `
                    -FrontendIpConfigurations $FrontEndIpConfig `
                    -GatewayIpConfigurations $GatewayIpConfig `
                    -FrontendPorts $FrontEndPort `
                    -HttpListeners $Listener `
                    -RequestRoutingRules $Rule `
                    -Sku $Sku `
                    -WebApplicationFirewallConfig $wafconfig

            } | Should -Not -Throw
        }
    }
}
