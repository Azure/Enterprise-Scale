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
        [int]$Counter = 0
    )

    $NewPolicies = @(git diff --diff-filter=A --name-only main policy-unittests -- $Policy_Dir)
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
        [int]$Counter = 0
    )

    $NewPolicies = @(git diff --diff-filter=M --name-only main policy-unittests -- $Policy_Dir)
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
