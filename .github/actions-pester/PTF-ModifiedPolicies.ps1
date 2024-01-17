Import-Module -Name $PSScriptRoot\PolicyPesterTestHelper.psm1 -Force -Verbose
Import-Module Pester -Force

function RunPester
{
    param (
        [Parameter()]
        [String]$PolicyTest
    )

    $pesterConfiguration = @{
    Run    = @{
        Container = New-PesterContainer -Path $PolicyTest
        PassThru  = $true
    }
    Output = @{
        Verbosity = 'Detailed'
        CIFormat = 'Auto'
    }
    }
    $result = Invoke-Pester -Configuration $pesterConfiguration
    exit $result.FailedCount
}

# $ModifiedFiles = @(Get-PolicyFiles -DiffFilter "M")
# if ($null -ne $ModifiedFiles)
# {
#     Write-Warning "These are the modified policies: $($ModifiedFiles)"
# }
# else
# {
#     Write-Warning "There are no modified policies"
# }

# $AddedFiles = @(Get-PolicyFiles -DiffFilter "A")
# if ($null -ne $AddedFiles)
# {
#     Write-Warning "These are the added policies: $($AddedFiles)"
# }
# else
# {
#     Write-Warning "There are no added policies"
# }

# $ModifiedAddedFiles = $ModifiedFiles + $AddedFiles

$PRBranch = "$($env:GITHUB_HEAD_REF)"
$ModifiedAddedFiles = @(git diff --diff-filter=$DiffFilter --name-only origin/main $PRBranch -- $policydirectory)
#$ModifiedAddedFiles = Get-Item "$($env:POLICY_DIR)/*.json"

$ModifiedAddedFiles | ForEach-Object {

    $PolicyFile = Split-Path $_ -Leaf
    $PolicyFileClean = $PolicyFile -replace ".json", ""

    $testPath = "tests/policy/$($PolicyFileClean).Tests.ps1"

    if (Test-Path $testPath)
    {
        Write-Warning "Running pester tests on $PolicyFileClean"
        RunPester($testPath)
    }
    else
    {
        Write-Warning "There are no tests for $PolicyFileClean"
    }
}