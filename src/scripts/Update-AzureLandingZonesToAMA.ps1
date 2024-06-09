# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

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

    [Parameter()]
    [bool]
    $DeployVMInsights = $true,

    [Parameter()]
    [bool]
    $DeployChangeTracking = $true,

    [Parameter()]
    [bool]
    $DeployMDfCDefenderSQL = $true,

    [Parameter()]
    [bool]
    $DeployAzureUpdateManager = $true,

    [Parameter()]
    [bool]
    $RemediatePolicies = $true,

    [Parameter()]
    [bool]
    $RemoveLegacyPolicyAssignments = $true,

    [Parameter()]
    [bool]
    $RemoveLegacySolutions = $true,

    [Parameter()]
    [bool]
    $UpdatePolicyDefinitions = $true
)

function Add-RbacRolesToManagedIdentities {
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
Function Start-PolicyRemediation {
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

$landingZoneScope = "$eslzRoot-landingzones"
$platformScope = "$eslzRoot-platform"

# Check for required modules
try {
    if (-not (Get-Module -ListAvailable Az.Resources)) {
        Write-Output "This script requires the Az.Resources module."
        $response = Read-Host "Would you like to install the 'Az.Resources' module now? (y/n)"
        if ($response -match '[yY]') {
            Install-Module Az.Resources -Scope CurrentUser
        }
    }
}
catch {
    Write-Output "An error occurred while checking for the Az.Resources module: $_"
}

try {
    if (-not (Get-Module -ListAvailable Az.MonitoringSolutions)) {
        Write-Output "This script requires the Az.MonitoringSolutions module."
        $response = Read-Host "Would you like to install the 'Az.MonitoringSolutions' module now? (y/n)"
        if ($response -match '[yY]') {
            Install-Module Az.MonitoringSolutions -Scope CurrentUser
        }
    }
}
catch {
    Write-Output "An error occurred while checking for the Az.MonitoringSolutions module: $_"
}

if ($UpdatePolicyDefinitions) {
    # Update Policy Definitions
    New-AzManagementGroupDeployment -ManagementGroupId $eslzRoot -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyDefinitions\policies.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot }
    # Update Policy Set Definitions
    New-AzManagementGroupDeployment -ManagementGroupId $eslzRoot -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyDefinitions\initiatives.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot }
}

If ($RemoveLegacyPolicyAssignments) {
    # Remove legacy Policy Assignments
    Remove-AzPolicyAssignment -Id "/providers/microsoft.management/managementgroups/$eslzRoot/providers/microsoft.authorization/policyassignments/deploy-vm-monitoring"
    Remove-AzPolicyAssignment -Id "/providers/microsoft.management/managementgroups/$eslzRoot/providers/microsoft.authorization/policyassignments/deploy-vmss-monitoring"
}

if ($DeployVMInsights -or $DeployChangeTracking -or $DeployMDfCDefenderSQL) {
    # Deploy User Assigned Managed Identity
    $userAssignedIdentityName = "id-ama-prod-$location-001"
    New-AzResourceGroupDeployment -ResourceGroupName $managementResourceGroupName -TemplateFile ".\eslzArm\resourceGroupTemplates\userAssignedIdentity.json" -TemplateParameterObject @{"location" = $location; "userAssignedIdentityName" = $userAssignedIdentityName; "userAssignedIdentityResourceGroup" = $managementResourceGroupName }
    # Do now allow deletion of the user assigned identity
    New-AzManagementGroupDeployment -ManagementGroupId $platformScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DENYACTION-DeleteUAMIAMAPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "resourceName" = $userAssignedIdentityName; "resourceType" = "Microsoft.ManagedIdentity/userAssignedIdentities" }
    $userAssignedIdentityResourceId = (Get-AzUserAssignedIdentity -Name $userAssignedIdentityName -ResourceGroupName $managementResourceGroupName).Id
}

if ($DeployVMInsights) {
    # Create a data collection rule for VMInsights
    $dataCollectionRuleVmInsightsName = "dcr-vminsights-prod-$location-001"
    New-AzResourceGroupDeployment -ResourceGroupName $managementResourceGroupName -TemplateFile ".\eslzArm\resourceGroupTemplates\dataCollectionRule-VmInsights.json" -TemplateParameterObject @{"userGivenDcrName" = $dataCollectionRuleVmInsightsName; "workspaceResourceId" = $workspaceResourceId; "workspaceLocation" = $location }
    $dataCollectionRuleResourceIdVMInsights = (Get-AzDataCollectionRule -Name $dataCollectionRuleVmInsightsName -ResourceGroupName $managementResourceGroupName).Id
    # VMInsights Azure Virtual Machines to platform management group
    New-AzManagementGroupDeployment -ManagementGroupId $platformScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DINE-VMMonitoringPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $platformScope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdVMInsights; "userAssignedIdentityResourceId" = $userAssignedIdentityResourceId }
    # VMInsights Azure Virtual Machines to landing zone management group
    New-AzManagementGroupDeployment -ManagementGroupId $landingZoneScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DINE-VMMonitoringPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $landingZoneScope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdVMInsights; "userAssignedIdentityResourceId" = $userAssignedIdentityResourceId }
    # VMInsights Azure Virtual Machine Scale Sets to platform management group
    New-AzManagementGroupDeployment -ManagementGroupId $platformScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DINE-VMSSMonitoringPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $platformScope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdVMInsights; "userAssignedIdentityResourceId" = $userAssignedIdentityResourceId }
    # VMInsights Azure Virtual Machine Scale Sets to landing zone management group
    New-AzManagementGroupDeployment -ManagementGroupId $landingZoneScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DINE-VMSSMonitoringPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $landingZoneScope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdVMInsights; "userAssignedIdentityResourceId" = $userAssignedIdentityResourceId }
    # VMInsights Arc-enabled VMs to platform management group
    New-AzManagementGroupDeployment -ManagementGroupId $platformScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DINE-VMHybridMonitoringPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $platformScope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdVMInsights }
    # VMInsights Arc-enabled VMs to landing zone management group
    New-AzManagementGroupDeployment -ManagementGroupId $landingZoneScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DINE-VMHybridMonitoringPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $landingZoneScope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdVMInsights }
    # Assigning Reader and Managed Identity Operator to VMInsights Managed Identity
    Add-RbacRolesToManagedIdentities -enterpriseScaleCompanyPrefix $eslzRoot -azureComputePolicyList @("Deploy-VM-Monitoring", "Deploy-VMSS-Monitoring") -arcEnabledPolicyList @("Deploy-vmHybr-Monitoring")
}

If ($DeployChangeTracking) {
    # Create a data collection rule for Change Tracking
    $dataCollectionRuleChangeTrackingName = "dcr-changetracking-prod-$location-001"
    New-AzResourceGroupDeployment -ResourceGroupName $managementResourceGroupName -TemplateFile ".\eslzArm\resourceGroupTemplates\dataCollectionRule-CT.json" -TemplateParameterObject @{"dataCollectionRuleName" = $dataCollectionRuleChangeTrackingName; "workspaceResourceId" = $workspaceResourceId; "workspaceLocation" = $location }
    $dataCollectionRuleResourceIdChangeTracking = (Get-AzDataCollectionRule -Name $dataCollectionRuleChangeTrackingName -ResourceGroupName $managementResourceGroupName).Id
    # Change Tracking Azure Virtual Machines to platform management group
    New-AzManagementGroupDeployment -ManagementGroupId $platformScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DINE-ChangeTrackingVMPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $platformScope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdChangeTracking; "userAssignedIdentityResourceId" = $userAssignedIdentityResourceId }
    # Change Tracking Azure Virtual Machines to landing zone management group
    New-AzManagementGroupDeployment -ManagementGroupId $landingZoneScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DINE-ChangeTrackingVMPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $landingZoneScope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdChangeTracking; "userAssignedIdentityResourceId" = $userAssignedIdentityResourceId }
    # Change Tracking Azure Virtual Machine Scale Sets to platform management group
    New-AzManagementGroupDeployment -ManagementGroupId $platformScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DINE-ChangeTrackingVMSSPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $platformScope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdChangeTracking; "userAssignedIdentityResourceId" = $userAssignedIdentityResourceId }
    # Change Tracking Azure Virtual Machine Scale Sets to landing zone management group
    New-AzManagementGroupDeployment -ManagementGroupId $landingZoneScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DINE-ChangeTrackingVMSSPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $landingZoneScope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdChangeTracking; "userAssignedIdentityResourceId" = $userAssignedIdentityResourceId }
    # Change Tracking Arc-enabled VMs to platform management group
    New-AzManagementGroupDeployment -ManagementGroupId $platformScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DINE-ChangeTrackingVMArcPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $platformScope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdChangeTracking }
    # Change Tracking Arc-enabled VMs to landing zone management group
    New-AzManagementGroupDeployment -ManagementGroupId $landingZoneScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DINE-ChangeTrackingVMArcPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $landingZoneScope; "dataCollectionRuleResourceId" = $dataCollectionRuleResourceIdChangeTracking }
    # Assigning Reader and Managed Identity Operator to VMInsights Managed Identity
    Add-RbacRolesToManagedIdentities -enterpriseScaleCompanyPrefix $eslzRoot -azureComputePolicyList @("Deploy-VM-ChangeTrack", "Deploy-VMSS-ChangeTrack") -arcEnabledPolicyList @("Deploy-vmArc-ChangeTrack")
}

If ($DeployMDfCDefenderSQL) {
    # Create a data collection rule for MDFC Defender SQL
    $dataCollectionRuleMdfcDefenderSqlName = "dcr-defendersql-prod-$location-001"
    New-AzResourceGroupDeployment -ResourceGroupName $managementResourceGroupName -TemplateFile ".\eslzArm\resourceGroupTemplates\dataCollectionRule-DefenderSQL.json" -TemplateParameterObject @{"userGivenDcrName" = $dataCollectionRuleMdfcDefenderSqlName; "workspaceResourceId" = $workspaceResourceId; "workspaceLocation" = $location }
    $dataCollectionRuleResourceIdMDfCDefenderSQL = (Get-AzDataCollectionRule -Name $dataCollectionRuleMdfcDefenderSqlName -ResourceGroupName $managementResourceGroupName).Id
    # MDFC Defender for SQL AMA initiative to platform management group
    New-AzManagementGroupDeployment -ManagementGroupId $platformScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DINE-MDFCDefenderSQLAMAPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "userWorkspaceResourceId" = $workspaceResourceId; "workspaceRegion" = $workspaceRegion; "dcrResourceId" = $dataCollectionRuleResourceIdMDfCDefenderSQL; "userAssignedIdentityResourceId" = $userAssignedIdentityResourceId; "scope" = $platformScope }
    # MDFC Defender for SQL AMA initiative to landing zone management group
    New-AzManagementGroupDeployment -ManagementGroupId $landingZoneScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\DINE-MDFCDefenderSQLAMAPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "userWorkspaceResourceId" = $workspaceResourceId; "workspaceRegion" = $workspaceRegion; "dcrResourceId" = $dataCollectionRuleResourceIdMDfCDefenderSQL; "userAssignedIdentityResourceId" = $userAssignedIdentityResourceId; "scope" = $landingZoneScope }
    # Assigning Reader and Managed Identity Operator to VMInsights Managed Identity
    Add-RbacRolesToManagedIdentities -enterpriseScaleCompanyPrefix $eslzRoot -azureComputePolicyList @("Deploy-MDFC-DefSQL-AMA")
}

If ($DeployAzureUpdateManager) {
    ## Azure Update Manager policy to platform management group
    New-AzManagementGroupDeployment -ManagementGroupId $platformScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\MODIFY-AUM-CheckUpdatesPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $platformScope }
    ## Azure Update Manager policy to landing zone management group
    New-AzManagementGroupDeployment -ManagementGroupId $landingZoneScope -Location $location -TemplateFile ".\eslzArm\managementGroupTemplates\policyAssignments\MODIFY-AUM-CheckUpdatesPolicyAssignment.json" -TemplateParameterObject @{"topLevelManagementGroupPrefix" = $eslzRoot; "scope" = $landingZoneScope }
}

If ($RemoveLegacySolutions) {
    Get-AzMonitorLogAnalyticsSolution | Where-Object { $_.Name -notlike "SecurityInsights*" } | Remove-AzMonitorLogAnalyticsSolution
}
    
if ($RemediatePolicies) {
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
    # Policy Remediation
    foreach ($policy in $policyRemediationList) {
        Get-PolicyType -managementGroupName $landingZoneScope -policyName $policy
        Get-PolicyType -managementGroupName $platformScope -policyName $policy
    }
}


# add removal of assignment Deploy-MDFC-DefenSQL-AMA and Deploy-UAMI-VMInsights