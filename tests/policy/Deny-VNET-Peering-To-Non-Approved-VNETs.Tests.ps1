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

Describe "Testing policy 'Deny-VNET-Peering-To-Non-Approved-VNETs'" -Tag "deny-vnet-peering" {

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

        ### Had to move the assignment into the test, as we need to dynamically generate the allowedVnets parameter - this code remains for the valid criteria
        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-VNET-Peering-To-Non-Approved-VNETs' }
        $allowedVnets = @("ApprovedVnet01", "ApprovedVnet02")
        $parameters = @{'allowedVnets'=($allowedVnets)}
        New-AzPolicyAssignment -Name "TDeny-Vnet-BadPeering" -Scope $mangementGroupScope -PolicyDefinition $definition -PolicyParameterObject $parameters

    }

    Context "Test same subscription peering on Virtual Network when created or updated" -Tag "deny-vnet-peering" {

        It "Should deny non-compliant Virtual Network with peering in same subscription" -Tag "deny-vnet-peering" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $NSG1 = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth"
                $Subnet1 = New-AzVirtualNetworkSubnetConfig -Name "subnet01" -AddressPrefix 10.1.0.0/24 -NetworkSecurityGroup $NSG1
                $vnet1 = New-AzVirtualNetwork -Name 'myVnet1' -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.1.0.0/16 -Subnet $Subnet1

                $NSG2 = New-AzNetworkSecurityGroup -Name "nsg2" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth"
                $Subnet2 = New-AzVirtualNetworkSubnetConfig -Name "subnet02" -AddressPrefix 10.2.0.0/24 -NetworkSecurityGroup $NSG2
                $vnet2 = New-AzVirtualNetwork -Name 'myVnet2' -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.2.0.0/16 -Subnet $Subnet2

                {

                    # Peer VNet1 to VNet2.
                    Add-AzVirtualNetworkPeering -Name 'myVnet1ToMyVnet2' -VirtualNetwork $vnet1 -RemoteVirtualNetworkId $vnet2.Id

                    # Peer VNet2 to VNet1.
                    Add-AzVirtualNetworkPeering -Name 'myVnet2ToMyVnet1' -VirtualNetwork $vnet2 -RemoteVirtualNetworkId $vnet1.Id

                } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should allow compliant Virtual Network with peering in same subscription" -Tag "allow-vnet-peering" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                # Moved the assignment into the test, as we need to dynamically generate the allowedVnets parameter - need the resource group name to do this
                $mangementGroupScope = "/providers/Microsoft.Management/managementGroups/$esCompanyPrefix-corp"

                $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-VNET-Peering-To-Non-Approved-VNETs' }
                $subscriptionID = $env:SUBSCRIPTION_ID
                $rgName = $ResourceGroup.ResourceGroupName
                $allowedVnets = @(
                    "/subscriptions/$subscriptionID/resourceGroups/$rgName/providers/Microsoft.Network/virtualNetworks/ApprovedVnet01",
                    "/subscriptions/$subscriptionID/resourceGroups/$rgName/providers/Microsoft.Network/virtualNetworks/ApprovedVnet02"
                    )
                $parameters = @{'allowedVnets'=($allowedVnets)}
                #Set-AzPolicyAssignment -Name "TDeny-Vnet-BadPeering" -PolicyParameterObject $parameters
                New-AzPolicyAssignment -Name "TDeny-Vnet-BadPeering" -Scope $mangementGroupScope -PolicyDefinition $definition -PolicyParameterObject $parameters

                $NSG1 = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth"
                $Subnet1 = New-AzVirtualNetworkSubnetConfig -Name "subnet01" -AddressPrefix 10.1.0.0/24 -NetworkSecurityGroup $NSG1
                $vnet1 = New-AzVirtualNetwork -Name 'ApprovedVnet01' -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.1.0.0/16 -Subnet $Subnet1

                $NSG2 = New-AzNetworkSecurityGroup -Name "nsg2" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth"
                $Subnet2 = New-AzVirtualNetworkSubnetConfig -Name "subnet02" -AddressPrefix 10.2.0.0/24 -NetworkSecurityGroup $NSG2
                $vnet2 = New-AzVirtualNetwork -Name 'ApprovedVnet02' -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.2.0.0/16 -Subnet $Subnet2

                {

                    # Peer VNet1 to VNet2.
                    Add-AzVirtualNetworkPeering -Name 'myVnet1ToMyVnet2' -VirtualNetwork $vnet1 -RemoteVirtualNetworkId $vnet2.Id

                    # Peer VNet2 to VNet1.
                    Add-AzVirtualNetworkPeering -Name 'myVnet2ToMyVnet1' -VirtualNetwork $vnet2 -RemoteVirtualNetworkId $vnet1.Id

                } | Should -Not -Throw
            }
        }
    }

    AfterAll {
       Remove-AzPolicyAssignment -Name "TDeny-Vnet-BadPeering" -Scope $mangementGroupScope -Confirm:$false
    }
}
