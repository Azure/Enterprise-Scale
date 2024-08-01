# Update-AzureLandingZonesToAMA

> [!IMPORTANT]  
> This script intended for Azure Landing Zone Portal Accelerator deployments only. It is not for Terraform and Bicep deployments of ALZ.

## Description

We have created a script that can assist you with updating the Azure Landing Zones components. This script can automatically do the following tasks, you can turn on or off some parts of the script, see the Syntax section for more details:

- Update Policies and Initiatives.
- Delete outdated Policy Assignments.
- Deploy a User Assigned Managed Identity for the AMA agent.
- Deploys Data Collection Rules.
- Assign new Policies and Initiatives.
- Remove Legacy Solutions
- Create remediation tasks for the newly assigned Policies and initiatives.
- Remove obsolete User Assigned Managed Identities (that were deployed with releases starting 2024-01-31 until 2024-04-24)

> [!IMPORTANT]  
> The script will NOT remove the MMA agent. Please see [Removing MMA & additional steps](./ALZ-AMA-Migration-Guidance.md#removing-mma-and-additional-steps).

## Support

The ALZ team will support the PowerShell script for six months after MMA deprecation date, until February 28, 2025. Please report any issues here: [Issues](https://github.com/Azure/Enterprise-Scale/issues)

## Prerequisites

1. PowerShell 7 (Tested with version 7.4.2 on Windows)
2. Az Modules
   1. Az.Resources (Tested with version 7.1.0)
   2. Az.Accounts (Tested with version 3.0.0)
   3. Az.MonitoringSolutions (Tested with version 0.1.1)
   4. Az.ResourceGraph (Tested with version 1.0.0)
3. Git

> [!NOTE]  
> While other configurations and versions may work, please update first if you run into any issues before raising an [Issue](https://github.com/Azure/Enterprise-Scale/issues)

## Syntax

```powershell
Update-AzureLandingZonesToAMA
  [-location <string>] (Required)
  [-eslzRoot <string>] (Required)
  [-managementResourceGroupName <string>] (Required)
  [-workspaceResourceId <string>] (Required)
  [-workspaceRegion <string>] (Required)
  [-migrationPath <string>, accepted values "MMAToAMA", "UpdateAMA"] (Required)
  [-deployUserAssignedManagedIdentity <switch>] (Optional)
  [-deployVMInsights <switch>] (Optional)
  [-deployChangeTracking <switch>] (Optional)
  [-deployMDfCDefenderSQL <switch>] (Optional)
  [-deployAzureUpdateManager <switch>] (Optional)
  [-remediatePolicies <switch>] (Optional)
  [-removeLegacyPolicyAssignments <switch>] (Optional)
  [-removeLegacySolutions <switch>] (Optional)
  [-updatePolicyDefinitions <switch>] (Optional)
  [-removeObsoleteUAMI <switch>] (Optional)
```

## Examples

### Example 1: Update Policy Definitions

```powershell
.\src\scripts\Update-AzureLandingZonesToAMA.ps1 -location "northeurope" -eslzRoot "contoso" -managementResourceGroupName "contoso-mgmt" -workspaceResourceId "/subscriptions/{subscriptionId}/resourcegroups/contoso-mgmt/providers/microsoft.operationalinsights/workspaces/contoso-law" -workspaceRegion "northeurope" -migrationPath MMAToAMA -updatePolicyDefinitions


Updating Policies ...

- Updating Policy Definitions: Resource changes: 32 to create, 58 to modify, 68 no change. ...
- Updating Policy Set Definitions: Resource changes: 32 to create, 8 to modify, 5 no change. ...
```

### Example 2: Deploy VM Insights

```powershell
.\src\scripts\Update-AzureLandingZonesToAMA.ps1 -location "northeurope" -eslzRoot "contoso" -managementResourceGroupName "contoso-mgmt" -workspaceResourceId "/subscriptions/{subscriptionId}/resourcegroups/contoso-mgmt/providers/microsoft.operationalinsights/workspaces/contoso-law" -workspaceRegion "northeurope" -migrationPath MMAToAMA -removeLegacyPolicyAssignments -deployVMInsights


Removing legacy Policy Assignments ...

- Removing legacy Policy Assignments: Deploy-VM-Monitoring from scope contoso ...
- Removing legacy Policy Assignments: Deploy-VMSS-Monitoring from scope contoso ...

Deploying User Assigned Managed Identity ...

- Deploying User Assigned Managed Identity: Name: id-ama-prod-northeurope-001 to resource group contoso-mgmt; Resource changes: 1 to create, 12 to ignore. ...
- Assigning 'DenyAction-DeleteUAMIAMA' policy to scope contoso-platform ...

Deploying VMInsights ...

- Deploying a data collection rule for VMInsights: Name: dcr-vminsights-prod-northeurope-001 to resource group contoso-mgmt; Resource changes: 1 to create, 13 to ignore. ...
- Assigning policies for VMInsights: DINE-VMMonitoringPolicyAssignment.json to scope contoso-platform; Resource changes: 5 to create. ...
- Assigning policies for VMInsights: DINE-VMSSMonitoringPolicyAssignment.json to scope contoso-platform; Resource changes: 5 to create. ...
- Assigning policies for VMInsights: DINE-VMHybridMonitoringPolicyAssignment.json to scope contoso-platform; Resource changes: 3 to create. ...
- Assigning policies for VMInsights: DINE-VMMonitoringPolicyAssignment.json to scope contoso-landingzones; Resource changes: 5 to create. ...
- Assigning policies for VMInsights: DINE-VMSSMonitoringPolicyAssignment.json to scope contoso-landingzones; Resource changes: 5 to create. ...
- Assigning policies for VMInsights: DINE-VMHybridMonitoringPolicyAssignment.json to scope contoso-landingzones; Resource changes: 3 to create. ...
```

### Example 3: Using -WhatIf

```powershell
.\src\scripts\Update-AzureLandingZonesToAMA.ps1 -location "northeurope" -eslzRoot "contoso" -managementResourceGroupName "contoso-mgmt" -workspaceResourceId "/subscriptions/{subscriptionId}/resourcegroups/contoso-mgmt/providers/microsoft.operationalinsights/workspaces/contoso-law" -workspaceRegion "northeurope" -migrationPath MMAToAMA -removeLegacySolutions -WhatIf


Removing legacy solutions ...

What if: Performing the operation "- Removing legacy solutions: VMInsights(contoso-law)" on target "/subscriptions/{subscriptionId}/resourcegroups/contoso-mgmt/providers/microsoft.operationalinsights/workspaces/contoso-law".
What if: Performing the operation "- Removing legacy solutions: AgentHealthAssessment(contoso-law)" on target "/subscriptions/{subscriptionId}/resourcegroups/contoso-mgmt/providers/microsoft.operationalinsights/workspaces/contoso-law".
What if: Performing the operation "- Removing legacy solutions: Updates(contoso-law)" on target "/subscriptions/{subscriptionId}/resourcegroups/contoso-mgmt/providers/microsoft.operationalinsights/workspaces/contoso-law".
What if: Performing the operation "- Removing legacy solutions: SQLAssessment(contoso-law)" on target "/subscriptions/{subscriptionId}/resourcegroups/contoso-mgmt/providers/microsoft.operationalinsights/workspaces/contoso-law".
What if: Performing the operation "- Removing legacy solutions: SQLAdvancedThreatProtection(contoso-law)" on target "/subscriptions/{subscriptionId}/resourcegroups/contoso-mgmt/providers/microsoft.operationalinsights/workspaces/contoso-law".
What if: Performing the operation "- Removing legacy solutions: SQLVulnerabilityAssessment(contoso-law)" on target "/subscriptions/{subscriptionId}/resourcegroups/contoso-mgmt/providers/microsoft.operationalinsights/workspaces/contoso-law".
What if: Performing the operation "- Removing legacy solutions: Security(contoso-law)" on target "/subscriptions/{subscriptionId}/resourcegroups/contoso-mgmt/providers/microsoft.operationalinsights/workspaces/contoso-law".
```

## Parameters

### -location

The deployment location.

| Type          | String |
| ------------- | ------ |
| Required      | True   |
| Default value | None   |

### -eslzRoot

Intermediate root management group id.

| Type          | String |
| ------------- | ------ |
| Required      | True   |
| Default value | None   |

### -managementResourceGroupName

The management Resource Group name. This is `eslzRoot-mgmt`. For example `contoso-mgmt`.

| Type          | String |
| ------------- | ------ |
| Required      | True   |
| Default value | None   |

### -workspaceResourceId

Log Analytics workspace id. Expected format `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.OperationalInsights/workspaces/{workspaceName}`

| Type          | String |
| ------------- | ------ |
| Required      | True   |
| Default value | None   |

### -workspaceRegion

The Log Analytics workspace region.

| Type          | String |
| ------------- | ------ |
| Required      | True   |
| Default value | None   |

### -migrationPath

This parameter determines what parts of the script are available depending on your migration scenario.

1. Use `MMAToAMA` if you are currently using MMA and need to perform a full migration. Applies to release _2024-01-07_ and earlier.
2. Use `UpdateAMA` if you are currently using AMA that was deployed by the Portal Accelerator over the past months. Applies to releases; _2024-04-24, 2024-03-08, 2024-03-04, 2024-02-14, 2024-02-12, 2024-02-07, 2024-02-05, 2024-01-31_.

| Type                                 | String                                                                                                                                                                                                                                                         |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Required                             | True                                                                                                                                                                                                                                                           |
| Default value                        | None                                                                                                                                                                                                                                                           |
| Allowed values                       | "MMAToAMA", "UpdateAMA"                                                                                                                                                                                                                                        |
| Available parameters for `MMAToAMA`  | `UpdatePolicyDefinitions`<br>`RemoveLegacyPolicyAssignments`<br>`DeployUserAssignedManagedIdentity`<br>`DeployVMInsights`<br>`DeployChangeTracking`<br>`DeployMDfCDefenderSQL`<br>`DeployAzureUpdateManager`<br>`RemoveLegacySolutions`<br>`RemediatePolicies` |
| Available parameters for `UpdateAMA` | `UpdatePolicyDefinitions`<br>`RemoveLegacyPolicyAssignments`<br>`DeployUserAssignedManagedIdentity`<br>`DeployVMInsights`<br>`DeployChangeTracking`<br>`DeployMDfCDefenderSQL`<br>`RemediatePolicies`<br>`removeObsoleteUAMI`                                  |

### -deployUserAssignedManagedIdentity

Deploys a User Assigned Managed Identity to the Management Resource Group.

- Checks for an existing User Assignment Managed Identity `id-ama-prod-$location-001` in the management resource group.
- Checks for an existing policy assignment `DenyAction-DeleteUAMIAMA` on the platform management group scope.
- Deploys a User Assigned Managed Identity template [userAssignedIdentity.json](https://github.com/Azure/Enterprise-Scale/blob/main/eslzArm/resourceGroupTemplates/userAssignedIdentity.json).
- Deploys a Policy Assignment template [DENYACTION-DeleteUAMIAMAPolicyAssignment.json](https://github.com/Azure/Enterprise-Scale/blob/main/eslzArm/managementGroupTemplates/policyAssignments/DENYACTION-DeleteUAMIAMAPolicyAssignment.json).

| Type          | SwitchParameter |
| ------------- | --------------- |
| Required      | False           |
| Default value | None            |

### -deployVMInsights

Deploys the Data Collection Rule for VM Insights and assigns new policies. When it is run to Update AMA it will update the existing Policy Assignments to enable the single centralized UAMI by setting the feature flag `restrictBringYourOwnUserAssignedIdentityToSubscription` to `false`. Due to dependencies, running this command will also deploy the User Assigned Managed Identity resources.

- Checks for an existing Data Collection rule `dcr-vminsights-prod-$location-001` in the management Resource Group.
- Checks for existing policy assignments `Deploy-VM-Monitoring`, `Deploy-VMSS-Monitoring`, `Deploy-vmHybr-Monitoring` on the platform and landing zone scopes.
- Deploys a Data Collection Rule template [dataCollectionRule-VmInsights.json](https://github.com/Azure/Enterprise-Scale/blob/main/eslzArm/resourceGroupTemplates/dataCollectionRule-VmInsights.json).
- Deploys Policy Assignment templates; [DINE-VMMonitoringPolicyAssignment.json](https://github.com/Azure/Enterprise-Scale/blob/main/eslzArm/managementGroupTemplates/policyAssignments/DINE-VMMonitoringPolicyAssignment.json), [DINE-VMSSMonitoringPolicyAssignment.json](https://github.com/Azure/Enterprise-Scale/blob/main/eslzArm/managementGroupTemplates/policyAssignments/DINE-VMSSMonitoringPolicyAssignment.json), [DINE-VMHybridMonitoringPolicyAssignment.json](https://github.com/Azure/Enterprise-Scale/blob/main/eslzArm/managementGroupTemplates/policyAssignments/DINE-VMHybridMonitoringPolicyAssignment.json)

| Type          | SwitchParameter |
| ------------- | --------------- |
| Required      | False           |
| Default value | None            |

### -deployChangeTracking

Deploys the Data Collection Rule for Change Tracking and assigns new policies. When it is run to Update AMA it will update the existing Policy Assignments to enable the single centralized UAMI by setting the feature flag `restrictBringYourOwnUserAssignedIdentityToSubscription` to `false`. Due to dependencies, running this command will also deploy the User Assigned Managed Identity resources.

- Checks for an existing Data Collection rule `dcr-changetracking-prod-$location-001` in the management Resource Group.
- Checks for existing policy assignments `Deploy-VM-ChangeTrack`, `Deploy-VMSS-ChangeTrack`, `Deploy-vmArc-ChangeTrack` on the platform and landing zone scopes.
- Deploys a Data Collection Rule template [dataCollectionRule-CT.json](https://github.com/Azure/Enterprise-Scale/blob/main/eslzArm/resourceGroupTemplates/dataCollectionRule-CT.json).
- Deploys Policy Assignment templates; [DINE-ChangeTrackingVMPolicyAssignment.json](https://github.com/Azure/Enterprise-Scale/blob/main/eslzArm/managementGroupTemplates/policyAssignments/DINE-ChangeTrackingVMPolicyAssignment.json), [DINE-ChangeTrackingVMSSPolicyAssignment.json](https://github.com/Azure/Enterprise-Scale/blob/main/eslzArm/managementGroupTemplates/policyAssignments/DINE-ChangeTrackingVMSSPolicyAssignment.json), [DINE-ChangeTrackingVMArcPolicyAssignment.json](https://github.com/Azure/Enterprise-Scale/blob/main/eslzArm/managementGroupTemplates/policyAssignments/DINE-ChangeTrackingVMArcPolicyAssignment.json)

| Type          | SwitchParameter |
| ------------- | --------------- |
| Required      | False           |
| Default value | None            |

### -deployMDfCDefenderSQL

Deploys the Data Collection Rule for Defender for SQL and assigns new policies. Due to dependencies, running this command will also deploy the User Assigned Managed Identity resources.

- Checks for an existing Data Collection rule `dcr-defendersql-prod-$location-001` in the management Resource Group.
- Checks for an existing policy assignment `Deploy-MDFC-DefSQL-AMA` on the platform and landing zone scopes.
- Deploys a Data Collection Rule template [dataCollectionRule-DefenderSQL.json](https://github.com/Azure/Enterprise-Scale/blob/main/eslzArm/resourceGroupTemplates/dataCollectionRule-DefenderSQL.json).
- Deploys Policy Assignment template [DINE-MDFCDefenderSQLAMAPolicyAssignment.json](https://github.com/Azure/Enterprise-Scale/blob/main/eslzArm/managementGroupTemplates/policyAssignments/DINE-MDFCDefenderSQLAMAPolicyAssignment.json).

| Type          | SwitchParameter |
| ------------- | --------------- |
| Required      | False           |
| Default value | None            |

### -deployAzureUpdateManager

Configures Azure Update Manager.

- Checks for an existing policy assignment `Enable-AUM-CheckUpdates`.
- Deploys Policy Assignment template [MODIFY-AUM-CheckUpdatesPolicyAssignment.json](https://github.com/Azure/Enterprise-Scale/blob/main/eslzArm/managementGroupTemplates/policyAssignments/MODIFY-AUM-CheckUpdatesPolicyAssignment.json).

| Type          | SwitchParameter |
| ------------- | --------------- |
| Required      | False           |
| Default value | None            |

### -remediatePolicies

Creates remediation tasks for the following Policy Assignments:

- [[Preview]: Enable ChangeTracking and Inventory for virtual machine scale sets](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/c4a70814-96be-461c-889f-2b27429120dc.html)
- [[Preview]: Enable ChangeTracking and Inventory for virtual machines](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/92a36f05-ebc9-4bba-9128-b47ad2ea3354.html)
- [[Preview]: Enable ChangeTracking and Inventory for Arc-enabled virtual machines](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/53448c70-089b-4f52-8f38-89196d7f2de1.html)
- [Enable Azure Monitor for VMSS with Azure Monitoring Agent(AMA)](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/f5bf694c-cca7-4033-b883-3a23327d5485.html)
- [Enable Azure Monitor for VMs with Azure Monitoring Agent(AMA)](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/924bfe3a-762f-40e7-86dd-5c8b95eb09e6.html)
- [Enable Azure Monitor for Hybrid VMs with AMA](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/2b00397d-c309-49c4-aa5a-f0b2c5bc6321.html)
- [Configure SQL VMs and Arc-enabled SQL Servers to install Microsoft Defender for SQL and AMA with a user-defined LA workspace](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/de01d381-bae9-4670-8870-786f89f49e26.html)
- [Deploy-AUM-CheckUpdates](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Deploy-AUM-CheckUpdates.html)

| Type          | SwitchParameter |
| ------------- | --------------- |
| Required      | False           |
| Default value | None            |

### -removeLegacyPolicyAssignments

Removes deprecated policy assignments.

When combined with parameter `-MMAToAMA` it removes assignments:

- deploy-vm-monitoring
- deploy-vmss-monitoring

When combined with parameter `-UpdateAMA` it removes assignments:

- deploy-mdfc-defensql-ama
- deploy-uami-vminsights

| Type          | SwitchParameter |
| ------------- | --------------- |
| Required      | False           |
| Default value | None            |

### -removeLegacySolutions

Removes all Legacy Solutions from the specified Log Analytics workspace except for `SecurityInsights` which is used by Microsoft Sentinel and `ChangeTracking`.

| Type          | SwitchParameter |
| ------------- | --------------- |
| Required      | False           |
| Default value | None            |

### -updatePolicyDefinitions

Updates custom Policy and Policy Set Definitions.

| Type          | SwitchParameter |
| ------------- | --------------- |
| Required      | False           |
| Default value | None            |

### -removeObsoleteUAMI

Initially a User Assigned Identity was created for each subscription. After implementing the AMA updates a new centralized UAMI will replace the existing Identities. When the centralized Identity is assigned to the VM/VMSS it is highly recommended to removed the previously created identities.

If the Identity resource group is empty, it will also be removed.

| Type          | SwitchParameter |
| ------------- | --------------- |
| Required      | False           |
| Default value | None            |

### -obsoleteUAMIResourceGroupName

Specify the resource group name of the obsolete User Assigned Managed Identity.

| Type          | String            |
| ------------- | ----------------- |
| Required      | False             |
| Default value | "rg-ama-prod-001" |

### -WhatIf

Shows what would happen if the script runs. The script is not run.

| Type          | SwitchParameter |
| ------------- | --------------- |
| Required      | False           |
| Default value | None            |
