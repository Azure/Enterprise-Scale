#!/usr/bin/pwsh

#
# PowerShell Script
# - Remove orphaned role assignments from the specified Subscriptions
#

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter()][String]$AlzToolsPath = "$PWD/src/Alz.Tools",
    [Parameter()][String]$SubscriptionConfigPath = "$($env:TEMP_SUBSCRIPTIONS_JSON_PATH)",
    [Parameter()][String[]]$SubscriptionIds
)

$ErrorActionPreference = "Stop"

# Save the current $InformationPreference value and set to continue
$InitialInformationPreference = $InformationPreference
$InformationPreference = 'Continue'

# Load the Subscription configuration from file if SubscriptionIds IsNullOrEmpty
if ([String]::IsNullOrEmpty($SubscriptionIds)) {
    Write-Information "==> Loading subscription aliases from : $SubscriptionConfigPath"
    $subscriptions = Get-Content -Path $SubscriptionConfigPath | ConvertFrom-Json
    $SubscriptionIds = $subscriptions.properties.subscriptionId
}

# This script relies on a custom set of classes and functions
# defined within the Alz.Tools PowerShell module.
Write-Information "==> Import Alz.Tools PowerShell module..."
Import-Module $AlzToolsPath

Write-Information "==> Process subscriptions to remove orphaned role assignments..."
Invoke-RemoveOrphanedRoleAssignment -SubscriptionId $subscriptionIds -WhatIf:$WhatIfPreference

# Revert InformationPreference to original value
$InformationPreference = $InitialInformationPreference
