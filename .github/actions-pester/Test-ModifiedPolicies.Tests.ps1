BeforeAll {
    Import-Module -Name $PSScriptRoot\policyunittesthelper.psm1 -Force -Verbose
}

Describe 'UnitTest-ModifiedPolicies' {
    Context "Validate policy metadata" {
        It 'Check for valid metadata key-pair values' {
            
            $NewPolicies = Get-ModifiedPolicies -Policy_Dir "C:\Repos\ALZ\Enterprise-Scale\src\resources\Microsoft.Authorization\policyDefinitions" -Verbose
            
            Write-Warning "These are the new policies: $($NewPolicies)"

            $NewPolicies | ForEach-Object {
                $policy = Get-Content -Path $_ -Raw | ConvertFrom-Json
                
                $policy.properties.metadata.version | Should -Be '1.0.0'
                
                $policy.properties.metadata.category | Should -Not -BeNullOrEmpty
                
                $policy.properties.metadata.source | Should -BeExactly 'https://github.com/Azure/Enterprise-Scale/'
                
                $alzEnvironments = @("AzureCloud", "AzureChinaCloud", "AzureUSGovernment")
                $policy.properties.metadata.alzCloudEnvironments | Should -BeIn $alzEnvironments
            }
        }
    }
    Context "Validate policy parameters" {
        It 'Check for parameter default values' {
            $NewPolicies = Get-ModifiedPolicies -Policy_Dir "C:\Repos\ALZ\Enterprise-Scale\src\resources\Microsoft.Authorization\policyDefinitions" -Verbose
            
            $NewPolicies | ForEach-Object {
                $policy = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $policyParameters = $policy.properties.parameters
                # 
                if ($policyParameters | Get-Member -MemberType NoteProperty)
                {
                    $parameters = $policyParameters | Get-Member -MemberType NoteProperty | Select-Object -Expand Name
                    Write-Warning "These are the params: $($parameters)"
                    $parameters = $policyParameters | Get-Member -MemberType NoteProperty
                    $parameters | ForEach-Object {
                        $key = $_.name
                        $defaultValue = $policyParameters.$key | Get-Member -MemberType NoteProperty | Where-Object Name -EQ "defaultValue"
                        Write-Warning "This is a default value: $($defaultValue)"
                        $policyParameters.$key.defaultValue | Should -Not -BeNullOrEmpty
                    }
                }
            }
        }  
    }   
}