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

Describe "Testing policy 'Deny-UDR-With-Specific-NextHop'" -Tag "deny-subnet-udr" {

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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-UDR-With-Specific-NextHop' }
        New-AzPolicyAssignment -Name "TDeny-Subnet-UDRHop" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    Context "Test specific next hop UDR on Virtual Network when created or updated" -Tag "deny-subnet-udr" {

        It "Should deny non-compliant Virtual Network with specific next hop - Internet" -Tag "deny-subnet-udr" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                # Deploying the compliant Virtual Network without UDR
                {
                    $Route = New-AzRouteConfig -Name "Route01" -NextHopType "Internet" -AddressPrefix 0.0.0.0/0
                    New-AzRouteTable -Name "RouteTable01" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -Route $Route

               } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should deny non-compliant Virtual Network with specific next hop - VirtualNetworkGateway" -Tag "deny-subnet-udr" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                # Deploying the compliant Virtual Network without UDR
                {
                    $Route = New-AzRouteConfig -Name "Route02" -NextHopType "VirtualNetworkGateway" -AddressPrefix 10.1.0.0/24
                    New-AzRouteTable -Name "RouteTable01" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -Route $Route

               } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should allow compliant Virtual Network with UDR to allowed next hop - Vnetlocal" -Tag "allow-subnet-udr" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "vnet-$Random" 

                # Deploying the compliant Virtual Network with UDR
                {
                    # Setting up all the requirements for an Virtual Network with UDR
                    $Route = New-AzRouteConfig -Name "Route03" -AddressPrefix 10.0.0.0/16 -NextHopType "VnetLocal"
                    $RouteTable = New-AzRouteTable -Name "RouteTable01" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -Route $Route
                    $NSG = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth"
                    $Subnet = New-AzVirtualNetworkSubnetConfig -Name "Subnet01" -AddressPrefix 10.0.0.0/24 -NetworkSecurityGroup $NSG -RouteTable $RouteTable

                    New-AzVirtualNetwork -Name $name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.0.0.0/16 -Subnet $Subnet

                } | Should -Not -Throw
            }
        }
    }

    AfterAll {
        Remove-AzPolicyAssignment -Name "TDeny-Subnet-UDRHop" -Scope $mangementGroupScope -Confirm:$false
    }
}
