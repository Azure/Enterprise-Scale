#!/usr/bin/pwsh

#
# PowerShell Script
# - Register Azure Subscriptions for test pipelines
#

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter()][String]$AlzToolsPath = "$PWD/src/Alz.Tools",
    [Parameter()][String[]]$Alias = @(
        "csu-portal-connectivity-100"
        "csu-portal-identity-110"
        "csu-portal-management-120"
        "csu-portal-corp-201"
        "csu-portal-corp-202"
        "csu-portal-corp-203"
        "csu-portal-online-211"
        "csu-portal-online-212"
    ),
    [Parameter()][String]$BillingScope = "$($env:BILLING_SCOPE)",
    [Parameter()][String]$OutputPath = "$($env:TEMP_SUBSCRIPTIONS_JSON_PATH)"
)

$ErrorActionPreference = "Stop"

# Save the current $InformationPreference value and set to continue
$InitialInformationPreference = $InformationPreference
$InformationPreference = 'Continue'

# This script relies on a custom set of classes and functions
# defined within the Alz.Tools PowerShell module.
Write-Information "==> Import Alz.Tools PowerShell module..."
Import-Module $AlzToolsPath

# List out the Subscription Aliases to be processed
Write-Information "==> Processing Subscription Aliases..."
$Alias | ForEach-Object {
    Write-Information "[PROCESSING] Subscription Alias : $_"
}

# Register the Subscription Aliases
$AzureSubscriptionAliasObject = @{
    Alias                    = $Alias
    SetParentManagementGroup = $true
    SetAddressPrefix         = $true
}
if (-not [String]::IsNullOrEmpty($BillingScope)) {
    $AzureSubscriptionAliasObject.Add('BillingScope', $BillingScope)
    $AzureSubscriptionAliasObject.Add('Workload', 'Production')
}
$subscriptions = Set-AzureSubscriptionAlias @AzureSubscriptionAliasObject

# Save the output to a local file for other steps
Write-Information "==> Saving Subscription Aliases to : $OutputPath"
$subscriptions | ConvertTo-Json -Depth 10 | New-Item -Path $OutputPath -ItemType File -Force | Out-Null

# Revert InformationPreference to original value
$InformationPreference = $InitialInformationPreference
