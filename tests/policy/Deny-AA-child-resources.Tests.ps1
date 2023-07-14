[CmdletBinding()]
param (
    [Parameter()][String]$DeploymentConfigPath = "./src/data/eslzArm.test.deployment.json",
    [Parameter()][String]$esCompanyPrefix
)

Import-Module -Name Az.Automation
Import-Module -Name Az.Resources
Import-Module "$($PSScriptRoot)/../../tests/utils/Policy.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Rest.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Test.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Generic.Utils.psm1" -Force

Describe "Testing policy 'Deny-AA-child-resources'" -Tag "deny-automation-children" {

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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-AA-child-resources' }
        New-AzPolicyAssignment -Name "TDeny-AA-child" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    Context "Test adding child resources on Automation Account when created or updated" -Tag "deny-automation-children" {

        # TEST TEST TEST
        It "Should allow compliant Automation Account" -Tag "deny-noncompliant-automation" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 15
                $name = "ALZTest$Random"

                {
                    $aa = New-AzAutomationAccount `
                       -ResourceGroupName $ResourceGroup.ResourceGroupName `
                       -Name "ContosoAA001" `
                       -Location "uksouth" `
                       -DisablePublicNetworkAccess
                       
               } | Should -Not -Throw
            }
        }
        
        It "Should deny non-compliant Automation Account - Runbook" -Tag "deny-noncompliant-automation" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 15
                $name = "ALZTest$Random"

                {
                    $aa = New-AzAutomationAccount `
                       -ResourceGroupName $ResourceGroup.ResourceGroupName `
                       -Name $name `
                       -Location "uksouth" `
                       -DisablePublicNetworkAccess

                    New-AzAutomationRunbook `
                          -ResourceGroupName $ResourceGroup.ResourceGroupName `
                          -AutomationAccountName $aa.AutomationAccountName `
                          -Name "ContosoRunbook001" `
                          -Type "PowerShell" 
                       
               } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should deny non-compliant Automation Account - Runbook - via API" -Tag "deny-noncompliant-automation" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                # Should be disallowed by policy, so exception should be thrown.
                {
                    $sku = @{
                        name = "Free"
                    }
    
                    $random = GenerateRandomString -Length 15
                    $name = "ALZTest$Random" 
    
                    $object = @{
                        name = $name
                        properties = @{
                            sku = $sku
                            publicNetworkAccess = $false
                        }
                        location = "uksouth"
                    }
                    $payload = ConvertTo-Json -InputObject $object -Depth 100

                    $httpResponse = Invoke-AzRestMethod `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -ResourceProviderName "Microsoft.Automation" `
                        -ResourceType "automationAccounts" `
                        -Name $name `
                        -ApiVersion "2021-06-22" `
                        -Method "PUT" `
                        -Payload $payload
            
                    if ($httpResponse.StatusCode -eq 200 -or $httpResponse.StatusCode -eq 201) {
                        # Automation Account created
                    }
                    else {
                        throw "Operation failed with message: '$($httpResponse.Content)'"
                    }              

                    $object = @{
                        name = "ContosoRunbook001"
                        properties = @{
                            runbookType = $false
                        }
                    }
                    $payload = ConvertTo-Json -InputObject $object -Depth 100

                    $httpResponse = Invoke-AzRestMethod `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -ResourceProviderName "Microsoft.Automation" `
                        -ResourceType @('automationAccounts','runbooks') `
                        -Name @($name,'ContosoRunbook001') `
                        -ApiVersion "2019-06-01" `
                        -Method "PUT" `
                        -Payload $payload
            
                    if ($httpResponse.StatusCode -eq 200 -or $httpResponse.StatusCode -eq 201) {
                        # Automation Account - Runbook created
                    }
                    else {
                        throw "Operation failed with message: '$($httpResponse.Content)'"
                    }

                } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should deny non-compliant Automation Account - Variable" -Tag "deny-noncompliant-automation" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 15
                $name = "ALZTest$Random"

                {
                    New-AzAutomationAccount `
                       -ResourceGroupName $ResourceGroup.ResourceGroupName `
                       -Name $name `
                       -Location "uksouth" `
                       -DisablePublicNetworkAccess

                    New-AzAutomationVariable `
                          -ResourceGroupName $ResourceGroup.ResourceGroupName `
                          -AutomationAccountName $name `
                          -Name "ContosoVariable001" `
                          -Value "somestring" `
                          -Encrypted $False
                       
               } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should deny non-compliant Automation Account - Variable - via API" -Tag "deny-noncompliant-automation" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                # Should be disallowed by policy, so exception should be thrown.
                {
                    $sku = @{
                        name = "Free"
                    }
    
                    $random = GenerateRandomString -Length 15
                    $name = "ALZTest$Random" 
    
                    $object = @{
                        name = $name
                        properties = @{
                            sku = $sku
                            publicNetworkAccess = $false
                        }
                        location = "uksouth"
                    }
                    $payload = ConvertTo-Json -InputObject $object -Depth 100

                    $httpResponse = Invoke-AzRestMethod `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -ResourceProviderName "Microsoft.Automation" `
                        -ResourceType "automationAccounts" `
                        -Name $name `
                        -ApiVersion "2021-06-22" `
                        -Method "PUT" `
                        -Payload $payload
            
                    if ($httpResponse.StatusCode -eq 200 -or $httpResponse.StatusCode -eq 201) {
                        # Automation Account created
                    }
                    else {
                        throw "Operation failed with message: '$($httpResponse.Content)'"
                    }              

                    $object = @{
                        name = "ContosoVariable001"
                        properties = @{
                            value = "somevalue"
                            isEncrypted = $false
                        }
                    }
                    $payload = ConvertTo-Json -InputObject $object -Depth 100

                    $httpResponse = Invoke-AzRestMethod `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -ResourceProviderName "Microsoft.Automation" `
                        -ResourceType @('automationAccounts','variables') `
                        -Name @($name,'ContosoVariable001') `
                        -ApiVersion "2019-06-01" `
                        -Method "PUT" `
                        -Payload $payload
            
                    if ($httpResponse.StatusCode -eq 200 -or $httpResponse.StatusCode -eq 201) {
                        # Automation Account - Runbook created
                    }
                    else {
                        throw "Operation failed with message: '$($httpResponse.Content)'"
                    }

                } | Should -Throw "*disallowed by policy*"
            }
        }
    }

}