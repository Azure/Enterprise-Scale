[CmdletBinding()]
param (
    [Parameter()][String]$DeploymentConfigPath = "./src/data/eslzArm.test.deployment.json",
    [Parameter()][String]$esCompanyPrefix
)

Import-Module -Name Az.PostgreSql
Import-Module -Name Az.Resources
Import-Module "$($PSScriptRoot)/../../tests/utils/Policy.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Rest.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Test.Utils.psm1" -Force
Import-Module "$($PSScriptRoot)/../../tests/utils/Generic.Utils.psm1" -Force

Describe "Testing policy 'Deny-PostgreSql-http'" -Tag "deny-pgsql-http" {

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

        $definition = Get-AzPolicyDefinition | Where-Object { $_.Name -eq 'Deny-PostgreSql-http' }
        New-AzPolicyAssignment -Name "TDeny-PgSql-http" -Scope $mangementGroupScope -PolicyDefinition $definition

        # Register the resource provider for PostgreSQL
        $rp = Get-AzResourceProvider -ListAvailable |
            Where-Object -Property ProviderNamespace -Like -Value "Microsoft.DBforPostgreSQL"

        if ($rp.RegistrationState -eq "NotRegistered"){
                Register-AzResourceProvider -ProviderNamespace Microsoft.DBforPostgreSQL 
            }

    }

    Context "Test SSL on PostgreSQL database servers when created or updated" -Tag "deny-pgsql-http" {

        It "Should deny non-compliant SSL on PostgreSQL database servers - SSL Disabled" -Tag "deny-pgsql-http" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $password = GeneratePasswordString -Length 20  | ConvertTo-Securestring -AsPlainText -Force
                $name = "mysql-$Random" 

                {
                    New-AzPostgreSqlServer -Name $name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AdministratorUserName mysql_test -AdministratorLoginPassword $password -SslEnforcement Disabled -MinimalTlsVersion 'TLS1_2' -Sku GP_Gen5_2

                } | Should -Throw "*disallowed by policy*"
            }
        }

        It "Should deny non-compliant SSL on PostgreSQL database servers - TLS Version" -Tag "deny-pgsql-http" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $password = GeneratePasswordString -Length 20  | ConvertTo-Securestring -AsPlainText -Force
                $name = "mysql-$Random" 

                {
                    New-AzPostgreSqlServer -Name $name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AdministratorUserName mysql_test -AdministratorLoginPassword $password -SslEnforcement 'Enabled' -MinimalTlsVersion 'TLS1_1' -Sku GP_Gen5_2

                } | Should -Throw "*disallowed by policy*"
            }  
        }

        It "Should allow compliant SSL on PostgreSQL database servers" -Tag "allow-pgsql-http" {
            AzTest -ResourceGroup {
                param($ResourceGroup)

                $random = GenerateRandomString -Length 13
                $password = GeneratePasswordString -Length 20  | ConvertTo-Securestring -AsPlainText -Force
                $name = "mysql-$Random" 

                {
                    New-AzPostgreSqlServer -Name $name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "uksouth" -AdministratorUserName mysql_test -AdministratorLoginPassword $password -SslEnforcement 'Enabled' -MinimalTlsVersion 'TLS1_2' -Sku GP_Gen5_2

               } | Should -Not -Throw
            }
        }
    }

    AfterAll {
        Remove-AzPolicyAssignment -Name "TDeny-PgSql-http" -Scope $mangementGroupScope -Confirm:$false
    }
}
