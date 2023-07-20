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

        It "Should deny non-compliant Application Gateway without WAF enabled" -Tag "deny-appgw-waf" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "alztest$Random" 

                # Setting up all the requirements for an Application Gateway with WAF enabled
                $rule1 = New-AzNetworkSecurityRuleConfig -Name waf-rule -Description "Allow WAF Ports" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange '65200-65535'
                $NSG = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -SecurityRules $rule1
                $Subnet = New-AzVirtualNetworkSubnetConfig -Name "Subnet01" -AddressPrefix 10.0.0.0/24 -NetworkSecurityGroup $NSG
                $VNet = New-AzVirtualNetwork -Name "VNet01" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.0.0.0/16 -Subnet $Subnet
                $VNet = Get-AzVirtualNetwork -Name "VNet01" -ResourceGroupName $ResourceGroup.ResourceGroupName
                $Subnet = Get-AzVirtualNetworkSubnetConfig -Name "Subnet01" -VirtualNetwork $VNet 
                $GatewayIPconfig = New-AzApplicationGatewayIPConfiguration -Name "GatewayIp01" -Subnet $Subnet
                $Pool = New-AzApplicationGatewayBackendAddressPool -Name "Pool01" -BackendIPAddresses 10.10.10.1, 10.10.10.2, 10.10.10.3
                $PoolSetting = New-AzApplicationGatewayBackendHttpSetting -Name "PoolSetting01"  -Port 80 -Protocol "Http" -CookieBasedAffinity "Disabled"
                $FrontEndPort = New-AzApplicationGatewayFrontendPort -Name "FrontEndPort01"  -Port 80
                $PublicIp = New-AzPublicIpAddress -ResourceGroupName $ResourceGroup.ResourceGroupName -Name "PublicIpName01" -Location "uksouth" -AllocationMethod "Static" -Sku Standard
                $FrontEndIpConfig = New-AzApplicationGatewayFrontendIPConfig -Name "FrontEndConfig01" -PublicIPAddress $PublicIp
                $Listener = New-AzApplicationGatewayHttpListener -Name "ListenerName01"  -Protocol "Http" -FrontendIpConfiguration $FrontEndIpConfig -FrontendPort $FrontEndPort
                $Rule = New-AzApplicationGatewayRequestRoutingRule -Name "Rule01" -RuleType basic -BackendHttpSettings $PoolSetting -HttpListener $Listener -BackendAddressPool $Pool -Priority 101
                $Sku = New-AzApplicationGatewaySku -Name Standard_v2 -Tier Standard_v2 -Capacity 1
                $wafconfig = New-AzApplicationGatewayWebApplicationFirewallConfiguration -Enabled $true -FirewallMode "Detection" -RuleSetType "OWASP" -RuleSetVersion "3.0" -RequestBodyCheck $true -MaxRequestBodySizeInKb 128 -FileUploadLimitInMb 2

                # Deploying the compliant Application Gateway with WAF enabled
                {
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

               } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should allow compliant Application Gateway with WAF enabled" -Tag "allow-appgw-waf" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "alztest$Random" 

                # Setting up all the requirements for an Application Gateway with WAF enabled
                $rule1 = New-AzNetworkSecurityRuleConfig -Name waf-rule -Description "Allow WAF Ports" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange '65200-65535'
                $NSG = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -SecurityRules $rule1
                $Subnet = New-AzVirtualNetworkSubnetConfig -Name "Subnet01" -AddressPrefix 10.0.0.0/24 -NetworkSecurityGroup $NSG
                $VNet = New-AzVirtualNetwork -Name "VNet01" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.0.0.0/16 -Subnet $Subnet
                $VNet = Get-AzVirtualNetwork -Name "VNet01" -ResourceGroupName $ResourceGroup.ResourceGroupName
                $Subnet = Get-AzVirtualNetworkSubnetConfig -Name "Subnet01" -VirtualNetwork $VNet 
                $GatewayIPconfig = New-AzApplicationGatewayIPConfiguration -Name "GatewayIp01" -Subnet $Subnet
                $Pool = New-AzApplicationGatewayBackendAddressPool -Name "Pool01" -BackendIPAddresses 10.10.10.1, 10.10.10.2, 10.10.10.3
                $PoolSetting = New-AzApplicationGatewayBackendHttpSetting -Name "PoolSetting01"  -Port 80 -Protocol "Http" -CookieBasedAffinity "Disabled"
                $FrontEndPort = New-AzApplicationGatewayFrontendPort -Name "FrontEndPort01"  -Port 80
                $PublicIp = New-AzPublicIpAddress -ResourceGroupName $ResourceGroup.ResourceGroupName -Name "PublicIpName01" -Location "uksouth" -AllocationMethod "Static" -Sku Standard
                $FrontEndIpConfig = New-AzApplicationGatewayFrontendIPConfig -Name "FrontEndConfig01" -PublicIPAddress $PublicIp
                $Listener = New-AzApplicationGatewayHttpListener -Name "ListenerName01"  -Protocol "Http" -FrontendIpConfiguration $FrontEndIpConfig -FrontendPort $FrontEndPort
                $Rule = New-AzApplicationGatewayRequestRoutingRule -Name "Rule01" -RuleType basic -BackendHttpSettings $PoolSetting -HttpListener $Listener -BackendAddressPool $Pool -Priority 101
                $Sku = New-AzApplicationGatewaySku -Name "WAF_v2" -Tier WAF_v2 -Capacity 1
                $wafconfig = New-AzApplicationGatewayWebApplicationFirewallConfiguration -Enabled $true -FirewallMode "Detection" -RuleSetType "OWASP" -RuleSetVersion "3.0" -RequestBodyCheck $true -MaxRequestBodySizeInKb 128 -FileUploadLimitInMb 2

                # Deploying the compliant Application Gateway with WAF enabled
                {
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

    AfterAll {
        Remove-AzPolicyAssignment -Name "TDeny-AppGw-WAF" -Scope $mangementGroupScope -Confirm:$false
    }
}
