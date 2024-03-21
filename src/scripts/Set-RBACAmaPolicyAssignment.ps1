#!/usr/bin/pwsh

#
# PowerShell Script
# - Assigns 'Reader' role permissions on Platform MG to the identities (Deploy-vmHybr-Monitoring, Deploy-VM-Monitoring, Deploy-VMSS-Monitoring,
#     Deploy-vmArc-ChangeTrack, Deploy-VM-ChangeTrack, Deploy-VMSS-ChangeTrack) configured on the Landing Zones MG
# - Assigns 'Managed Identity Operator' on both Platform and Landing Zones MGs to the "Enable-AUM-CheckUpdates" identity
#

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'enterpriseScaleCompanyPrefix', Justification = 'False positive as rule does not know that Where-Object operates within the same scope')]

[CmdletBinding(SupportsShouldProcess)]
param(
    # the pseudo managemnt group to start from
    [Parameter(Mandatory = $True,
        ValueFromPipeline = $false)]
    [string]$enterpriseScaleCompanyPrefix
)

process {
    $vmiCtIdentityList = "Deploy-vmHybr-Monitoring", "Deploy-VM-Monitoring", "Deploy-VMSS-Monitoring", "Deploy-vmArc-ChangeTrack", "Deploy-VM-ChangeTrack", "Deploy-VMSS-ChangeTrack"
    $aumIdentityList = "Enable-AUM-CheckUpdates"

    If (-NOT(Get-Module -ListAvailable Az.Resources)) {
        Write-Output "This script requires the Az.Resources module."

        $response = Read-Host "Would you like to install the 'Az.Resources' module now? (y/n)"
        If ($response -match '[yY]') { Install-Module Az.Resources -Scope CurrentUser }
    }

    Write-Output "Retrieving Platform and Landing Zones management groups ..."

    # getting Platform and Landing Zones mgs
    $platformMg = Get-AzManagementGroup | Where-Object { $_.Name -like "$enterpriseScaleCompanyPrefix*-platform" } -ErrorAction SilentlyContinue
    $landingZonesMg = Get-AzManagementGroup | Where-Object { $_.Name -like "$enterpriseScaleCompanyPrefix*-landingzones" } -ErrorAction SilentlyContinue

    if ($platformMg -and $landingZonesMg) {
        # getting role assignments for both Platform and landing Zones mgs
        Write-Output "`tRetrieving role assignments on Platform management group ..."
        $platformMgAumRoleAssignments = Get-AzRoleAssignment -Scope $($platformMg.Id) | where-object { $_.Displayname -in $aumIdentityList } | Sort-Object -Property ObjectId -Unique

        Write-Output "`tRetrieving role assignments on Landing Zones management group ..."
        $landingZonesMgAumRoleAssignments = Get-AzRoleAssignment -Scope $($landingZonesMg.Id) | where-object { $_.Displayname -in $aumIdentityList } | Sort-Object -Property ObjectId -Unique
        $landingZonesMgVmiCtRoleAssignments = Get-AzRoleAssignment -Scope $($landingZonesMg.Id) | where-object { $_.Displayname -in $vmiCtIdentityList } | Sort-Object -Property ObjectId -Unique
        # Performing role assignments
        if ($landingZonesMgVmiCtRoleAssignments) {
            # assigning Reader role for VMI and CT Managed Identities from LandingZones to Platform mg
            Write-Output "`t`tAssigning 'Reader' role for 'VMInsights' and 'Change Tracking' Managed Identities from Landing Zones to Platform management group ..."
            $landingZonesMgVmiCtRoleAssignments | ForEach-Object { New-AzRoleAssignment -Scope $($platformMg.Id) -RoleDefinitionName 'Reader' -ObjectId $_.ObjectId -ErrorAction SilentlyContinue }
        }
        else {
            Write-Output "`t`tNo role assignment found on the Landing Zones management group for the given 'VMInsights' and 'Change Tracking' Managed Identities."
        }

        if ($landingZonesMgAumRoleAssignments) {
            # assigning Managed Identity Operator to Azure Update Manager Managed Identity on Landing Zones mg
            Write-Output "`t`tAssigning 'Managed Identity Operator' role to 'Azure Update Manager' Managed Identity on Landing Zones management group ..."
            $landingZonesMgAumRoleAssignments | ForEach-Object { New-AzRoleAssignment -Scope $($landingZonesMg.Id) -RoleDefinitionName 'Managed Identity Operator' -ObjectId $_.ObjectId -ErrorAction SilentlyContinue }
        }
        else {
            Write-Output "`t`tNo role assignment found on the Landing Zones management group for the given 'Azure Update Manger' Managed Identities."
        }

        if ($platformMgAumRoleAssignments) {
            # assigning Managed Identity Operator to Azure Update Manager Managed Identity on Platform mg
            Write-Output "`t`tAssigning 'Managed Identity Operator' role to 'Azure Update Manager' Managed Identity on Platform management group ..."
            $platformMgAumRoleAssignments | ForEach-Object { New-AzRoleAssignment -Scope $($platformMg.Id) -RoleDefinitionName 'Managed Identity Operator' -ObjectId $_.ObjectId-ErrorAction SilentlyContinue }
        }
        else {
            Write-Output "`t`tNo role assignment found on the Platform management group for the given 'Azure Update Manger' Managed Identity."
        }
    }
    else {
        Write-Output "`tOne or more management group of type 'Platform' and 'Landing Zones' was not found. Make sure you have the necessary permissions and/or that the hierachy is Azure Landing Zones aligned."
    }
}
End {
    Write-Output "Script execution completed."
}