#!/usr/bin/pwsh

#
# PowerShell Script
# - Test, run and destroy eslzArm deployments for test pipelines
#

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter()][String]$AlzToolsPath = "$PWD/src/Alz.Tools",
    [Parameter()][String]$DeploymentConfigPath = "$($env:TEMP_DEPLOYMENT_OBJECT_PATH)",
    [Parameter()][String]$SubscriptionConfigPath = "$($env:TEMP_SUBSCRIPTIONS_JSON_PATH)",
    [Parameter()][String]$RootId,
    [Parameter()][Switch]$Test,
    [Parameter()][Switch]$Destroy
)

$ErrorActionPreference = "Stop"

# Save the current $InformationPreference value and set to continue
$InitialInformationPreference = $InformationPreference
$InformationPreference = 'Continue'

# Set the deployment mode
if ($Test) {
    $mode = "TEST"
}
elseif ($Destroy) {
    $mode = "DESTROY"
}
else {
    $mode = "RUN"
}

# Load the deployment configuration from file if path specified
if (-not [String]::IsNullOrEmpty($DeploymentConfigPath)) {
    Write-Information "==> Loading deployment configuration from : $DeploymentConfigPath"
    $deploymentObject = Get-Content -Path $DeploymentConfigPath | ConvertFrom-Json -AsHashTable
    # Set the RootId from the deployment configuration if not specified
    if ([String]::IsNullOrEmpty($RootId)) {
        $RootId = $deploymentObject.Name
        Write-Information "==> Set rootId [$RootId] from deployment configuration"
    }
    $maxParameterKeyLength = (
        $deploymentObject.TemplateParameterObject.Keys |
        ForEach-Object { $_.Length } |
        Measure-Object -Maximum
    ).Maximum
    $deploymentObject.TemplateParameterObject.Keys | Sort-Object | ForEach-Object {
        Write-Information "[Parameter] $($_.PadRight($maxParameterKeyLength, ' ')) : $($deploymentObject.TemplateParameterObject[$_])"
    }
}


# Load the Subscription configuration from file
if ($Destroy) {
    Write-Information "==> Loading subscription aliases from : $SubscriptionConfigPath"
    $subscriptions = Get-Content -Path $SubscriptionConfigPath | ConvertFrom-Json
    $subscriptionIds = $subscriptions.properties.subscriptionId
}

# Configure the environment for WhatIfPreference
$WhatIfPrefix = ""
if ($WhatIfPreference) {
    $WhatIfPrefix = "What if: "
    $deploymentObject.Add('WhatIf', $WhatIfPreference)
    $deploymentObject.Add('WhatIfResultFormat', 'ResourceIdOnly')
}

# Run the deployment
Write-Information "$($WhatIfPrefix)[$mode] deployment : [$($deploymentObject.Name)]..."
Write-Information "$($WhatIfPrefix)Template URI : $($deploymentObject.TemplateUri)"
if ($Test) {
    $deployment = Test-AzTenantDeployment @deploymentObject
}
elseif ($Destroy) {
    # This part of the script relies on a custom set of classes and functions
    # defined within the Alz.Tools PowerShell module.
    Write-Information "==> Import Alz.Tools PowerShell module..."
    Import-Module $AlzToolsPath

    $jobs = @()

    $maxKeyLength = ($subscriptions.name.foreach({ $_.Length }) | Measure-Object -Maximum).Maximum

    $subscriptions | Sort-Object -Property name | ForEach-Object {
        Write-Information "$($WhatIfPrefix)Processing Subscription : $($_.name.PadRight($maxKeyLength, ' ')) [$($_.properties.subscriptionId)]"
    }

    $jobs += Invoke-RemoveRsgByPattern -SubscriptionId $subscriptionIds -Like "$RootId-*" -WhatIf:$WhatIfPreference
    $jobs += Invoke-RemoveRsgByPattern -SubscriptionId $subscriptionIds -Like "NetworkWatcherRG" -WhatIf:$WhatIfPreference
    $jobs += Invoke-RemoveDeploymentByPattern -SubscriptionId $subscriptionIds -Like "$RootId" -IncludeTenantScope -WhatIf:$WhatIfPreference
    $jobs += Invoke-RemoveDeploymentByPattern -SubscriptionId $subscriptionIds -Like "alz-*" -IncludeTenantScope -WhatIf:$WhatIfPreference

    Write-Information "$($WhatIfPrefix)Removing Management Group : $RootId..."
    Invoke-RemoveMgHierarchy -ManagementGroupId $RootId -WhatIf:$WhatIfPreference | ForEach-Object { Write-Information "Successfully removed : $_" }

    Write-Information "$($WhatIfPrefix)Removing Orphaned Role Assignments..."
    if (-not $WhatIfPreference) {
        # Sleep for 60 seconds to allow Management Group changes to create orphaned Role Assignments
        Start-Sleep -Seconds 60
    }
    Invoke-RemoveOrphanedRoleAssignment -SubscriptionId $subscriptionIds -WhatIf:$WhatIfPreference

    Write-Information "$($WhatIfPrefix)Waiting for resource deletion jobs to complete..."
    $jobs | Wait-Job -Timeout 3600
}
else {
    $deployment = New-AzTenantDeployment @deploymentObject
}

# Return deployment output
if (
    (-not $Test) -and
    (-not $Destroy)
) {
    $deployment
}

# Validate provisioning state for completed deployment
if (
    (-not $Test) -and
    (-not $Destroy) -and
    (-not $WhatIfPreference) -and
    ($deployment.ProvisioningState -ne "Succeeded")
) {
    throw "Provisioning failed... check activity and deployment logs in Azure for more information."
}
else {
    Write-Information "$($WhatIfPrefix)[$mode] Deployment Complete..."
}

# Revert InformationPreference to original value
$InformationPreference = $InitialInformationPreference
