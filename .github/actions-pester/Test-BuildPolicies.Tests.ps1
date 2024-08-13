Describe 'UnitTest-BuildPolicies' {

    BeforeAll {
        Import-Module -Name $PSScriptRoot\PolicyPesterTestHelper.psm1 -Force -Verbose

        New-Item -Name "buildout" -Type Directory
        
        # Build the PR policies, initiatives, and role definitions to a temp folder
        bicep build ./src/templates/policies.bicep --outfile ./buildout/policies.json
        bicep build ./src/templates/initiatives.bicep --outfile ./buildout/initiatives.json
        bicep build ./src/templates/roles.bicep --outfile ./buildout/customRoleDefinitions.json
    }

    Context "Check Policy Builds" {

        It "Check policies build done" {
            $prFile = "./eslzArm/managementGroupTemplates/policyDefinitions/policies.json"
            $buildFile = "./buildout/policies.json"

            $buildJson = Remove-JSONMetadata -TemplateObject (Get-Content $buildFile -Raw | ConvertFrom-Json -Depth 99 -AsHashtable)
            $buildJson = ConvertTo-OrderedHashtable -JSONInputObject (ConvertTo-Json $buildJson -Depth 99)

            $prJson = Remove-JSONMetadata -TemplateObject (Get-Content $prFile -Raw | ConvertFrom-Json -Depth 99 -AsHashtable)
            $prJson = ConvertTo-OrderedHashtable -JSONInputObject (ConvertTo-Json $prJson -Depth 99)

            # Compare files we built to the PR files
            (ConvertTo-Json $buildJson -Depth 99) | Should -Be (ConvertTo-Json $prJson -Depth 99) -Because "the [policies.json] should be based on the latest [policies.bicep] file. Please run [` bicep build ./src/templates/policies.bicep --outfile ./eslzArm/managementGroupTemplates/policyDefinitions/policies.json `] using the latest Bicep CLI version."
        }

        It "Check initiatives build done" {
            $PRfile = "./eslzArm/managementGroupTemplates/policyDefinitions/initiatives.json"
            $buildFile = "./buildout/initiatives.json"

            $buildJson = Remove-JSONMetadata -TemplateObject (Get-Content $buildFile -Raw | ConvertFrom-Json -Depth 99 -AsHashtable)
            $buildJson = ConvertTo-OrderedHashtable -JSONInputObject (ConvertTo-Json $buildJson -Depth 99)

            $prJson = Remove-JSONMetadata -TemplateObject (Get-Content $prFile -Raw | ConvertFrom-Json -Depth 99 -AsHashtable)
            $prJson = ConvertTo-OrderedHashtable -JSONInputObject (ConvertTo-Json $prJson -Depth 99)

            # Compare files we built to the PR files
            (ConvertTo-Json $buildJson -Depth 99) | Should -Be (ConvertTo-Json $prJson -Depth 99) -Because "the [initiatives.json] should be based on the latest [initiatives.bicep] file. Please run [` bicep build ./src/templates/initiatives.bicep --outfile ./eslzArm/managementGroupTemplates/policyDefinitions/initiatives.json `] using the latest Bicep CLI version."
        }

        It "Check role definitions build done" {
            $PRfile = "./eslzArm/managementGroupTemplates/roleDefinitions/customRoleDefinitions.json"
            $buildFile = "./buildout/customRoleDefinitions.json"

            $buildJson = Remove-JSONMetadata -TemplateObject (Get-Content $buildFile -Raw | ConvertFrom-Json -Depth 99 -AsHashtable)
            $buildJson = ConvertTo-OrderedHashtable -JSONInputObject (ConvertTo-Json $buildJson -Depth 99)

            $prJson = Remove-JSONMetadata -TemplateObject (Get-Content $prFile -Raw | ConvertFrom-Json -Depth 99 -AsHashtable)
            $prJson = ConvertTo-OrderedHashtable -JSONInputObject (ConvertTo-Json $prJson -Depth 99)

            # Compare files we built to the PR files
            (ConvertTo-Json $buildJson -Depth 99) | Should -Be (ConvertTo-Json $prJson -Depth 99) -Because "the [customRoleDefinitions.json] should be based on the latest [customRoleDefinitions.bicep] file. Please run [` bicep build ./src/templates/roles.bicep --outfile ./eslzArm/managementGroupTemplates/roleDefinitions/customRoleDefinitions.json `] using the latest Bicep CLI version."
        }
    }

    AfterAll {
        # These are not the droids you are looking for... 
    }
}