Describe 'UnitTest-ModifiedPolicies' {
    BeforeAll {
        Import-Module -Name $PSScriptRoot\policyunittesthelper.psm1 -Force -Verbose
        Find-Module -Name SemVerPS | Install-Module -Force

        $ModifiedPolicies = Get-ModifiedPolicies -Verbose
        Write-Warning "These are the modified policies: $($ModifiedPolicies)"
    }

    Context "Validate policy metadata" {
        It "Check for valid metadata version" {
            $policyMetadataVersions =  @()
            $ModifiedPolicies | ForEach-Object {
                $policyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $policyFile = Split-Path $_ -Leaf
                $policyMetadataVersions += $policyJson.properties.metadata.version
                foreach ($policyMetadataVersion in $policyMetadataVersions) {
                    Write-Warning "$($policyFile) - This is the policy metadata version for the PR branch: $($policyMetadataVersion)"
                }
            }

            $policyMetadataVersionsMainBranch =  @()
            git checkout policy-unittests
            $ModifiedPolicies | ForEach-Object {
                $policyJsonMain = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $policyMetadataVersionsMainBranch += $policyJsonMain.properties.metadata.version
                foreach ($policyMetadataVersionMainBranch in $policyMetadataVersionsMainBranch) {
                    Write-Warning "$($policyFile) - This is the policy metadata version for the main branch: $($policyMetadataVersionMainBranch)"
                }
            }
            # ([version]$policyMetadataVersion) | Should -BeGreaterThan ([version]$policyMetadataVersionMainBranch)
        }

        It "Check policy metadata categories" {
            git checkout testing
            $ModifiedPolicies | ForEach-Object {
                $policyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $policyFile = Split-Path $_ -Leaf
                $policyMetadataCategories = $policyJson.properties.metadata.category
                Write-Warning "$($policyFile) - These are the policy metadata categories: $($policyMetadataCategories)"
                $policyMetadataCategories | Should -Not -BeNullOrEmpty
            }
        }

        It "Check policy metadata source" {
            $ModifiedPolicies | ForEach-Object {
                $policyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $policyFile = Split-Path $_ -Leaf
                $policyMetadataSource = $policyJson.properties.metadata.source
                Write-Warning "$($policyFile) - This is the policy source link: $($policyMetadataSource)"
                $policyMetadataSource | Should -Be 'https://github.com/Azure/Enterprise-Scale/'
            }
        }

        It "Check policy metadata alzenvironments" {
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
        It 'Check for parameter default values' {
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