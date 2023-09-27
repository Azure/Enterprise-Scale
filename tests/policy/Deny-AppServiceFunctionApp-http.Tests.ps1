[CmdletBinding()]
param (
    [Parameter()][String]$DeploymentConfigPath = "./src/data/eslzArm.test.deployment.json",
    [Parameter()][String]$esCompanyPrefix
)

Import-Module -Name Az.Websites
Import-Module -Name Az.Resources
Import-Module "$($PSScriptRoot)/../../tests/utils/Policy.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Rest.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Test.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Generic.Utils.psm1" -Force

Describe "Testing policy 'Deny-AppServiceFunctionApp-http'" -Tag "deny-appservice-function-http" {

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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-AppServiceFunctionApp-http' }
        New-AzPolicyAssignment -Name "TDeny-ASFunc-http" -Scope $mangementGroupScope -PolicyDefinition $definition

    }

    # Create or update App Service is actually the same PUT request, hence testing create covers update as well.
    Context "Test HTTPS enabled on App Service - Function when created or updated" -Tag "deny-appservice-function-http" {
        
        It "Should deny non-compliant App Services - Function - Windows" -Tag "deny-noncompliant-appservice" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $object = @{
                    kind = "functionapp"
                    properties = @{
                        httpsOnly = false
                    }
                    location = "uksouth"
                }

                $payload = ConvertTo-Json -InputObject $object -Depth 100

                # Should be disallowed by policy, so exception should be thrown.
                {
                    $httpResponse = Invoke-AzRestMethod `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -ResourceProviderName "Microsoft.Web" `
                        -ResourceType "sites" `
                        -Name "testAppServicefunc01" `
                        -ApiVersion "2022-03-01" `
                        -Method "PUT" `
                        -Payload $payload
            
                    if ($httpResponse.StatusCode -eq 200) {
                        # App Service - API created
                    }
                    elseif ($httpResponse.StatusCode -eq 202) {
                        Write-Information "==> Async deployment started"
                    } throw "Operation error: '$($httpResponse.Content)'"
                    # Error response describing why the operation failed.
                    else {
                        throw "Operation failed with message: '$($httpResponse.Content)'"
                    }              
                } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should deny non-compliant App Services - Function - Linux" -Tag "deny-noncompliant-appservice" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $object = @{
                    kind = "functionapp,linux"
                    properties = @{
                        httpsOnly = false
                    }
                    location = "uksouth"
                }

                $payload = ConvertTo-Json -InputObject $object -Depth 100

                # Should be disallowed by policy, so exception should be thrown.
                {
                    $httpResponse = Invoke-AzRestMethod `
                        -ResourceGroupName $ResourceGroup.ResourceGroupName `
                        -ResourceProviderName "Microsoft.Web" `
                        -ResourceType "sites" `
                        -Name "testAppServicefunc02" `
                        -ApiVersion "2022-03-01" `
                        -Method "PUT" `
                        -Payload $payload
            
                if ($httpResponse.StatusCode -eq 200) {
                    # App Service - API created
                }
                elseif ($httpResponse.StatusCode -eq 202) {
                    Write-Information "==> Async deployment started"
                } throw "Operation error: '$($httpResponse.Content)'"
                # Error response describing why the operation failed.
                else {
                    throw "Operation failed with message: '$($httpResponse.Content)'"
                }              
                } | Should -Throw "*disallowed by policy*"
            }
        }        
    }
    
    AfterAll {
        Remove-AzPolicyAssignment -Name "TDeny-ASFunc-http" -Scope $mangementGroupScope -Confirm:$false
    }
}