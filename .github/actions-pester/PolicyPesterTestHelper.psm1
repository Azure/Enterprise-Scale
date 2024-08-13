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

function Remove-JSONMetadata {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable] $TemplateObject
    )
    $TemplateObject.Remove('metadata')

    # Differantiate case: With user defined types (resources property is hashtable) vs without user defined types (resources property is array)
    if ($TemplateObject.resources.GetType().BaseType.Name -eq 'Hashtable') {
        # Case: Hashtable
        $resourceIdentifiers = $TemplateObject.resources.Keys
        for ($index = 0; $index -lt $resourceIdentifiers.Count; $index++) {
            if ($TemplateObject.resources[$resourceIdentifiers[$index]].type -eq 'Microsoft.Resources/deployments' -and $TemplateObject.resources[$resourceIdentifiers[$index]].properties.template.GetType().BaseType.Name -eq 'Hashtable') {
                $TemplateObject.resources[$resourceIdentifiers[$index]] = Remove-JSONMetadata -TemplateObject $TemplateObject.resources[$resourceIdentifiers[$index]].properties.template
            }
        }
    } else {
        # Case: Array
        for ($index = 0; $index -lt $TemplateObject.resources.Count; $index++) {
            if ($TemplateObject.resources[$index].type -eq 'Microsoft.Resources/deployments' -and $TemplateObject.resources[$index].properties.template.GetType().BaseType.Name -eq 'Hashtable') {
                $TemplateObject.resources[$index] = Remove-JSONMetadata -TemplateObject $TemplateObject.resources[$index].properties.template
            }
        }
    }

    return $TemplateObject
}
