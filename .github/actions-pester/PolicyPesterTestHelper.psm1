<#
.DESCRIPTION
Uses git diff to return a list of policy definitions and policy set definition file paths.
#>

function Get-PolicyFiles
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()]
        [String]$DiffFilter,

        [Parameter()]
        [String]$PolicyDir = "$($env:POLICY_DIR)",

        [Parameter()]
        [String]$PolicySetDir = "$($env:POLICYSET_DIR)",

        [Parameter()]
        [String]$PRBranch = "$($env:GITHUB_HEAD_REF)",

        [Parameter()]
        [String]$BaseBranch = "$($env:GITHUB_BASE_REF)"
    )

    $PolicyFiles = @(git diff --diff-filter=$DiffFilter --name-only origin/main $PRBranch -- $PolicyDir)
    $PolicySetsFiles = @(git diff --diff-filter=$DiffFilter --name-only origin/main $PRBranch -- $PolicySetDir)

    $PolicyAndSetFiles = $PolicyFiles + $PolicySetsFiles

    $PolicyAndSetFiles | ForEach-Object {
        return $_
    }
}
