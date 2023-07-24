<#
This script is used to trigger remediation on a specific policy or policy set at management group scope. 
It first calls the Azure REST API to get the policy assignments in the management group scope, then it iterates through the policy assignments, checking by name whether it's a policy set or an individual policy. 
Depending on the result the script will either enumerate the policy set and trigger remediation for each individual policy in the set or trigger remediation for the individual policy.

Examples: 
  #Modify the following variables to match your environment
  $managementGroupID = "The pseudo root management group id parenting the identity, management and connectivity management groups"
  $identityManagementGroup = "The management group id for Identity"
  $managementManagementGroup = "The management group id for Management"
  $connectivityManagementGroup = "The management group id for Connectivity"
  $LZManagementGroup="The management group id for Landing Zones"
  #Run the following commands to initiate remediation
  .src\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $managementManagementGroup -policyName Alerting-Management
  .src\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $connectivityManagementGroup -policyName Alerting-Connectivity
  .src\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $identityManagementGroup -policyName Alerting-Identity
  .src\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $LZManagementGroup -policyName Alerting-LandingZone
  .src\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $managementGroupId -policyName Alerting-ServiceHealth
#>

Param(
    [Parameter(Mandatory = $true)] [string] $managementGroupName,
    [Parameter(Mandatory = $true)] [string] $policyName
)

# Function to trigger remediation for a single policy
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
    }
    #if no policy assignments were found for the specified policy name, throw an error
    If(!$assignmentFound) {
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
    


#Main script

Get-PolicyType -managementGroupName $managementGroupName -policyName $policyName