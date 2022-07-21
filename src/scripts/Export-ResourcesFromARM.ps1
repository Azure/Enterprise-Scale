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

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter()][String]$AlzToolsPath = "$PWD/src/Alz.Tools",
    [Parameter()][String]$TargetPath = "$PWD/src/resources",
    [Parameter()][String]$SourcePath = "$PWD/eslzArm",
    [Parameter()][String]$LineEnding = "unix",
    [Parameter()][Switch]$Reset,
    [Parameter()][Switch]$UpdateProviderApiVersions
)

$ErrorActionPreference = "Stop"

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

# Check whether the target library exists and create
# library directory structure if not.
$libDirectories = @(
    ($TargetPath + "/Microsoft.Authorization/policyAssignments")
    ($TargetPath + "/Microsoft.Authorization/policyDefinitions")
    ($TargetPath + "/Microsoft.Authorization/policySetDefinitions")
    ($TargetPath + "/Microsoft.Authorization/roleAssignments")
    ($TargetPath + "/Microsoft.Authorization/roleDefinitions")
    ($TargetPath + "/Microsoft.Management/managementGroups")
    ($TargetPath + "/Microsoft.Management/managementGroups/subscriptions")
)
foreach ($path in $libDirectories) {
    $libPathStatus = "UNKNOWN"
    if (!(Test-Path -Path $path -PathType Container)) {
        New-Item -ItemType Directory -Force -Path "$path" -WhatIf:$WhatIfPreference | Out-Null
        $libPathStatus = "NEW"
    }
    else {
        $libPathStatus = "EXISTING"
    }
    Write-Information "Library path: $path [$libPathStatus]" -InformationAction Continue
}

# The defaultConfig object provides a set of default values
# to reduce verbosity within the resourceConfigs object.
$defaultConfig = @{
    inputFilter        = "*.json"
    resourceTypeFilter = @()
    outputPath         = $TargetPath
    fileNamePrefix     = ""
    fileNameSuffix     = ".json"
    exportFormat       = "ArmResource"
    recurse            = $false
}

# File locations from Azure/Enterprise-Scale repository for
# resources to export, organised by type
$policyDefinitionFilePaths = @(
    "$SourcePath/managementGroupTemplates/policyDefinitions"
)
$policySetDefinitionFilePaths = @(
    "$SourcePath/managementGroupTemplates/policyDefinitions"
)

# The resourceConfigs array controls the foreach loop used to run
# Export-LibraryArtifact. Each object provides a set of values
# used to configure each run of Export-LibraryArtifact within
# the loop. If a value needed by Export-LibraryArtifact is
# missing, it will use the default value specified in the
# defaultConfig object.
$resourceConfigs = @()

# Add AzureCloud Policy Definition source files to $resourceConfigs
$resourceConfigs += $policyDefinitionFilePaths | ForEach-Object {
    [PsCustomObject]@{
        inputPath          = "$_"
        resourceTypeFilter = "Microsoft.Authorization/policyDefinitions"
        fileNamePrefix     = "Microsoft.Authorization/policyDefinitions/"
    }
}
# Add AzureCloud Policy Set Definition source files to $resourceConfigs
$resourceConfigs += $policySetDefinitionFilePaths | ForEach-Object {
    [PsCustomObject]@{
        inputPath          = "$_"
        resourceTypeFilter = "Microsoft.Authorization/policySetDefinitions"
        fileNamePrefix     = "Microsoft.Authorization/policySetDefinitions/"
    }
}

# Add AzureChinaCloud Policy Definition source files to $resourceConfigs
$resourceConfigs += $policyDefinitionFilePaths | ForEach-Object {
    [PsCustomObject]@{
        inputPath          = "$_/china"
        resourceTypeFilter = "Microsoft.Authorization/policyDefinitions"
        fileNamePrefix     = "Microsoft.Authorization/policyDefinitions/"
        fileNameSuffix     = ".AzureChinaCloud.json"
    }
}
# Add AzureChinaCloud Policy Set Definition source files to $resourceConfigs
$resourceConfigs += $policySetDefinitionFilePaths | ForEach-Object {
    [PsCustomObject]@{
        inputPath          = "$_/china"
        resourceTypeFilter = "Microsoft.Authorization/policySetDefinitions"
        fileNamePrefix     = "Microsoft.Authorization/policySetDefinitions/"
        fileNameSuffix     = ".AzureChinaCloud.json"
    }
}

# Add AzureUSGovernment Policy Definition source files to $resourceConfigs
$resourceConfigs += $policyDefinitionFilePaths | ForEach-Object {
    [PsCustomObject]@{
        inputPath          = "$_/gov"
        resourceTypeFilter = "Microsoft.Authorization/policyDefinitions"
        fileNamePrefix     = "Microsoft.Authorization/policyDefinitions/"
        fileNameSuffix     = ".AzureUSGovernment.json"
    }
}
# Add AzureUSGovernment Policy Set Definition source files to $resourceConfigs
$resourceConfigs += $policySetDefinitionFilePaths | ForEach-Object {
    [PsCustomObject]@{
        inputPath          = "$_/gov"
        resourceTypeFilter = "Microsoft.Authorization/policySetDefinitions"
        fileNamePrefix     = "Microsoft.Authorization/policySetDefinitions/"
        fileNameSuffix     = ".AzureUSGovernment.json"
    }
}

# Add AzureGermanCloud Policy Definition source files to $resourceConfigs
# $resourceConfigs += $policyDefinitionFilePaths | ForEach-Object {
#     [PsCustomObject]@{
#         inputPath          = "$_/germany"
#         resourceTypeFilter = "Microsoft.Authorization/policyDefinitions"
#         fileNamePrefix     = "Microsoft.Authorization/policyDefinitions/"
#         fileNameSuffix     = ".AzureGermanCloud.json"
#     }
# }
# Add AzureGermanCloud Policy Set Definition source files to $resourceConfigs
# $resourceConfigs += $policySetDefinitionFilePaths | ForEach-Object {
#     [PsCustomObject]@{
#         inputPath          = "$_/germany"
#         resourceTypeFilter = "Microsoft.Authorization/policySetDefinitions"
#         fileNamePrefix     = "Microsoft.Authorization/policySetDefinitions/"
#         fileNameSuffix     = ".AzureGermanCloud.json"
#     }
# }

# If the -Reset parameter is set, delete all existing
# artefacts (by resource type) from the library
if ($Reset) {
    foreach ($path in $libDirectories) {
        $libPathStatus = "UNKNOWN"
        if (Test-Path -Path $path -PathType container) {
            Remove-Item -Force -Path "$path/*" -WhatIf:$WhatIfPreference | Out-Null
            $libPathStatus = "DELETED"
        }
        else {
            $libPathStatus = "NO FILES FOUND"
        }
        Write-Information "Reset directory: $path [$libPathStatus]" -InformationAction Continue
    }
}

# Process the files added to $resourceConfigs, to add content
# to the library
foreach ($resourceConfig in $resourceConfigs) {
    Export-LibraryArtifact `
        -InputPath ($resourceConfig.inputPath ?? $defaultConfig.inputPath) `
        -InputFilter ($resourceConfig.inputFilter ?? $defaultConfig.inputFilter) `
        -ResourceTypeFilter ($resourceConfig.resourceTypeFilter ?? $defaultConfig.resourceTypeFilter) `
        -OutputPath ($resourceConfig.outputPath ?? $defaultConfig.outputPath) `
        -FileNamePrefix ($resourceConfig.fileNamePrefix ?? $defaultConfig.fileNamePrefix) `
        -FileNameSuffix ($resourceConfig.fileNameSuffix ?? $defaultConfig.fileNameSuffix) `
        -ExportFormat ($resourceConfig.exportFormat ?? $defaultConfig.exportFormat) `
        -Recurse:($resourceConfig.recurse ?? $defaultConfig.recurse) `
        -LineEnding $LineEnding `
        -WhatIf:$WhatIfPreference
}
