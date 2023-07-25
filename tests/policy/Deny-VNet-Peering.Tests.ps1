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

Describe "Testing policy 'Deny-VNet-Peering'" -Tag "deny-vnet-peering" {

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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-VNet-Peering' }
        New-AzPolicyAssignment -Name "TDeny-Vnet-Peering" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    Context "Test same subscription peering on Virtual Network when created or updated" -Tag "deny-vnet-peering" {

        It "Should deny non-compliant Virtual Network with peering in same subscription" -Tag "deny-vnet-peering" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "vnet-$Random"

                $NSG1 = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth"
                $Subnet1 = New-AzVirtualNetworkSubnetConfig -Name "subnet01" -AddressPrefix 10.1.0.0/24 -NetworkSecurityGroup $NSG1
                $vnet1 = New-AzVirtualNetwork -Name 'myVnet1' -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.1.0.0/16 -Subnet $Subnet1

                $NSG2 = New-AzNetworkSecurityGroup -Name "nsg2" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth"
                $Subnet2 = New-AzVirtualNetworkSubnetConfig -Name "subnet02" -AddressPrefix 10.2.0.0/24 -NetworkSecurityGroup $NSG2
                $vnet2 = New-AzVirtualNetwork -Name 'myVnet2' -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.2.0.0/16 -Subnet $Subnet2

                # Deploying the compliant Virtual Network without UDR
                {

                    # Peer VNet1 to VNet2.
                    Add-AzVirtualNetworkPeering -Name 'myVnet1ToMyVnet2' -VirtualNetwork $vnet1 -RemoteVirtualNetworkId $vnet2.Id

                    # Peer VNet2 to VNet1.
                    Add-AzVirtualNetworkPeering -Name 'myVnet2ToMyVnet1' -VirtualNetwork $vnet2 -RemoteVirtualNetworkId $vnet1.Id

                } | Should -Throw "*disallowed by policy*"
            }
        }

        # It "Should deny non-compliant Virtual Network with specific next hop - VirtualNetworkGateway" -Tag "deny-subnet-udr" {
        #     AzTest -ResourceGroup {
        #         param($ResourceGroup)

        #         $random = GenerateRandomString -Length 13
        #         $name = "vnet-$Random" 
               
        #         # Deploying the compliant Virtual Network without UDR
        #         {
        #             $Route = New-AzRouteConfig -Name "Route02" -NextHopType "VirtualNetworkGateway" -AddressPrefix 10.1.0.0/24
        #             $RouteTable = New-AzRouteTable -Name "RouteTable01" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -Route $Route
        #             # $NSG = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth"
        #             # $Subnet = New-AzVirtualNetworkSubnetConfig -Name "Subnet01" -AddressPrefix 10.0.0.0/24 -NetworkSecurityGroup $NSG -RouteTable $RouteTable

        #             # New-AzVirtualNetwork -Name $name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.0.0.0/16 -Subnet $Subnet

        #        } | Should -Throw "*disallowed by policy*"
        #     }
        # }

        # It "Should allow compliant Virtual Network with UDR to allowed next hop - Vnetlocal" -Tag "allow-subnet-udr" {
        #     AzTest -ResourceGroup {
        #         param($ResourceGroup)

        #         $random = GenerateRandomString -Length 13
        #         $name = "vnet-$Random" 

        #         # Setting up all the requirements for an Virtual Network with UDR
        #         $Route = New-AzRouteConfig -Name "Route03" -AddressPrefix 10.0.0.0/16 -NextHopType "VnetLocal"
        #         $RouteTable = New-AzRouteTable -Name "RouteTable01" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -Route $Route
        #         $NSG = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth"
        #         $Subnet = New-AzVirtualNetworkSubnetConfig -Name "Subnet01" -AddressPrefix 10.0.0.0/24 -NetworkSecurityGroup $NSG -RouteTable $RouteTable

        #         # Deploying the compliant Virtual Network with UDR
        #         {
        #             New-AzVirtualNetwork -Name $name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.0.0.0/16 -Subnet $Subnet

        #         } | Should -Not -Throw
        #     }
        # }
    }

    AfterAll {
        Remove-AzPolicyAssignment -Name "TDeny-Vnet-Peering" -Scope $mangementGroupScope -Confirm:$false
    }
}
