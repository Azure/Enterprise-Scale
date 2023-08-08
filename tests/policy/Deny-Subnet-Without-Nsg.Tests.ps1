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

Describe "Testing policy 'Deny-Subnet-Without-Nsg'" -Tag "deny-subnet-nsg" {

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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-Subnet-Without-Nsg' }
        New-AzPolicyAssignment -Name "TDeny-Subnet-NSG" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    Context "Test NSG on Virtual Network when created or updated" -Tag "deny-subnet-nsg" {

        It "Should deny non-compliant Virtual Network without NSG" -Tag "deny-subnet-nsg" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "vnet-$Random" 

                # Setting up all the requirements for a Virtual Network with no NSG enabled
                $Subnet = New-AzVirtualNetworkSubnetConfig -Name "Subnet01" -AddressPrefix 10.0.0.0/24 
                
                # Deploying the compliant Virtual Network with NSG enabled
                {
                    New-AzVirtualNetwork -Name $name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.0.0.0/16 -Subnet $Subnet

               } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should allow compliant Virtual Network without NSG but excluded subnet" -Tag "allow-subnet-nsg" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "vnet-$Random" 

                # Setting up all the requirements for an Virtual Network with NSG enabled
                $Subnet = New-AzVirtualNetworkSubnetConfig -Name "AzureFirewallSubnet" -AddressPrefix 10.0.1.0/24

                # Deploying the compliant a Virtual Network with no NSG enabled
                {
                    New-AzVirtualNetwork -Name $name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.0.0.0/16 -Subnet $Subnet

                } | Should -Not -Throw
            }
        }

        It "Should allow compliant Virtual Network with NSG" -Tag "allow-subnet-nsg" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "vnet-$Random" 

                # Setting up all the requirements for an Virtual Network with NSG enabled
                $NSG = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth"
                $Subnet = New-AzVirtualNetworkSubnetConfig -Name "Subnet01" -AddressPrefix 10.0.0.0/24 -NetworkSecurityGroup $NSG

                # Deploying the compliant Virtual Network with NSG enabled
                {
                    New-AzVirtualNetwork -Name $name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.0.0.0/16 -Subnet $Subnet

                } | Should -Not -Throw
            }
        }
    }

    AfterAll {
        Remove-AzPolicyAssignment -Name "TDeny-Subnet-NSG" -Scope $mangementGroupScope -Confirm:$false
    }
}
