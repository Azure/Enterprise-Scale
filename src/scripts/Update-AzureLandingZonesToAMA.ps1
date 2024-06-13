# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# what if -plan
# configuration

# check changetracking migration https://learn.microsoft.com/en-us/azure/automation/change-tracking/guidance-migration-log-analytics-monitoring-agent?tabs=ps-policy%2Climit-single-vm
# Deploy CT new and see if Legacy Solution is deployed

<#
    .SYNOPSIS
    Updates Azure Landing Zones to use AMA.

    .DESCRIPTION
    The Update-AzureLandingZonesToAMA command performs the following tasks:
    - Deploys Data Collection Rules for VMInsights, ChangeTracking, and MDFC Defender for SQL.
    - Deploys User Assigned Managed Identity.
    - Updates Policy Definitions.
    - Removes legacy Policy Assignments.
    - Removes legacy solutions.
    - Assigns new Policies and Initiatives.
    - Updates Managed Identity roles.
    - Creates Policy Remediation tasks.

    .PARAMETER Name
    Required. 

    .PARAMETER ResourceGroupName
    Required. 

    .EXAMPLE
    example

    .LINK
    alz link
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $location,

    [Parameter(Mandatory = $true)]
    [string]
    $eslzRoot,

    [Parameter(Mandatory = $true)]
    [string]
    $managementResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]
    $workspaceResourceId,

    [Parameter(Mandatory = $true)]
    [string]
    $workspaceRegion,

    [switch]
    $DeployUserAssignedManagedIdentity,
    
    [switch]
    $DeployVMInsights,

    [switch]
    $DeployChangeTracking,

    [switch]
    $DeployMDfCDefenderSQL,

    [switch]
    $DeployAzureUpdateManager,

    [switch]
    $RemediatePolicies,

    [switch]
    $RemoveLegacyPolicyAssignments,

    [switch]
    $RemoveLegacySolutions,

    [switch]
    $UpdatePolicyDefinitions
)

function Add-RbacRolesToManagedIdentities {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory = $true)]
        [string] 
        $enterpriseScaleCompanyPrefix,

        [Parameter()]
        [array]
        $azureComputePolicyList,

        [Parameter()]
        [array]
        $arcEnabledPolicyList
    )

    Write-Output "Retrieving Landing Zones management group ..."

    # Getting Platform and Landing Zones management groups
    $platformMg = Get-AzManagementGroup | Where-Object { $_.Name -like "$enterpriseScaleCompanyPrefix*-platform" } -ErrorAction SilentlyContinue
    $landingZonesMg = Get-AzManagementGroup | Where-Object { $_.Name -like "$enterpriseScaleCompanyPrefix*-landingzones" } -ErrorAction SilentlyContinue


    if ($platformMg -and $landingZonesMg) {

        Write-Output "`tRetrieving role assignments on Landing Zones management group ..."
        $landingZonesMgHybridRoleAssignments = Get-AzRoleAssignment -Scope $($landingZonesMg.Id) | where-object { $_.Displayname -in $arcEnabledPolicyList } | Sort-Object -Property ObjectId -Unique
        $landingZonesMgVmiCtRoleAssignments = Get-AzRoleAssignment -Scope $($landingZonesMg.Id) | where-object { $_.Displayname -in $azureComputePolicyList } | Sort-Object -Property ObjectId -Unique
        
        # Performing role assignments
        
        if ($landingZonesMgVmiCtRoleAssignments) {
            # Assigning Reader and Managed Identity Operator to VMInsights, Change Tracking and MDfC Defender for SQL Managed Identities
            Write-Output "`t`tAssigning 'Reader' and 'Managed Identity Operator' roles to 'VMInsights', 'Change Tracking' and 'MDfC Defender for SQL' Managed Identities from Landing Zones to Platform management group ..."
            $landingZonesMgVmiCtRoleAssignments | ForEach-Object { New-AzRoleAssignment -Scope $($platformMg.Id) -RoleDefinitionName 'Reader' -ObjectId $_.ObjectId -ErrorAction SilentlyContinue }
            $landingZonesMgVmiCtRoleAssignments | ForEach-Object { New-AzRoleAssignment -Scope $($platformMg.Id) -RoleDefinitionName 'Managed Identity Operator' -ObjectId $_.ObjectId -ErrorAction SilentlyContinue }
        }
        else {
            Write-Output "`t`tNo role assignment found on the Landing Zones management group for the given 'VMInsights', 'Change Tracking' or 'MDfC Defender for SQL' Managed Identities."
        }

        if ($landingZonesMgHybridRoleAssignments) {
            # Assigning Reader to Hybrid VMInsights and Change Tracking Managed Identities
            Write-Output "`t`tAssigning 'Reader' role to 'VMInsights' and 'Change Tracking' Managed Identity from Landing Zones on Platform management group ..."
            $landingZonesMgHybridRoleAssignments | ForEach-Object { New-AzRoleAssignment -Scope $($platformMg.Id) -RoleDefinitionName 'Reader' -ObjectId $_.ObjectId -ErrorAction SilentlyContinue }
        }
        else {
            Write-Output "`t`tNo role assignment found on the Landing Zones management group for the given 'VMInsights' and 'Change Tracking' Managed Identities."
        }

    }
    else {
        Write-Output "`tOne or more management group of type 'Platform' and 'Landing Zones' was not found. Make sure you have the necessary permissions and/or that the hierachy is Azure Landing Zones aligned."
    }
}
function Start-PolicyRemediation {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory = $true)] [string] $managementGroupName,
        [Parameter(Mandatory = $true)] [string] $policyAssignmentName,
        [Parameter(Mandatory = $true)] [string] $polassignId,
        [Parameter(Mandatory = $false)] [string] $policyDefinitionReferenceId
    )
    $guid = New-Guid
    #create remediation for the individual policy
    $uri = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$($managementGroupName)/providers/Microsoft.PolicyInsights/remediations/$($policyName)-$($guid)?api-version=2021-10-01"
    $body = @{
        properties = @{
            policyAssignmentId = "$polassignId"
        }
    }
    if ($policyDefinitionReferenceId) {
        $body.properties.policyDefinitionReferenceId = $policyDefinitionReferenceId
    }
    $body = $body | ConvertTo-Json -Depth 10
    Invoke-AzRestMethod -Uri $uri -Method PUT -Payload $body
}
#Function to get the policy assignments in the management group scope
function Get-PolicyType {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(Mandatory = $true)] [string] $managementGroupName,
        [Parameter(Mandatory = $true)] [string] $policyName
    )

    #Validate that the management group exists through the Azure REST API
    $uri = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$($managementGroupName)?api-version=2021-04-01"
    $result = (Invoke-AzRestMethod -Uri $uri -Method GET).Content | ConvertFrom-Json -Depth 100
    if ($result.error) {
        throw "Management group $managementGroupName does not exist, please specify a valid management group name"
    }

    # Getting custom policySetDefinitions
    $uri = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$($managementGroupName)/providers/Microsoft.Authorization/policySetDefinitions?&api-version=2023-04-01"
    $initiatives = (Invoke-AzRestMethod -Uri $uri -Method GET).Content | ConvertFrom-Json -Depth 100

    #Get policy assignments at management group scope
    $assignmentFound = $false
    $uri = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$($managementGroupName)/providers/Microsoft.Authorization/policyAssignments?`$filter=atScope()&api-version=2022-06-01"
    $result = (Invoke-AzRestMethod -Uri $uri -Method GET).Content | ConvertFrom-Json -Depth 100

    #iterate through the policy assignments
    $result.value | ForEach-Object {
        #check if the policy assignment is for the specified policy set definition
        If ($($PSItem.properties.policyDefinitionId) -match "/providers/Microsoft.Authorization/policySetDefinitions/$policyName") {
            # Go to enumerating policy set
            $assignmentFound = $true
            Enumerate-PolicySet -managementGroupName $managementGroupName -policyAssignmentObject $PSItem
        }
        Elseif ($($PSItem.properties.policyDefinitionId) -match "/providers/Microsoft.Authorization/policyDefinitions/$policyName") {
            # Go to handling individual policy
            $assignmentFound = $true
            Enumerate-Policy -managementGroupName $managementGroupName -policyAssignmentObject $PSItem
        }
        Else {
            # Getting parent initiative for unassigned individual policies
            If ($initiatives) {
                $parentInitiative = $initiatives.value | Where-Object { ($_.properties.policyType -eq 'Custom') -and ($_.properties.metadata -like '*_deployed_by_amba*') } | Where-Object { $_.properties.policyDefinitions.policyDefinitionReferenceId -eq $policyname }

                # Getting the assignment of the parent initiative
                If ($parentInitiative) {
                    If ($($PSItem.properties.policyDefinitionId) -match "/providers/Microsoft.Authorization/policySetDefinitions/$($parentInitiative.name)") {
                        # Invoking policy remediation
                        $assignmentFound = $true
                        Start-PolicyRemediation -managementGroupName $managementGroupName -policyAssignmentName $PSItem.name -polassignId $PSItem.id -policyDefinitionReferenceId $policyName
                    }
                }
            }
        }
    }

    #if no policy assignments were found for the specified policy name, throw an error
    If (!$assignmentFound) {
        throw "No policy assignments found for policy $policyName at management group scope $managementGroupName"
    }
}
# Function to enumerate the policies in the policy set and trigger remediation for each individual policy
function Enumerate-PolicySet {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)] [string] $managementGroupName,
        [Parameter(Mandatory = $true)] [object] $policyAssignmentObject
    )
    #extract policy assignment information
    $policyAssignmentObject
    $polassignId = $policyAssignmentObject.id
    $name = $policyAssignmentObject.name
    $policySetId = $policyAssignmentObject.properties.policyDefinitionId
    $policySetId
    $psetUri = "https://management.azure.com$($policySetId)?api-version=2021-06-01"
    $policySet = (Invoke-AzRestMethod -Uri $psetUri -Method GET).Content | ConvertFrom-Json -Depth 100
    $policySet
    $policies = $policySet.properties.policyDefinitions
    #iterate through the policies in the policy set
    Foreach ($policy in $policies) {
        $policyDefinitionId = $policy.policyDefinitionId
        $policyDefinitionReferenceId = $policy.policyDefinitionReferenceId
        #trigger remediation for the individual policy
        Start-PolicyRemediation -managementGroupName $managementGroupName -policyAssignmentName $name -polassignId $polassignId -policyDefinitionReferenceId $policyDefinitionReferenceId
    }
}
#Function to get specific information about a policy assignment for a single policy and trigger remediation
function Enumerate-Policy {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)] [string] $managementGroupName,
        [Parameter(Mandatory = $true)] [object] $policyAssignmentObject
    )
    #extract policy assignment information
    $polassignId = $policyAssignmentObject.id
    $name = $policyAssignmentObject.name
    $policyDefinitionId = $policyAssignmentObject.properties.policyDefinitionId
    Start-PolicyRemediation -managementGroupName $managementGroupName -policyAssignmentName $name -polassignId $polassignId
}
function Update-Policies {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $eslzRoot,

        [Parameter(Mandatory = $true)]
        [string]
        $location
    )
    begin {
        $resultsPolicy = Get-AzManagementGroupDeploymentWhatIfResult -ManagementGroupId $eslzRoot -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyDefinitions\policies.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot } | Out-string -Stream | Select-String -Pattern 'Resource changes'
        $resultsPolicySet = Get-AzManagementGroupDeploymentWhatIfResult -ManagementGroupId $eslzRoot -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyDefinitions\initiatives.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot } | Out-string -Stream | Select-String -Pattern 'Resource changes'
    }
    process {
        if ($PSCmdlet.ShouldProcess($eslzRoot, "- Updating Policy Definitions: $resultsPolicy")) {
            # Update Policy Definitions
            Write-Host "- Updating Policy Definitions: $resultsPolicy ..." -ForegroundColor DarkCyan
            New-AzManagementGroupDeployment -ManagementGroupId $eslzRoot -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyDefinitions\policies.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot } > $null
        }
        if ($PSCmdlet.ShouldProcess($eslzRoot, "- Updating Policy Set Definitions: $resultsPolicySet")) {
            # Update Policy Set Definitions
            Write-Host "- Updating Policy Set Definitions: $resultsPolicySet ..." -ForegroundColor DarkCyan
            New-AzManagementGroupDeployment -ManagementGroupId $eslzRoot -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyDefinitions\initiatives.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot } > $null
        }
    }
}
function Remove-LegacyAssignments {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $eslzRoot,

        [Parameter(Mandatory = $true)]
        [array]
        $legacyAssignments
    )
    process {
        foreach ($legacyAssignment in $legacyAssignments) {
            $assignment = Get-AzPolicyAssignment -Id "/providers/microsoft.management/managementgroups/$eslzRoot/providers/microsoft.authorization/policyassignments/$legacyAssignment" -ErrorAction SilentlyContinue
            if ($PSCmdlet.ShouldProcess($eslzRoot, "- Removing legacy Policy Assignments: $($assignment.Name)")) {
                if ($assignment) {
                    Write-Host "- Removing legacy Policy Assignments: $($assignment.Name) ..." -ForegroundColor DarkRed
                    Remove-AzPolicyAssignment -Id "/providers/microsoft.management/managementgroups/$eslzRoot/providers/microsoft.authorization/policyassignments/$legacyAssignment" > $null
                }
                else {
                    Write-Host "- No legacy Policy Assignments found ..." -ForegroundColor DarkGray
                }
            }
        }
    }
}
function Deploy-UserAssignedManagedIdentity {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $eslzRoot,

        [Parameter(Mandatory = $true)]
        [string]
        $location,

        [Parameter(Mandatory = $true)]
        [string]
        $managementResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string]
        $platformScope,

        [Parameter(Mandatory = $true)]
        [string]
        $userAssignedIdentityName
    )
    begin {
        $uami = Get-AzUserAssignedIdentity -Name $userAssignedIdentityName -ResourceGroupName $managementResourceGroupName -ErrorAction SilentlyContinue
        $uamiAssignment = Get-AzPolicyAssignment -Id "/providers/microsoft.management/managementgroups/$platformScope/providers/microsoft.authorization/policyassignments/DenyAction-DeleteUAMIAMA" -ErrorAction SilentlyContinue
        $resultsUAMI = Get-AzResourceGroupDeploymentWhatIfResult -ResourceGroupName $managementResourceGroupName -TemplateFile ".\eslzArm\resourceGroupTemplates\userAssignedIdentity.json" -TemplateParameterObject @{"location" = $location; "userAssignedIdentityName" = $userAssignedIdentityName; "userAssignedIdentityResourceGroup" = $managementResourceGroupName } | Out-string -Stream | Select-String -Pattern 'Resource changes'
        $resultsUAMIAssignment = Get-AzManagementGroupDeploymentWhatIfResult -ManagementGroupId $platformScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DENYACTION-DeleteUAMIAMAPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "resourceName" = $userAssignedIdentityName; "resourceType" = "Microsoft.ManagedIdentity/userAssignedIdentities" } | Out-string -Stream | Select-String -Pattern 'Resource changes'
    }
    process {
        if ($PSCmdlet.ShouldProcess($managementResourceGroupName, "- Deploying User Assigned Managed Identity: $userAssignedIdentityName $resultsUAMI")) {
            if ($uami) {
                Write-Host "- User Assigned Managed Identity $userAssignedIdentityName already exists ..." -ForegroundColor DarkGray
            }
            if (-NOT($uami)) {
                Write-Host "- Deploying User Assigned Managed Identity: $userAssignedIdentityName ..." -ForegroundColor DarkGreen
                New-AzResourceGroupDeployment -ResourceGroupName $managementResourceGroupName -TemplateFile ".\eslzArm\resourceGroupTemplates\userAssignedIdentity.json" -TemplateParameterObject @{"location" = $location; "userAssignedIdentityName" = $userAssignedIdentityName; "userAssignedIdentityResourceGroup" = $managementResourceGroupName } > $null    
            }
        }
        if ($PSCmdlet.ShouldProcess($platformScope, "- Assigning 'DenyAction-DeleteUAMIAMA' policy: $resultsUAMIAssignment")) {
            if ($uamiAssignment) {
                Write-Host "- Policy Assignment to protect the User Assigned Managed Identity from accidental deletion already exists ..." -ForegroundColor DarkGray
            }
            if (-NOT($uamiAssignment)) {
                Write-Host "- Assigning 'DenyAction-DeleteUAMIAMA' policy to protect the User Assigned Managed Identity from accidental deletion ..." -ForegroundColor DarkGreen
                New-AzManagementGroupDeployment -ManagementGroupId $platformScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DENYACTION-DeleteUAMIAMAPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "resourceName" = $userAssignedIdentityName; "resourceType" = "Microsoft.ManagedIdentity/userAssignedIdentities" } > $null
            }
        }
    }
}
function Deploy-VMInsights {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $location,

        [Parameter(Mandatory = $true)]
        [string]
        $eslzRoot,

        [Parameter(Mandatory = $true)]
        [string]
        $managementResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string]
        $workspaceResourceId,

        [Parameter(Mandatory = $true)]
        [string]
        $userAssignedIdentityName,

        [Parameter(Mandatory = $true)]
        [array]
        $scopes,

        [Parameter(Mandatory = $true)]
        [array]
        $VMInsightsAssignmentTemplates
    )
    $userAssignedIdentityResourceId = (Get-AzUserAssignedIdentity -Name $userAssignedIdentityName -ResourceGroupName $managementResourceGroupName).Id
    # Create a data collection rule for VMInsights
    $dataCollectionRuleVmInsightsName = "dcr-vminsights-prod-$location-001"
    $dcrVMinsights = Get-AzDataCollectionRule -Name $dataCollectionRuleVmInsightsName -ResourceGroupName $managementResourceGroupName -ErrorAction SilentlyContinue
    if ($dcrVMinsights) {
        Write-Host "- Found existing data collection rule: $($dcrVMinsights.Name) ..." -ForegroundColor DarkGray
    }
    if (-NOT($dcrVMinsights)) {
        Write-Host "- Creating a data collection rule for VMInsights ..." -ForegroundColor DarkGreen
        New-AzResourceGroupDeployment -ResourceGroupName $managementResourceGroupName -TemplateFile ".\eslzArm\resourceGroupTemplates\dataCollectionRule-VmInsights.json" -TemplateParameterObject @{"userGivenDcrName" = $dataCollectionRuleVmInsightsName; "workspaceResourceId" = $workspaceResourceId; "workspaceLocation" = $location } > $null
    }
    $dataCollectionRuleResourceIdVMInsights = (Get-AzDataCollectionRule -Name $dataCollectionRuleVmInsightsName -ResourceGroupName $managementResourceGroupName).Id
    
    # Assign policies for VMInsights
    foreach ($scope in $scopes) {
        foreach ($template in $VMInsightsAssignmentTemplates) {
            if ($template -eq "DINE-VMMonitoringPolicyAssignment.json") {
                $vminsightsAssignment = Get-AzPolicyAssignment -Id "/providers/microsoft.management/managementgroups/$scope/providers/microsoft.authorization/policyassignments/Deploy-VM-Monitoring" -ErrorAction SilentlyContinue
            }
            if ($template -eq "DINE-VMSSMonitoringPolicyAssignment.json") {
                $vminsightsAssignment = Get-AzPolicyAssignment -Id "/providers/microsoft.management/managementgroups/$scope/providers/microsoft.authorization/policyassignments/Deploy-VMSS-Monitoring" -ErrorAction SilentlyContinue
            }
            if ($template -eq "DINE-VMHybridMonitoringPolicyAssignment.json") {
                $vminsightsAssignment = Get-AzPolicyAssignment -Id "/providers/microsoft.management/managementgroups/$scope/providers/microsoft.authorization/policyassignments/Deploy-vmHybr-Monitoring" -ErrorAction SilentlyContinue
            }
            if ($vminsightsAssignment) {
                Write-Host "- Found existing policy assignment: $($vminsightsAssignment.Name) on $($scope) ..." -ForegroundColor DarkGray
            }
            if (-NOT($vminsightsAssignment)) {
                if ($template -eq "DINE-VMHybridMonitoringPolicyAssignment.json") {
                    Write-Host "- Assigning policies for VMInsights ..." -ForegroundColor DarkGreen
                    New-AzManagementGroupDeployment -ManagementGroupId $scope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\$template" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $scope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdVMInsights } > $null
                }
                else {
                    Write-Host "- Assigning policies for VMInsights ..." -ForegroundColor DarkGreen
                    New-AzManagementGroupDeployment -ManagementGroupId $scope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\$template" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $scope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdVMInsights; "userAssignedIdentityResourceId" = $userAssignedIdentityResourceId } > $null
                }
            }
        }
    }

    # Assign roles to Managed Identities
    Add-RbacRolesToManagedIdentities -enterpriseScaleCompanyPrefix $eslzRoot -azureComputePolicyList @("Deploy-VM-Monitoring", "Deploy-VMSS-Monitoring") -arcEnabledPolicyList @("Deploy-vmHybr-Monitoring") > $null
}
function Deploy-ChangeTracking {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $location,

        [Parameter(Mandatory = $true)]
        [string]
        $eslzRoot,

        [Parameter(Mandatory = $true)]
        [string]
        $managementResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string]
        $workspaceResourceId,

        [Parameter(Mandatory = $true)]
        [string]
        $userAssignedIdentityName,

        [Parameter(Mandatory = $true)]
        [array]
        $scopes,

        [Parameter(Mandatory = $true)]
        [array]
        $ChangeTrackingAssignmentTemplates
    )
    $userAssignedIdentityResourceId = (Get-AzUserAssignedIdentity -Name $userAssignedIdentityName -ResourceGroupName $managementResourceGroupName).Id
    # Create a data collection rule for ChangeTracking
    $dataCollectionRuleChangeTrackingName = "dcr-changetracking-prod-$location-001"
    $dcrChangeTracking = Get-AzDataCollectionRule -Name $dataCollectionRuleChangeTrackingName -ResourceGroupName $managementResourceGroupName -ErrorAction SilentlyContinue
    if ($dcrChangeTracking) {
        Write-Host "- Found existing data collection rule: $($dcrChangeTracking.Name) ..." -ForegroundColor DarkGray
    }
    if (-NOT($dcrChangeTracking)) {
        Write-Host "- Creating a data collection rule for ChangeTracking ..." -ForegroundColor DarkGreen
        New-AzResourceGroupDeployment -ResourceGroupName $managementResourceGroupName -TemplateFile ".\eslzArm\resourceGroupTemplates\dataCollectionRule-CT.json" -TemplateParameterObject @{"dataCollectionRuleName" = $dataCollectionRuleChangeTrackingName; "workspaceResourceId" = $workspaceResourceId; "workspaceLocation" = $location } > $null
    }
    $dataCollectionRuleResourceIdChangeTracking = (Get-AzDataCollectionRule -Name $dataCollectionRuleChangeTrackingName -ResourceGroupName $managementResourceGroupName).Id
    
    # Assign policies for ChangeTracking
    foreach ($scope in $scopes) {
        foreach ($template in $ChangeTrackingAssignmentTemplates) {
            if ($template -eq "DINE-ChangeTrackingVMPolicyAssignment.json") {
                $changeTrackingAssignment = Get-AzPolicyAssignment -Id "/providers/microsoft.management/managementgroups/$scope/providers/microsoft.authorization/policyassignments/Deploy-VM-ChangeTrack" -ErrorAction SilentlyContinue
            }
            if ($template -eq "DINE-ChangeTrackingVMSSPolicyAssignment.json") {
                $changeTrackingAssignment = Get-AzPolicyAssignment -Id "/providers/microsoft.management/managementgroups/$scope/providers/microsoft.authorization/policyassignments/Deploy-VMSS-ChangeTrack" -ErrorAction SilentlyContinue
            }
            if ($template -eq "DINE-ChangeTrackingVMArcPolicyAssignment.json") {
                $changeTrackingAssignment = Get-AzPolicyAssignment -Id "/providers/microsoft.management/managementgroups/$scope/providers/microsoft.authorization/policyassignments/Deploy-vmArc-ChangeTrack" -ErrorAction SilentlyContinue
            }
            if ($changeTrackingAssignment) {
                Write-Host "- Found existing policy assignment: $($changeTrackingAssignment.Name) on $($scope) ..." -ForegroundColor DarkGray
            }
            if (-NOT($changeTrackingAssignment)) {
                if ($template -eq "DINE-ChangeTrackingVMArcPolicyAssignment.json") {
                    Write-Host "- Assigning policies for ChangeTracking ..." -ForegroundColor DarkGreen
                    New-AzManagementGroupDeployment -ManagementGroupId $scope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\$template" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $scope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdChangeTracking } > $null
                }
                else {
                    Write-Host "- Assigning policies for ChangeTracking ..." -ForegroundColor DarkGreen
                    New-AzManagementGroupDeployment -ManagementGroupId $scope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\$template" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $scope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdChangeTracking; "userAssignedIdentityResourceId" = $userAssignedIdentityResourceId } > $null
                }
            }
        }
    }

    # Assign roles to Managed Identities
    Add-RbacRolesToManagedIdentities -enterpriseScaleCompanyPrefix $eslzRoot -azureComputePolicyList @("Deploy-VM-ChangeTrack", "Deploy-VMSS-ChangeTrack") -arcEnabledPolicyList @("Deploy-vmArc-ChangeTrack") > $null

}
function Deploy-MDFCDefenderSQL {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $location,

        [Parameter(Mandatory = $true)]
        [string]
        $eslzRoot,

        [Parameter(Mandatory = $true)]
        [string]
        $managementResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string]
        $workspaceResourceId,

        [Parameter(Mandatory = $true)]
        [string]
        $userAssignedIdentityName,

        [Parameter(Mandatory = $true)]
        [array]
        $scopes,

        [Parameter(Mandatory = $true)]
        [array]
        $MDfCDefenderSQLAssignmentTemplates
    )
    $userAssignedIdentityResourceId = (Get-AzUserAssignedIdentity -Name $userAssignedIdentityName -ResourceGroupName $managementResourceGroupName).Id
    # Create a data collection rule for MDFC Defender SQL
    $dataCollectionRuleMdfcDefenderSqlName = "dcr-defendersql-prod-$location-001"
    $dcrMDfCDefenderSQL = Get-AzDataCollectionRule -Name $dataCollectionRuleMdfcDefenderSqlName -ResourceGroupName $managementResourceGroupName -ErrorAction SilentlyContinue
    if ($dcrMDfCDefenderSQL) {
        Write-Host "- Found existing data collection rule: $($dcrMDfCDefenderSQL.Name) ..." -ForegroundColor DarkGray
    }
    if (-NOT($dcrMDfCDefenderSQL)) {
        Write-Host "- Creating a data collection rule for MDFC Defender for SQL ..." -ForegroundColor DarkGreen
        New-AzResourceGroupDeployment -ResourceGroupName $managementResourceGroupName -TemplateFile ".\eslzArm\resourceGroupTemplates\dataCollectionRule-DefenderSQL.json" -TemplateParameterObject @{"userGivenDcrName" = $dataCollectionRuleMdfcDefenderSqlName; "workspaceResourceId" = $workspaceResourceId; "workspaceLocation" = $location } > $null
    }
    $dataCollectionRuleResourceIdMDfCDefenderSQL = (Get-AzDataCollectionRule -Name $dataCollectionRuleMdfcDefenderSqlName -ResourceGroupName $managementResourceGroupName).Id
    
    # Assign policies for MDFC Defender for SQL
    foreach ($scope in $scopes) {
        foreach ($template in $MDfCDefenderSQLAssignmentTemplates) {
            $mdfcDefenderSQLAssignment = Get-AzPolicyAssignment -Id "/providers/microsoft.management/managementgroups/$scope/providers/microsoft.authorization/policyassignments/Deploy-MDFC-DefSQL-AMA" -ErrorAction SilentlyContinue
            if ($mdfcDefenderSQLAssignment) {
                Write-Host "- Found existing policy assignment: $($mdfcDefenderSQLAssignment.Name) on $($scope) ..." -ForegroundColor DarkGray
            }
            if (-NOT($mdfcDefenderSQLAssignment)) {
                Write-Host "- Assigning policies for MDFC Defender for SQL ..." -ForegroundColor DarkGreen
                New-AzManagementGroupDeployment -ManagementGroupId $scope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\$template" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "userWorkspaceResourceId" = $workspaceResourceId; "workspaceRegion" = $workspaceRegion; "dcrResourceId" = $dataCollectionRuleResourceIdMDfCDefenderSQL; "userAssignedIdentityResourceId" = $userAssignedIdentityResourceId } > $null
            }
        }
    }

    # Assign roles to Managed Identities
    Add-RbacRolesToManagedIdentities -enterpriseScaleCompanyPrefix $eslzRoot -azureComputePolicyList @("Deploy-MDFC-DefSQL-AMA") > $null
}
function Deploy-AzureUpdateManager {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $location,

        [Parameter(Mandatory = $true)]
        [string]
        $eslzRoot,

        [Parameter(Mandatory = $true)]
        [string]
        $managementResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string]
        $workspaceResourceId,

        [Parameter(Mandatory = $true)]
        [string]
        $userAssignedIdentityName
    )
    foreach ($scope in $scopes) {
        foreach ($template in $AzureUpdateManagerAssignmentTemplates) {
            $azureUpdateManagerAssignment = Get-AzPolicyAssignment -Id "/providers/microsoft.management/managementgroups/$scope/providers/microsoft.authorization/policyassignments/Enable-AUM-CheckUpdates" -ErrorAction SilentlyContinue
            if ($azureUpdateManagerAssignment) {
                Write-Host "- Found existing policy assignment: $($azureUpdateManagerAssignment.Name) on $($scope) ..." -ForegroundColor DarkGray
            }
            if (-NOT($azureUpdateManagerAssignment)) {
                Write-Host "- Assigning policies for Azure Update Manager ..." -ForegroundColor DarkGreen
                New-AzManagementGroupDeployment -ManagementGroupId $scope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\$template" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $scope } > $null
            }
        }
    }
}
function Remove-LegacySolutions {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $legacySolutions = Get-AzMonitorLogAnalyticsSolution | Where-Object { $_.Name -notlike "SecurityInsights*" -and $_.Name -notlike "ChangeTracking*" }
    if ($legacySolutions) {
        Write-Host "- Removing legacy solutions: $($legacySolutions.Name) ..." -ForegroundColor DarkRed
        $legacySolutions | Remove-AzMonitorLogAnalyticsSolution  > $null
    }
    if (-NOT($legacySolutions)) {
        Write-Host "- No legacy solutions found ..." -ForegroundColor DarkGray
    }
}

$landingZoneScope = "$eslzRoot-landingzones"
$platformScope = "$eslzRoot-platform"
$scopes = @(
    $platformScope, 
    $landingZoneScope
)
$legacyAssignments = @(
    "deploy-vm-monitoring", 
    "deploy-vmss-monitoring"
)
$userAssignedIdentityName = "id-ama-prod-$location-001"
$VMInsightsAssignmentTemplates = @(
    "DINE-VMMonitoringPolicyAssignment.json", 
    "DINE-VMSSMonitoringPolicyAssignment.json", 
    "DINE-VMHybridMonitoringPolicyAssignment.json"
)
$ChangeTrackingAssignmentTemplates = @(
    "DINE-ChangeTrackingVMPolicyAssignment.json", 
    "DINE-ChangeTrackingVMSSPolicyAssignment.json", 
    "DINE-ChangeTrackingVMArcPolicyAssignment.json"
)
$MDfCDefenderSQLAssignmentTemplates = @(
    "DINE-MDFCDefenderSQLAMAPolicyAssignment.json"
)
$AzureUpdateManagerAssignmentTemplates = @(
    "MODIFY-AUM-CheckUpdatesPolicyAssignment.json"
)
$policyRemediationList = @( 
    "c4a70814-96be-461c-889f-2b27429120dc",
    "92a36f05-ebc9-4bba-9128-b47ad2ea3354",
    "53448c70-089b-4f52-8f38-89196d7f2de1",
    "f5bf694c-cca7-4033-b883-3a23327d5485",
    "924bfe3a-762f-40e7-86dd-5c8b95eb09e6",
    "2b00397d-c309-49c4-aa5a-f0b2c5bc6321",
    "de01d381-bae9-4670-8870-786f89f49e26",
    "Deploy-AUM-CheckUpdates"
)

# Check for required modules
If (-NOT(Get-Module -ListAvailable Az.Resources)) {
    Write-Output "This script requires the Az.Resources module."
    $response = Read-Host "Would you like to install the 'Az.Resources' module now? (y/n)"
    If ($response -match '[yY]') { Install-Module Az.Resources -Scope CurrentUser }
}

If (-NOT(Get-Module -ListAvailable Az.Accounts)) {
    Write-Output "This script requires the Az.Accounts module."
    $response = Read-Host "Would you like to install the 'Az.Accounts' module now? (y/n)"
    If ($response -match '[yY]') { Install-Module Az.Accounts -Scope CurrentUser }
}

If (-NOT(Get-Module -ListAvailable Az.MonitoringSolutions)) {
    Write-Output "This script requires the Az.MonitoringSolutions module."
    $response = Read-Host "Would you like to install the 'Az.MonitoringSolutions' module now? (y/n)"
    If ($response -match '[yY]') { Install-Module Az.MonitoringSolutions -Scope CurrentUser }
}

# Update Policy Definitions
if ($UpdatePolicyDefinitions) {
    Write-Host "`r`nUpdating Policies ...`r`n" -ForegroundColor DarkBlue
    Update-Policies -eslzRoot $eslzRoot -location $location
}

# Remove legacy Policy Assignments
If ($RemoveLegacyPolicyAssignments) {
    Write-Host "`r`nRemoving legacy Policy Assignments ...`r`n" -ForegroundColor DarkBlue
    Remove-LegacyAssignments -eslzRoot $eslzRoot -legacyAssignments $legacyAssignments
}

# Deploy User Assigned Managed Identity
if ($DeployUserAssignedManagedIdentity -or $DeployVMInsights -or $DeployChangeTracking -or $DeployMDfCDefenderSQL) {
    Write-Host "`r`nDeploying User Assigned Managed Identity ...`r`n" -ForegroundColor DarkBlue
    Deploy-UserAssignedManagedIdentity -eslzRoot $eslzRoot -location $location -managementResourceGroupName $managementResourceGroupName -platformScope $platformScope -userAssignedIdentityName $userAssignedIdentityName
}

# Deploy VMInsights
if ($DeployVMInsights) {
    Write-Host "`r`nDeploying VMInsights ...`r`n" -ForegroundColor DarkBlue
    Deploy-VMInsights -location $location -eslzRoot $eslzRoot -managementResourceGroupName $managementResourceGroupName -workspaceResourceId $workspaceResourceId -userAssignedIdentityName $userAssignedIdentityName -scopes $scopes -VMInsightsAssignmentTemplates $VMInsightsAssignmentTemplates
}

# Deploy ChangeTracking
if ($DeployChangeTracking) {
    Write-Host "`r`nDeploying ChangeTracking ...`r`n" -ForegroundColor DarkBlue
    Deploy-ChangeTracking -location $location -eslzRoot $eslzRoot -managementResourceGroupName $managementResourceGroupName -workspaceResourceId $workspaceResourceId -userAssignedIdentityName $userAssignedIdentityName -scopes $scopes -ChangeTrackingAssignmentTemplates $ChangeTrackingAssignmentTemplates
}

# Deploy MDFC Defender for SQL
if ($DeployMDfCDefenderSQL) {
    Write-Host "`r`nDeploying MDFC Defender for SQL ...`r`n" -ForegroundColor DarkBlue
    Deploy-MDFCDefenderSQL -location $location -eslzRoot $eslzRoot -managementResourceGroupName $managementResourceGroupName -workspaceResourceId $workspaceResourceId -userAssignedIdentityName $userAssignedIdentityName -scopes $scopes -MDfCDefenderSQLAssignmentTemplates $MDfCDefenderSQLAssignmentTemplates
}

# Deploy Azure Update Manager
if ($DeployAzureUpdateManager) {
    Write-Host "`r`nDeploying Azure Update Manager ...`r`n" -ForegroundColor DarkBlue
    Deploy-AzureUpdateManager -location $location -eslzRoot $eslzRoot -managementResourceGroupName $managementResourceGroupName -workspaceResourceId $workspaceResourceId -userAssignedIdentityName $userAssignedIdentityName
}

# Remove legacy solutions
If ($RemoveLegacySolutions) {
    Write-Host "`r`nRemoving legacy solutions ...`r`n" -ForegroundColor DarkBlue
    Remove-LegacySolutions
}

# Policy Remediation
if ($RemediatePolicies) {
    Write-Host "`r`nRemediating policies ...`r`n" -ForegroundColor DarkBlue
    foreach ($policy in $policyRemediationList) {
        Get-PolicyType -managementGroupName $landingZoneScope -policyName $policy > $null
        Get-PolicyType -managementGroupName $platformScope -policyName $policy > $null
    }
}


# add removal of assignment Deploy-MDFC-DefenSQL-AMA and Deploy-UAMI-VMInsights