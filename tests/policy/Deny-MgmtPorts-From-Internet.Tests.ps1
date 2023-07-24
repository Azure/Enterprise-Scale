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

Describe "Testing policy 'Deny-MgmtPorts-From-Internet'" -Tag "deny-mgmtports-from-internet" {

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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-MgmtPorts-From-Internet' }
        New-AzPolicyAssignment -Name "TDeny-MgmtPorts-Internet" -Scope $mangementGroupScope -PolicyDefinition $definition -PolicyParameterObject @{
            "ports" = @("3389", "22")
        }

    }

    # Create or update NSG is actually the same PUT request, hence testing create covers update as well.
    Context "Test open ports NSG is created or updated" -Tag "deny-mgmtports-from-internet-nsg-port" {
        
        It "Should deny non-compliant port '3389'" -Tag "deny-noncompliant-nsg-port" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $networkSecurityGroup = New-AzNetworkSecurityGroup `
                -Name "nsg-test" `
                -ResourceGroupName $ResourceGroup.ResourceGroupName `
                -Location $ResourceGroup.Location

                # Should be disallowed by policy, so exception should be thrown.
                {
                    $networkSecurityGroup | Add-AzNetworkSecurityRuleConfig `
                        -Name RDP-rule `
                        -Description "Allow RDP" `
                        -Access Allow `
                        -Protocol Tcp `
                        -Direction Inbound `
                        -Priority 200 `
                        -SourceAddressPrefix * `
                        -SourcePortRange * `
                        -DestinationAddressPrefix * `
                        -DestinationPortRange 3389 # Incompliant.
                    | Set-AzNetworkSecurityGroup
                } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should deny non-compliant port '3389' inline" -Tag "deny-noncompliant-nsg-port" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                # Should be disallowed by policy, so exception should be thrown.
                {
                    New-AzNetworkSecurityGroup `
                        -Name "nsg-test" `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -Location $ResourceGroup.Location | Add-AzNetworkSecurityRuleConfig `
                        -Name RDP-rule `
                        -Description "Allow RDP" `
                        -Access Allow `
                        -Protocol Tcp `
                        -Direction Inbound `
                        -Priority 200 `
                        -SourceAddressPrefix * `
                        -SourcePortRange * `
                        -DestinationAddressPrefix * `
                        -DestinationPortRange 3389 # Incompliant.
                    | Set-AzNetworkSecurityGroup
                } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should deny non-compliant port range (21-23)" -Tag "deny-noncompliant-nsg-port" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $networkSecurityGroup = New-AzNetworkSecurityGroup `
                -Name "nsg-test" `
                -ResourceGroupName $ResourceGroup.ResourceGroupName `
                -Location $ResourceGroup.Location

                # Should be disallowed by policy, so exception should be thrown.
                {
                    $networkSecurityGroup | Add-AzNetworkSecurityRuleConfig `
                        -Name SSH-rulePlus `
                        -Description "Allow Mgmt" `
                        -Access Allow `
                        -Protocol Tcp `
                        -Direction Inbound `
                        -Priority 200 `
                        -SourceAddressPrefix * `
                        -SourcePortRange * `
                        -DestinationAddressPrefix * `
                        -DestinationPortRange "21-23" # Incompliant.
                    | Set-AzNetworkSecurityGroup
                } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should allow compliant ports (443)" -Tag "allow-compliant-nsg-port" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $networkSecurityGroup = New-AzNetworkSecurityGroup `
                -Name "nsg-test" `
                -ResourceGroupName $ResourceGroup.ResourceGroupName `
                -Location $ResourceGroup.Location

                # Should be disallowed by policy, so exception should be thrown.
                {
                    $networkSecurityGroup | Add-AzNetworkSecurityRuleConfig `
                        -Name web-rule `
                        -Description "Allow Web" `
                        -Access Allow `
                        -Protocol Tcp `
                        -Direction Inbound `
                        -Priority 200 `
                        -SourceAddressPrefix * `
                        -SourcePortRange * `
                        -DestinationAddressPrefix * `
                        -DestinationPortRange 443 # Compliant.
                    | Set-AzNetworkSecurityGroup
                } | Should -Not -Throw
            }
        }

        It "Should deny non-compliant port range (multi-rule)" -Tag "deny-noncompliant-nsg-port" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $networkSecurityGroup = New-AzNetworkSecurityGroup `
                -Name "nsg-test2" `
                -ResourceGroupName $ResourceGroup.ResourceGroupName `
                -Location $ResourceGroup.Location

                # Should be disallowed by policy, so exception should be thrown.
                {
                    $networkSecurityGroup | Add-AzNetworkSecurityRuleConfig `
                        -Name Web-rule `
                        -Description "Allow Web" `
                        -Access Allow `
                        -Protocol Tcp `
                        -Direction Inbound `
                        -Priority 300 `
                        -SourceAddressPrefix * `
                        -SourcePortRange * `
                        -DestinationAddressPrefix * `
                        -DestinationPortRange 443 
                    | Add-AzNetworkSecurityRuleConfig `
                        -Name SSH-rule `
                        -Description "Allow Mgmt" `
                        -Access Allow `
                        -Protocol Tcp `
                        -Direction Inbound `
                        -Priority 310 `
                        -SourceAddressPrefix * `
                        -SourcePortRange * `
                        -DestinationAddressPrefix * `
                        -DestinationPortRange "21-23" # Incompliant.
                    | Set-AzNetworkSecurityGroup
                } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should deny non-compliant port ranges* - API" -Tag "deny-noncompliant-nsg-port" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                #Destination port ranges to test
                $portRanges =  @("23","3388-3390","8080")

                $securityRules = @(
                    @{
                        name = "Web-rule"
                        properties = @{
                            description = "Allow Web"
                            protocol = "Tcp"
                            sourcePortRange = "*"
                            destinationPortRange = "443"
                            sourceAddressPrefix = "*"
                            destinationAddressPrefix = "*"
                            access = "Allow"
                            priority = 300
                            direction = "Inbound"
                        }
                    },
                    @{
                        name = "Multi-rule"
                        properties = @{
                            description = "Allow Mgmt"
                            protocol = "Tcp"
                            sourcePortRange = "*"
                            destinationPortRanges = $portRanges
                            sourceAddressPrefix = "*"
                            destinationAddressPrefix = "*"
                            access = "Allow"
                            priority = 310
                            direction = "Inbound"
                        }
                    }
                )

                $object = @{
                    properties = @{
                        securityRules = $securityRules
                    }
                    location = "uksouth"
                }

                $payload = ConvertTo-Json -InputObject $object -Depth 100

                # Should be disallowed by policy, so exception should be thrown.
                {
                    $httpResponse = Invoke-AzRestMethod `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -ResourceProviderName "Microsoft.Network" `
                        -ResourceType "networkSecurityGroups" `
                        -Name "testNSG98" `
                        -ApiVersion "2022-11-01" `
                        -Method "PUT" `
                        -Payload $payload
            
                if ($httpResponse.StatusCode -eq 200 -or $httpResponse.StatusCode -eq 201) {
                    # NSG created
                }
                # Error response describing why the operation failed.
                else {
                    throw "Operation failed with message: '$($httpResponse.Content)'"
                }              
                } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should allow compliant port ranges* - API" -Tag "allow-compliant-nsg-port" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                #Destination port ranges to test
                $portRanges =  @("23","3390-3392","8080")

                # Create Payload for NSG
                $securityRules = @(
                    @{
                        name = "Web-rule"
                        properties = @{
                            description = "Allow Web2"
                            protocol = "Tcp"
                            sourcePortRange = "*"
                            destinationPortRange = "443"
                            sourceAddressPrefix = "*"
                            destinationAddressPrefix = "*"
                            access = "Allow"
                            priority = 300
                            direction = "Inbound"
                        }
                    },
                    @{
                        name = "Multi-rule"
                        properties = @{
                            description = "Allow Mgmt3"
                            protocol = "Tcp"
                            sourcePortRange = "*"
                            destinationPortRanges = $portRanges
                            sourceAddressPrefix = "*"
                            destinationAddressPrefix = "*"
                            access = "Allow"
                            priority = 310
                            direction = "Inbound"
                        }
                    }
                )

                $object = @{
                    properties = @{
                        securityRules = $securityRules
                    }
                    location = "uksouth"
                }

                $payload = ConvertTo-Json -InputObject $object -Depth 100

                # Should be disallowed by policy, so exception should be thrown.
                {
                    $httpResponse = Invoke-AzRestMethod `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -ResourceProviderName "Microsoft.Network" `
                        -ResourceType "networkSecurityGroups" `
                        -Name "testNSG99" `
                        -ApiVersion "2022-11-01" `
                        -Method "PUT" `
                        -Payload $payload
            
                if ($httpResponse.StatusCode -eq 200 -or $httpResponse.StatusCode -eq 201) {
                    # NSG created
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
        Remove-AzPolicyAssignment -Name "TDeny-MgmtPorts-Internet" -Scope $mangementGroupScope -Confirm:$false
    }
}