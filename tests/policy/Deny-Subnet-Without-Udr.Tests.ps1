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

Describe "Testing policy 'Deny-Subnet-Without-Udr'" -Tag "deny-subnet-udr" {

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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-Subnet-Without-Udr' }
        New-AzPolicyAssignment -Name "TDeny-Subnet-UDR" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    Context "Test UDR on Virtual Network when created or updated" -Tag "deny-subnet-udr" {

        It "Should deny non-compliant Virtual Network without UDR" -Tag "deny-subnet-udr" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "vnet-$Random" 

                # Setting up all the requirements for an Virtual Network without UDR
                $NSG = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth"
                $Subnet = New-AzVirtualNetworkSubnetConfig -Name "Subnet01" -AddressPrefix 10.0.0.0/24 -NetworkSecurityGroup $NSG
                
                # Deploying the compliant Virtual Network without UDR
                {
                    New-AzVirtualNetwork -Name $name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.0.0.0/16 -Subnet $Subnet

               } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should allow compliant Virtual Network without UDR but excluded subnet" -Tag "allow-subnet-udr" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "vnet-$Random" 

                # Setting up all the requirements for an Virtual Network without UDR
                $rule1 = New-AzNetworkSecurityRuleConfig -Name allowhttpsinbound-rule -Description "Allow HTTPS Inbound" -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 443
                $rule2 = New-AzNetworkSecurityRuleConfig -Name allowGWinbound-rule -Description "Allow Gateway Manager Inbound" -Access Allow -Protocol Tcp -Direction Inbound -Priority 102 -SourceAddressPrefix GatewayManager -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 443
                $rule3 = New-AzNetworkSecurityRuleConfig -Name allowLBinbound-rule -Description "Allow Load Balancer Inbound" -Access Allow -Protocol Tcp -Direction Inbound -Priority 103 -SourceAddressPrefix AzureLoadBalancer -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 443
                $rule4 = New-AzNetworkSecurityRuleConfig -Name allowBH1inbound-rule -Description "Allow Bastion Host Inbound" -Access Allow -Protocol * -Direction Inbound -Priority 104 -SourceAddressPrefix VirtualNetwork -SourcePortRange * -DestinationAddressPrefix VirtualNetwork -DestinationPortRange 8080
                $rule5 = New-AzNetworkSecurityRuleConfig -Name allowBH2inbound-rule -Description "Allow Bastion Host Inbound" -Access Allow -Protocol * -Direction Inbound -Priority 105 -SourceAddressPrefix VirtualNetwork -SourcePortRange * -DestinationAddressPrefix VirtualNetwork -DestinationPortRange 5701
                $rule6 = New-AzNetworkSecurityRuleConfig -Name allowOutbound-rule -Description "Allow Outbound" -Access Allow -Protocol * -Direction Outbound -Priority 101 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange *

                $NSG = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -SecurityRules $rule1,$rule2,$rule3,$rule4,$rule5,$rule6
                $Subnet = New-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet" -AddressPrefix 10.0.1.0/24 -NetworkSecurityGroup $NSG

                # Deploying the compliant Virtual Network without UDR
                {
                    New-AzVirtualNetwork -Name $name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.0.0.0/16 -Subnet $Subnet

                } | Should -Not -Throw
            }
        }

        It "Should allow compliant Virtual Network with UDR" -Tag "allow-subnet-udr" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "vnet-$Random" 

                # Setting up all the requirements for an Virtual Network with UDR
                $Route = New-AzRouteConfig -Name "Route01" -AddressPrefix 10.0.0.0/16 -NextHopType "VnetLocal"
                $RouteTable = New-AzRouteTable -Name "RouteTable01" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -Route $Route
                $NSG = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth"
                $Subnet = New-AzVirtualNetworkSubnetConfig -Name "Subnet01" -AddressPrefix 10.0.0.0/24 -NetworkSecurityGroup $NSG -RouteTable $RouteTable

                # Deploying the compliant Virtual Network with UDR
                {
                    New-AzVirtualNetwork -Name $name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.0.0.0/16 -Subnet $Subnet

                } | Should -Not -Throw
            }
        }
    }

    AfterAll {
        Remove-AzPolicyAssignment -Name "TDeny-Subnet-UDR" -Scope $mangementGroupScope -Confirm:$false
    }
}
