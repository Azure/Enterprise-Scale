Describe 'UnitTest-ModifiedPolicies' {
    BeforeAll {
        Import-Module -Name $PSScriptRoot\PolicyPesterTestHelper.psm1 -Force -Verbose

        $ModifiedPolicies = Get-ModifiedPolicies -Verbose
        Write-Warning "These are the modified policies: $($ModifiedPolicies)"
    }

    Context "Validate policy metadata" {

        It "Check policy metadata version exists" {
            $ModifiedPolicies | ForEach-Object {
                $policyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $policyFile = Split-Path $_ -Leaf
                $policyMetadataVersion = $policyJson.properties.metadata.version
                Write-Warning "$($policyFile) - The current metadata version for the PR branch is : $($policyMetadataVersion)"
                $policyMetadataVersion | Should -Not -BeNullOrEmpty

            }
        }

        It "Check policy metadata version is greater than its previous version" {
            $ModifiedPolicies | ForEach-Object {
                $policyFile = Split-Path $_ -Leaf
                $policyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $previousPolicyDefinitionRawUrl = "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/$_"
                $previousPolicyDefinitionOutputFile = "./previous-$policyFile"
                Invoke-WebRequest -Uri $previousPolicyDefinitionRawUrl -OutFile $previousPolicyDefinitionOutputFile
                $PreviousPolicyDefinitionsFile = Get-Content $previousPolicyDefinitionOutputFile -Raw | ConvertFrom-Json
                $PreviousPolicyDefinitionsFileVersion = $PreviousPolicyDefinitionsFile.properties.metadata.version
                Write-Warning "$($policyFile) - The current metadata version for the main branch is : $($PreviousPolicyDefinitionsFileVersion)"
                $policyMetadataVersion = $policyJson.properties.metadata.version
                $policyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $policyMetadataVersion | Should -BeGreaterThan $PreviousPolicyDefinitionsFileVersion

            }
        }

        It "Check policy metadata category exists" {
            $ModifiedPolicies | ForEach-Object {
                $policyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $policyFile = Split-Path $_ -Leaf
                $policyMetadataCategories = $policyJson.properties.metadata.category
                Write-Warning "$($policyFile) - These are the policy metadata categories: $($policyMetadataCategories)"
                $policyMetadataCategories | Should -Not -BeNullOrEmpty
            }
        }

        It "Check policy metadata source is set to Enterprise-Scale repo" {
            $ModifiedPolicies | ForEach-Object {
                $policyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $policyFile = Split-Path $_ -Leaf
                $policyMetadataSource = $policyJson.properties.metadata.source
                Write-Warning "$($policyFile) - This is the policy source link: $($policyMetadataSource)"
                $policyMetadataSource | Should -Be 'https://github.com/Azure/Enterprise-Scale/'
            }
        }

        It "Check policy metadata ALZ Environments are specified for Public, US Gov or China Clouds" {
            $ModifiedPolicies | ForEach-Object {
                $policyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $policyFile = Split-Path $_ -Leaf
                $alzEnvironments = @("AzureCloud", "AzureChinaCloud", "AzureUSGovernment")
                $policyEnvironments = $policyJson.properties.metadata.alzCloudEnvironments
                Write-Warning "$($policyFile) - These are the environments: $($policyEnvironments)"
                $policyJson.properties.metadata.alzCloudEnvironments | Should -BeIn $alzEnvironments
            }
        }
    }
    Context "Validate policy parameters" {
        It 'Check for policy parameters have default values' {
            $ModifiedPolicies | ForEach-Object {
                $policyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $policyFile = Split-Path $_ -Leaf
                $policyParameters = $policyJson.properties.parameters
                if ($policyParameters | Get-Member -MemberType NoteProperty)
                {
                    $parameters = $policyParameters | Get-Member -MemberType NoteProperty | Select-Object -Expand Name
                    Write-Warning "$($policyFile) - These are the params: $($parameters)"
                    $parameters = $policyParameters | Get-Member -MemberType NoteProperty
                    $parameters | ForEach-Object {
                        $key = $_.name
                        $defaultValue = $policyParameters.$key | Get-Member -MemberType NoteProperty | Where-Object Name -EQ "defaultValue"
                        Write-Warning "$($policyFile) - Parameter: $($key) - Default Value: $($defaultValue)"
                        $policyParameters.$key.defaultValue | Should -Not -BeNullOrEmpty
                    }
                }
            }
        }
    }
}
