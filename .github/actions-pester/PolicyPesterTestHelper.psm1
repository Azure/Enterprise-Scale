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

function ConvertTo-OrderedHashtable {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $JSONInputObject # Must be string to workaround auto-conversion
    )

    $JSONObject = ConvertFrom-Json $JSONInputObject -AsHashtable -Depth 99 -NoEnumerate
    $orderedLevel = [ordered]@{}

    if (-not ($JSONObject.GetType().BaseType.Name -eq 'Hashtable')) {
        return $JSONObject # E.g. in primitive data types [1,2,3]
    }

    foreach ($currentLevelKey in ($JSONObject.Keys | Sort-Object -Culture 'en-US')) {

        if ($null -eq $JSONObject[$currentLevelKey]) {
            # Handle case in which the value is 'null' and hence has no type
            $orderedLevel[$currentLevelKey] = $null
            continue
        }

        switch ($JSONObject[$currentLevelKey].GetType().BaseType.Name) {
            { $PSItem -in @('Hashtable') } {
                $orderedLevel[$currentLevelKey] = ConvertTo-OrderedHashtable -JSONInputObject ($JSONObject[$currentLevelKey] | ConvertTo-Json -Depth 99)
            }
            'Array' {
                $arrayOutput = @()

                # Case: Array of arrays
                $arrayElements = $JSONObject[$currentLevelKey] | Where-Object { $_.GetType().BaseType.Name -eq 'Array' }
                foreach ($array in $arrayElements) {
                    if ($array.Count -gt 1) {
                        # Only sort for arrays with more than one item. Otherwise single-item arrays are casted
                        $array = $array | Sort-Object -Culture 'en-US'
                    }
                    $arrayOutput += , (ConvertTo-OrderedHashtable -JSONInputObject ($array | ConvertTo-Json -Depth 99))
                }

                # Case: Array of objects
                $hashTableElements = $JSONObject[$currentLevelKey] | Where-Object { $_.GetType().BaseType.Name -eq 'Hashtable' }
                foreach ($hashTable in $hashTableElements) {
                    $arrayOutput += , (ConvertTo-OrderedHashtable -JSONInputObject ($hashTable | ConvertTo-Json -Depth 99))
                }

                # Case: Primitive data types
                $primitiveElements = $JSONObject[$currentLevelKey] | Where-Object { $_.GetType().BaseType.Name -notin @('Array', 'Hashtable') } | ConvertTo-Json -Depth 99 | ConvertFrom-Json -AsHashtable -NoEnumerate -Depth 99
                if ($primitiveElements.Count -gt 1) {
                    $primitiveElements = $primitiveElements | Sort-Object -Culture 'en-US'
                }
                $arrayOutput += $primitiveElements

                if ($array.Count -gt 1) {
                    # Only sort for arrays with more than one item. Otherwise single-item arrays are casted
                    $arrayOutput = $arrayOutput | Sort-Object -Culture 'en-US'
                }
                $orderedLevel[$currentLevelKey] = $arrayOutput
            }
            Default {
                # string/int/etc.
                $orderedLevel[$currentLevelKey] = $JSONObject[$currentLevelKey]
            }
        }
    }

    return $orderedLevel
}
