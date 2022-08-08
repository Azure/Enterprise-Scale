#!/usr/bin/pwsh

#
# PowerShell Script
# - Generate eslzArm configuration for test pipelines
#

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter()][String]$SubscriptionConfigPath = "$($env:TEMP_SUBSCRIPTIONS_JSON_PATH)",
    [Parameter()][ValidateLength(1, 10)][String]$RootId = "$($env:GITHUB_PR_ID)".PadRight(10, ' ').Substring(0, 10).Trim(),
    [Parameter()][String]$TemplateUri = "https://raw.githubusercontent.com/$($env:GITHUB_REPOSITORY)/$($env:GITHUB_COMMIT_ID)/eslzArm/eslzArm.json",
    [Parameter()][String]$TemplateParameterPath = "./eslzArm/eslzArm.test.param.json",
    [Parameter()][String]$Location = "$env:DEPLOYMENT_LOCATION",
    [Parameter()][String]$OutputPath = "$($env:TEMP_DEPLOYMENT_OBJECT_PATH)"
)

$ErrorActionPreference = "Stop"

# Save the current $InformationPreference value and set to continue
$InitialInformationPreference = $InformationPreference
$InformationPreference = 'Continue'

# Load Subscription data from local file
Write-Information "==> Loading Subscription Aliases from : $SubscriptionConfigPath"
$subscriptions = Get-Content -Path $SubscriptionConfigPath | ConvertFrom-Json

# Extract configuration values from Subscription data
$connectivitySubscriptionId = ($subscriptions | Where-Object -Property "parentManagementGroup" -EQ "connectivity")[0].properties.subscriptionId
$connectivityAddressPrefix = ($subscriptions | Where-Object -Property "parentManagementGroup" -EQ "connectivity")[0].addressPrefix
$identitySubscriptionId = ($subscriptions | Where-Object -Property "parentManagementGroup" -EQ "identity")[0].properties.subscriptionId
$identityAddressPrefix = ($subscriptions | Where-Object -Property "parentManagementGroup" -EQ "identity")[0].addressPrefix
$managementSubscriptionId = ($subscriptions | Where-Object -Property "parentManagementGroup" -EQ "management")[0].properties.subscriptionId
$corpLzSubscriptionId = ($subscriptions | Where-Object -Property "parentManagementGroup" -EQ "corp").properties.subscriptionId
$onlineLzSubscriptionId = ($subscriptions | Where-Object -Property "parentManagementGroup" -EQ "online").properties.subscriptionId

# Load default values from stored parameter file
Write-Information "==> Loading parameter defaults from : $TemplateParameterPath"
$loadTemplateParameterFile = (Get-Content -Path $TemplateParameterPath | ConvertFrom-Json -AsHashTable).parameters

# Create customr hashtable object with AddOrUpdate() method
$templateParameterObject = @{} | Add-Member -MemberType ScriptMethod -Name AddOrUpdate -Value {
    param($key, $value)
    $this[$key] = $value
} -Force -PassThru
$loadTemplateParameterFile.Keys.foreach({ $templateParameterObject.Add($_, $loadTemplateParameterFile[$_]['value']) })

# Set environment specific parameter values from the Subscription data and script parameters
Write-Information "==> Setting environment specific parameter values..."
$templateParameterObject.AddOrUpdate('enterpriseScaleCompanyPrefix', $RootId)
$templateParameterObject.AddOrUpdate('managementSubscriptionId', $managementSubscriptionId)
$templateParameterObject.AddOrUpdate('connectivitySubscriptionId', $connectivitySubscriptionId)
$templateParameterObject.AddOrUpdate('connectivityLocation', $env:DEPLOYMENT_LOCATION)
$templateParameterObject.AddOrUpdate('addressPrefix', $connectivityAddressPrefix)
$templateParameterObject.AddOrUpdate('identitySubscriptionId', $identitySubscriptionId)
$templateParameterObject.AddOrUpdate('identityAddressPrefix', $identityAddressPrefix)
$templateParameterObject.AddOrUpdate('corpLzSubscriptionId', $corpLzSubscriptionId)
$templateParameterObject.AddOrUpdate('onlineLzSubscriptionId', $onlineLzSubscriptionId)

# Add the deployment configuration to an object
$deploymentObject = @{
    Name                    = $RootId
    Location                = $Location
    TemplateUri             = $TemplateUri
    TemplateParameterObject = $templateParameterObject
}

# Save the deployment configuration to a local file for other steps
Write-Information "==> Saving deployment config to : $OutputPath"
$deploymentObject | ConvertTo-Json -Depth 10 | New-Item -Path $OutputPath -ItemType File -Force | Out-Null

# Revert InformationPreference to original value
$InformationPreference = $InitialInformationPreference
