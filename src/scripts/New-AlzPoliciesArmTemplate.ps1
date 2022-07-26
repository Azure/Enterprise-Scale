#!/usr/bin/pwsh

#
# PowerShell Script
# - Update template library in terraform-azurerm-caf-enterprise-scale repository
#
# Valid object schema for Export-LibraryArtifact function loop:
#
# @{
#     inputPath          = [String]
#     inputFilter        = [String]
#     resourceTypeFilter = [String[]]
#     outputPath         = [String]
#     fileNamePrefix     = [String]
#     fileNameSuffix     = [String]
#     exportFormat       = [String]
#     recurse            = [Boolean]
#     whatIf             = [Boolean]
# }
#

# The following SuppressMessageAttribute entries are used to surpress
# PSScriptAnalyzer tests against known exceptions as per:
# https://github.com/powershell/psscriptanalyzer#suppressing-rules
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'SourcePath', Justification = 'False positive')]

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter()][String]$AlzToolsPath = "$PWD/src/Alz.Tools",
    [Parameter()][String]$armTemplateFilePath = "$PWD/src/templates/policies.json",
    [Parameter()][String]$TargetFilePath = "$PWD/eslzArm/managementGroupTemplates/policyDefinitions/policies.json",
    [Parameter()][String]$SourcePath = "$PWD/src/resources",
    [Parameter()][String[]]$PolicyDefinitionFilters = @("Microsoft.Authorization/policyDefinitions/*"),
    [Parameter()][String[]]$PolicySetDefinitionFilters = @("Microsoft.Authorization/policySetDefinitions/*"),
    [Parameter()][String]$LineEnding = "unix",
    [Parameter()][Switch]$UpdateProviderApiVersions
)

$ErrorActionPreference = "Stop"
$jsonDepth = 100

# This script relies on a custom set of classes and functions
# defined within the Alz.Tools PowerShell module.
Import-Module $AlzToolsPath

# To avoid needing to authenticate with Azure, the following
# code will preload the ProviderApiVersions cache from a
# stored state in the module if the UseCacheFromModule flag
# is set and the ProviderApiVersions.zip file is present.
if (!$UpdateProviderApiVersions -and (Test-Path "$AlzToolsPath/ProviderApiVersions.zip")) {
    Write-Information "Pre-loading ProviderApiVersions from saved cache." -InformationAction Continue
    Invoke-UseCacheFromModule($AlzToolsPath)
}

# Import base template to object
$armTemplate = Get-Content -Path "$armTemplateFilePath" | ConvertFrom-Json

# Get all Policy Definitions matching filter
# and add to armTemplate object
$policyDefinitionFiles = $PolicyDefinitionFilters | ForEach-Object {
    Get-ChildItem -Path $SourcePath -File -Filter $_
}
$armTemplate.variables.policies.policyDefinitions += $policyDefinitionFiles | ForEach-Object {
    ConvertTo-ArmTemplateResource `
        -FilePath "$($_.FullName)" `
        -ExportFormat "ArmVariable"
} | Sort-Object

# Get all Policy Set Definitions matching filter
# and add to armTemplate object
$policySetDefinitionFiles = $PolicySetDefinitionFilters | ForEach-Object {
    Get-ChildItem -Path $SourcePath -File -Filter $_
}

$armTemplate.variables.initiatives.policySetDefinitions += $policySetDefinitionFiles | ForEach-Object {
    ConvertTo-ArmTemplateResource `
        -FilePath "$($_.FullName)" `
        -ExportFormat "ArmVariable"
} | Sort-Object

# Check whether the target directory exists and create
# directory structure if not.
$targetDirectory = Split-Path "$TargetFilePath"
$targetPathStatus = "UNKNOWN"
if (!(Test-Path -Path $targetDirectory -PathType Container)) {
    New-Item -ItemType Directory -Force -Path "$targetDirectory" -WhatIf:$WhatIfPreference | Out-Null
    $targetPathStatus = "NEW"
}
else {
    $targetPathStatus = "EXISTING"
}
Write-Information "Target directory: $targetDirectory [$targetPathStatus]" -InformationAction Continue

# Save armTemplate to target directory.
$armTemplate |
ConvertTo-Json -Depth $jsonDepth |
Edit-LineEndings -LineEnding $LineEnding |
New-Item -Path $TargetFilePath -ItemType File -Force -WhatIf:$WhatIfPreference | Out-Null
Write-Information "Output File : $($TargetFilePath) [COMPLETE]" -InformationAction Continue
