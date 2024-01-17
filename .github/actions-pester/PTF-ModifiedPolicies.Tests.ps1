Describe 'Policy Testing Framework' {
    BeforeAll {
        Import-Module -Name $PSScriptRoot\PolicyPesterTestHelper.psm1 -Force -Verbose

        $ModifiedFiles = @(Get-PolicyFiles -DiffFilter "M")
        if ($ModifiedFiles -ne $null)
        {
            Write-Warning "These are the modified policies: $($ModifiedFiles)"
        }
        else
        {
            Write-Warning "There are no modified policies"
        }

        $AddedFiles = @(Get-PolicyFiles -DiffFilter "A")
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

    Context "Test Changed Policies" {
        
        It 'Run pester tests on changed policies' {

            if ($ModifiedAddedFiles -eq $null)
            {
                Write-Warning "There are no modified or added policies"
            }
            else
            {
                $ModifiedAddedFiles | ForEach-Object {

                    $PolicyFile = Split-Path $_ -Leaf
                    $PolicyFileClean = $PolicyFile -replace ".json", ""

                    $testPath = "tests/" + $PolicyFileClean + ".Tests.ps1"
                    
                    if ($testPath -eq $null)
                    {
                        Write-Warning "There are no tests for $PolicyFileClean"
                    }
                    else
                    {
                        Write-Warning "Running pester tests on $PolicyFileClean"
                        Invoke-Pester -Script $testPath -PassThru
                    }
                }
            }
        }

    }
}