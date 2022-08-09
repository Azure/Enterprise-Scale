#!/usr/bin/pwsh

#
# PowerShell Script
# - Run and test eslzArm deployments for test pipelines
#

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter()][String]$DeploymentConfigPath = "$($env:TEMP_DEPLOYMENT_OBJECT_PATH)",
    [Parameter()][Switch]$Test
)

$ErrorActionPreference = "Stop"

# Save the current $InformationPreference value and set to continue
$InitialInformationPreference = $InformationPreference
$InformationPreference = 'Continue'

# Load the deployment configuration from file
Write-Information "==> Loading deployment config from : $DeploymentConfigPath"
$deploymentObject = Get-Content -Path $DeploymentConfigPath | ConvertFrom-Json -AsHashTable
$maxParameterKeyLength = (
    $deploymentObject.TemplateParameterObject.Keys |
    ForEach-Object { $_.Length } |
    Measure-Object -Maximum
).Maximum
$deploymentObject.TemplateParameterObject.Keys | Sort-Object | ForEach-Object {
    Write-Information "[Parameter] $($_.PadRight($maxParameterKeyLength, ' ')) : $($deploymentObject.TemplateParameterObject[$_])"
}

# Run the deployment
if ($Test) {
    $scenarioPrefix = "TEST"
}
elseif ($WhatIfPreference) {
    $scenarioPrefix = "RUN (WHAT IF)"
    $deploymentObject.Add('WhatIf', $WhatIfPreference)
    $deploymentObject.Add('WhatIfResultFormat', 'ResourceIdOnly')
}
else {
    $scenarioPrefix = "RUN"
}
Write-Information "[$scenarioPrefix] deployment : [$($deploymentObject.Name)]..."
Write-Information " - Template URI : $($deploymentObject.TemplateUri)"
if ($Test) {
    $deployment = Test-AzTenantDeployment @deploymentObject
}
else {
    $deployment = New-AzTenantDeployment @deploymentObject
}

# Return output
if (-not $Test) {
    $deployment
}

# Validate provisioning state for completed deployment
if (
    (-not $Test) -and
    (-not $WhatIfPreference) -and
    ($deployment.ProvisioningState -ne "Succeeded")
) {
    throw "Provisioning failed... check activity and deployment logs in Azure for more information."
}
else {
    Write-Information "[$scenarioPrefix] Deployment Complete..."
}

# Revert InformationPreference to original value
$InformationPreference = $InitialInformationPreference
