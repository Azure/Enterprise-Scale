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

Describe "Testing policy 'Deny-Subnet-Without-Penp'" -Tag "deny-subnet-penp" {

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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-Subnet-Without-Penp' }
        New-AzPolicyAssignment -Name "TDeny-Subnet-PENP" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    Context "Test Private Endpoint Network Policies on Virtual Network when created or updated" -Tag "deny-subnet-penp" {

        It "Should deny non-compliant Virtual Network without Privatee Endpoint Network Policies" -Tag "deny-subnet-penp" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "vnet-$Random" 

                # Setting up all the requirements for a Virtual Network without Privatee Endpoint Network Policies
                $NSG = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth"
                $Subnet = New-AzVirtualNetworkSubnetConfig -Name "Subnet01" -AddressPrefix 10.0.0.0/24 -NetworkSecurityGroup $NSG
                
                # Deploying the compliant Virtual Network without Privatee Endpoint Network Policies
                {
                    New-AzVirtualNetwork -Name $name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.0.0.0/16 -Subnet $Subnet

               } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should allow compliant Virtual Network with Private Endpoint Network Policies" -Tag "allow-subnet-penp" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $name = "vnet-$Random" 

                # Setting up all the requirements for an Virtual Network with Private Endpoint Network Policies
                $NSG = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth"
                $Subnet = New-AzVirtualNetworkSubnetConfig -Name "Subnet01" -AddressPrefix 10.0.0.0/24 -NetworkSecurityGroup $NSG -PrivateEndpointNetworkPoliciesFlag "Enabled"

                # Deploying the compliant Virtual Network without Privatee Endpoint Network Policies
                {
                    New-AzVirtualNetwork -Name $name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AddressPrefix 10.0.0.0/16 -Subnet $Subnet

                } | Should -Not -Throw
            }
        }
    }

    AfterAll {
        Remove-AzPolicyAssignment -Name "TDeny-Subnet-PENP" -Scope $mangementGroupScope -Confirm:$false
    }
}
