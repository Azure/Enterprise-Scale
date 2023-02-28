BeforeAll {
    Import-Module -Name $PSScriptRoot\policyunittesthelper.psm1 -Force -Verbose
    Find-Module -Name SemVerPS | Install-Module -Force

    $ModifiedPolicies = Get-ModifiedPolicies -Verbose 
    Write-Warning "These are the modified policies: $($ModifiedPolicies)"
    
    $ModifiedPolicies | ForEach-Object {
        $policyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
        $policyFile = Split-Path $_ -leaf
    }

    git checkout policy-unittests
    $ModifiedPolicies | ForEach-Object {
        $policyJsonMain = Get-Content -Path $_ -Raw | ConvertFrom-Json
        $policyFile = Split-Path $_ -leaf
    }
}

Describe 'UnitTest-ModifiedPolicies' {
    Context "Validate policy metadata" {
        It "Check for valid metadata version" {
            $policyMetadataVersion = $policyJson.properties.metadata.version
            Write-Warning "$($policyFile) - This is the policy metadata version from the main branch: $($policyMetadataVersionMainBranch)"

            $policyMetadataMainBranch = $policyJsonMain.properties.metadata.version
            Write-Warning "$($policyFile) - This is the policy metadata version from the PR branch: $($policyMetadataVersionMainBranch)"
            
            $policyMetadataVersion | Should -Be '1.0.0'
        }

        It "Check policy metadata categories" {
            $policyMetadataCategories = $policyJson.properties.metadata.category
            Write-Warning "$($policyFile) - These are the policy metadata categories: $($policyMetadataCategories)"
            $policyMetadataCategories| Should -Not -BeNullOrEmpty
        }

        It "Check policy metadata source" {
            $policyMetadataSource = $policyJson.properties.metadata.source
            Write-Warning "$($policyFile) - This is the policy source link: $($policyMetadataSource)"
            $policyMetadataSource | Should -BeExactly 'https://github.com/Azure/Enterprise-Scale/'
        }
        
        It "Check policy metadata alzenvironments" {
            $alzEnvironments = @("AzureCloud", "AzureChinaCloud", "AzureUSGovernment")
            $policyEnvironments = $policyJson.properties.metadata.alzCloudEnvironments
            Write-Warning "$($policyFile) - These are the environments: $($policyEnvironments)"
            $policyJson.properties.metadata.alzCloudEnvironments | Should -BeIn $alzEnvironments
        }
    }
    Context "Validate policy parameters" {
        It 'Check for parameter default values' {
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
  
