<#
.DESCRIPTION
Gets a list of new policy definitions
#>

function Get-AddedPolicies
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()]
        [String]$Policy_Dir = "$($env:POLICY_DIR)",

        [Parameter()]
        [String]$PRBranch = "$($env:GITHUB_HEAD_REF)",

        [Parameter()]
        [int]$Counter = 0
    )

    $NewPolicies = @(git diff --name-only origin/main origin/$PRBranch -- $Policy_Dir)
    $NewPolicies | ForEach-Object {
        $Counter++
        Write-Output $_
        Write-Verbose "New Policy #${Counter}: $_"
    }
}

function Get-ModifiedPolicies
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()]
        [String]$Policy_Dir = "$($env:POLICY_DIR)",

        [Parameter()]
        [String]$PRBranch = "$($env:GITHUB_HEAD_REF)",

        [Parameter()]
        [int]$Counter = 0
    )
    
    Write-Verbose "Checking directory $($Policy_Dir)"
    $NewPolicies = @(git diff --diff-filter=M --name-only origin/main origin/$PRBranch -- $Policy_Dir)
    $NewPolicies | ForEach-Object {
        $Counter++
        Write-Output $_    
    }
}

function report
{
    process
    {
        $_ | Get-Member | Out-String | Write-Host 
    } 
}