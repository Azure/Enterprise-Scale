#!/usr/bin/pwsh

#
# PowerShell Script
# - Update the ProviderApiVersions.zip file stored in the module
#
# Requires an authentication session PowerShell session to Azure
# and should be run from the same location as the script unless
# the -Directory parameter is specified.
#

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter()][String]$AlzToolsPath = "$PWD/src/Alz.Tools"
)

$ErrorActionPreference = "Stop"

# This script relies on a custom set of classes and functions
# defined within the Alz.Tools PowerShell module.
Import-Module $AlzToolsPath

Write-Information "Updating ProviderApiVersions in module." -InformationAction Continue
if ($PSCmdlet.ShouldProcess($AlzToolsPath)) {
    Invoke-UpdateCacheInModule($AlzToolsPath)
}

Write-Information "... Complete" -InformationAction Continue
