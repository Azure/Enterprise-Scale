Describe 'UnitTest-ModifiedPolicies' {
    BeforeAll {
        Import-Module -Name $PSScriptRoot\PolicyPesterTestHelper.psm1 -Force -Verbose

        $ModifiedFiles = Get-PolicyFiles -DiffFilter "M"
        if ($ModifiedFiles -ne $null)
        {
            Write-Warning "These are the modified policies: $($ModifiedFiles)"
        }
        else
        {
            Write-Warning "There are no modified policies"
        }

        $AddedFiles = Get-PolicyFiles -DiffFilter "A"
        if ($AddedFiles -ne $null)
        {
            Write-Warning "These are the added policies: $($AddedFiles)"
        }
        else
        {
            Write-Warning "There are no added policies"
        }

        $ModifiedAddedFiles = $ModifiedFiles + $AddedFiles
    }



    Context "Validate policy metadata" {

        It "Check policy metadata version exists" {
            $ModifiedAddedFiles | ForEach-Object {
                $PolicyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $PolicyFile = Split-Path $_ -Leaf
                $PolicyMetadataVersion = $PolicyJson.properties.metadata.version
                Write-Warning "$($PolicyFile) - The current metadata version for the PR branch is : $($PolicyMetadataVersion)"
                $PolicyMetadataVersion | Should -Not -BeNullOrEmpty
            }
        }

        It "Check policy metadata version is greater than its previous version" -Skip:($ModifiedFiles -ne $null) {
            $ModifiedFiles | ForEach-Object {
                $PolicyFile = Split-Path $_ -Leaf
                $PolicyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $PreviousPolicyDefinitionRawUrl = "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/$_"
                $PreviousPolicyDefinitionOutputFile = "./previous-$PolicyFile"
                Invoke-WebRequest -Uri $PreviousPolicyDefinitionRawUrl -OutFile $PreviousPolicyDefinitionOutputFile
                $PreviousPolicyDefinitionsFile = Get-Content $PreviousPolicyDefinitionOutputFile -Raw | ConvertFrom-Json
                $PreviousPolicyDefinitionsFileVersion = $PreviousPolicyDefinitionsFile.properties.metadata.version
                Write-Warning "$($PolicyFile) - The current metadata version for the main branch is : $($PreviousPolicyDefinitionsFileVersion)"
                $PolicyMetadataVersion = $PolicyJson.properties.metadata.version
                $PolicyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $PolicyMetadataVersion | Should -BeGreaterThan $PreviousPolicyDefinitionsFileVersion
            }
        }

        It "Check policy metadata category exists" {
            $ModifiedAddedFiles | ForEach-Object {
                $PolicyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $PolicyFile = Split-Path $_ -Leaf
                $PolicyMetadataCategories = $PolicyJson.properties.metadata.category
                Write-Warning "$($PolicyFile) - These are the policy metadata categories: $($PolicyMetadataCategories)"
                $PolicyMetadataCategories | Should -Not -BeNullOrEmpty
            }
        }

        It "Check policy metadata source is set to Enterprise-Scale repo" {
            $ModifiedAddedFiles | ForEach-Object {
                $PolicyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $PolicyFile = Split-Path $_ -Leaf
                $PolicyMetadataSource = $PolicyJson.properties.metadata.source
                Write-Warning "$($PolicyFile) - This is the policy source link: $($PolicyMetadataSource)"
                $PolicyMetadataSource | Should -Be 'https://github.com/Azure/Enterprise-Scale/'
            }
        }

        It "Check policy metadata ALZ Environments are specified for Public, US Gov or China Clouds" {
            $ModifiedAddedFiles | ForEach-Object {
                $PolicyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                $PolicyFile = Split-Path $_ -Leaf
                $AlzEnvironments = @("AzureCloud", "AzureChinaCloud", "AzureUSGovernment")
                $PolicyEnvironments = $PolicyJson.properties.metadata.alzCloudEnvironments
                Write-Warning "$($PolicyFile) - These are the environments: $($PolicyEnvironments)"
                $PolicyJson.properties.metadata.alzCloudEnvironments | Should -BeIn $AlzEnvironments
            }
        }
        }
        Context "Validate policy parameters" {
            It 'Check for policy parameters have default values' {
                $ModifiedAddedFiles | ForEach-Object {
                    $PolicyJson = Get-Content -Path $_ -Raw | ConvertFrom-Json
                    $PolicyFile = Split-Path $_ -Leaf
                    $PolicyParameters = $PolicyJson.properties.parameters
                    if ($PolicyParameters | Get-Member -MemberType NoteProperty)
                    {
                        $Parameters = $PolicyParameters | Get-Member -MemberType NoteProperty | Select-Object -Expand Name
                        Write-Warning "$($PolicyFile) - These are the params: $($Parameters)"
                        $Parameters = $PolicyParameters | Get-Member -MemberType NoteProperty
                        $Parameters | ForEach-Object {
                            $key = $_.name
                            $defaultValue = $PolicyParameters.$key | Get-Member -MemberType NoteProperty | Where-Object Name -EQ "defaultValue"
                            Write-Warning "$($PolicyFile) - Parameter: $($key) - Default Value: $($defaultValue)"
                            $PolicyParameters.$key.defaultValue | Should -Not -BeNullOrEmpty
                        }
                    }
                }
            }
        }
    }