Import-Module -Name Az.Resources

<#
.SYNOPSIS
Completes a policy compliance scan.

.DESCRIPTION
Starts a policy compliance scan and awaits it's completion. In case of a failure, the policy compliance scan is retried (Default: 3 times). Used as is from https://github.com/fawohlsc/azure-policy-testing.

.PARAMETER ResourceGroup
The resource group to be scanned for policy compliance.

.PARAMETER MaxRetries
The maximum amount of retries in case of failures (Default: 3 times).

.EXAMPLE
$ResourceGroup | Complete-PolicyComplianceScan 
#>
function Complete-PolicyComplianceScan {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroup]$ResourceGroup,
        [Parameter()]
        [ValidateRange(1, [ushort]::MaxValue)]
        [ushort]$MaxRetries = 3
    )

    # Policy compliance scan might fail, hence retrying to avoid flaky tests.
    $retries = 0
    do {
        $job = Start-AzPolicyComplianceScan -ResourceGroupName $ResourceGroup.ResourceGroupName -PassThru -AsJob 
        $succeeded = $job | Wait-Job | Receive-Job
        
        if ($succeeded) {
            break
        }
        # Failure: Retry policy compliance scan when still below maximum retries.
        elseif ($retries -le $MaxRetries) {
            Write-Host "Policy compliance scan for resource group '$($ResourceGroup.ResourceId)' failed. Retrying..."
            $retries++
            continue # Not required, just defensive programming.
        }
        # Failure: Policy compliance scan is still failing after maximum retries.
        else {
            throw "Policy compliance scan for resource group '$($ResourceGroup.ResourceId)' failed even after $($MaxRetries) retries."
        }
    } while ($retries -le $MaxRetries) # Prevent endless loop, just defensive programming.
}

<#
.SYNOPSIS
Completes a policy remediation.

.DESCRIPTION
Starts a remediation for a policy and awaits it's completion. In case of a failure, the policy remediation is retried (Default: 3 times). Used as is from https://github.com/fawohlsc/azure-policy-testing.

.PARAMETER Resource
The resource to be remediated.

.PARAMETER PolicyDefinitionName
The name of the policy definition.

.PARAMETER CheckDeployment
The switch to determine if a deployment is expected. If a deployment is expected but did not happen during policy remediation, the policy remediation is retried.

.PARAMETER MaxRetries
The maximum amount of retries in case of failures (Default: 3 times).

.EXAMPLE
$routeTable | Complete-PolicyRemediation -PolicyDefinition "Modify-RouteTable-NextHopVirtualAppliance" -CheckDeployment
#>
function Complete-PolicyRemediation {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [Microsoft.Azure.Commands.Network.Models.PSChildResource]$Resource,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$PolicyDefinitionName,
        [Parameter()]
        [switch]$CheckDeployment,
        [Parameter()]
        [ValidateRange(1, [ushort]::MaxValue)]
        [ushort]$MaxRetries = 3
    )
    
    # Determine policy assignment id-
    $scope = "/subscriptions/$((Get-AzContext).Subscription.Id)"
    $policyAssignmentId = (Get-AzPolicyAssignment -Scope $scope
        | Select-Object -Property PolicyAssignmentId -ExpandProperty Properties 
        | Where-Object { $_.PolicyDefinitionId.EndsWith($PolicyDefinitionName) } 
        | Select-Object -Property PolicyAssignmentId -First 1
    ).PolicyAssignmentId
    
    if ($null -eq $policyAssignmentId) {
        throw "Policy '$($PolicyDefinitionName)' is not assigned to scope '$($scope)'."
    }

    # Remediation might be started before all previous changes on the resource in scope are completed.
    # This race condition could lead to a successful remediation without any deployment being triggered.
    # When a deployment is expected, it might be required to retry remediation to avoid flaky tests.
    $retries = 0
    do {
        # Trigger and wait for remediation.
        $job = Start-AzPolicyRemediation `
            -Name "$($Resource.Name)-$([DateTimeOffset]::Now.ToUnixTimeSeconds())" `
            -Scope $Resource.Id `
            -PolicyAssignmentId $policyAssignmentId `
            -ResourceDiscoveryMode ReEvaluateCompliance `
            -AsJob
        $remediation = $job | Wait-Job | Receive-Job
        
        # Check remediation provisioning state and deployment when required .
        $succeeded = $remediation.ProvisioningState -eq "Succeeded"
        if ($succeeded) {
            if ($CheckDeployment) {
                $deployed = $remediation.DeploymentSummary.TotalDeployments -gt 0
                
                # Success: Deployment was triggered.
                if ($deployed) {
                    break 
                }
                # Failure: No deployment was triggered, so retry when still below maximum retries.
                elseif ($retries -le $MaxRetries) {
                    Write-Host "Policy '$($PolicyDefinitionName)' succeeded to remediated resource '$($Resource.Id)', but no deployment was triggered. Retrying..."
                    $retries++
                    continue # Not required, just defensive programming.
                }
                # Failure: No deployment was triggered even after maximum retries.
                else {
                    throw "Policy '$($PolicyDefinitionName)' succeeded to remediated resource '$($Resource.Id)', but no deployment was triggered even after $($MaxRetries) retries."
                }
            }
            # Success: No deployment need to checked, hence no retry required.
            else {
                break
            }
        }
        # Failure: Remediation failed, so retry when still below maximum retries.
        elseif ($retries -le $MaxRetries) {
            Write-Host "Policy '$($PolicyDefinitionName)' failed to remediate resource '$($Resource.Id)'. Retrying..."
            $retries++
            continue # Not required, just defensive programming.
        }
        # Failure: Remediation failed even after maximum retries.
        else {
            throw "Policy '$($PolicyDefinitionName)' failed to remediate resource '$($Resource.Id)' even after $($MaxRetries) retries."
        }
    } while ($retries -le $MaxRetries) # Prevent endless loop, just defensive programming.
}

<#
.SYNOPSIS
Gets the policy compliance state of a resource.

.DESCRIPTION
Gets the policy compliance state of a resource. In case of a failure, getting the policy compliance state is retried (Default: 30 times) after a few seconds of waiting (Default: 60s). Used as is from https://github.com/fawohlsc/azure-policy-testing.

.PARAMETER Resource
The resource to get the policy compliance state for. 

.PARAMETER PolicyDefinitionName
The name of the policy definition.

.PARAMETER WaitSeconds
The duration in seconds to wait between retries in case of failures (Default: 60s).

.PARAMETER MaxRetries
The maximum amount of retries in case of failures (Default: 3 times).

.EXAMPLE
$networkSecurityGroup | Get-PolicyComplianceState -PolicyDefinition "OP-Audit-NSGAny" | Should -BeFalse
#>
function Get-PolicyComplianceState {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [Microsoft.Azure.Commands.Network.Models.PSChildResource]$Resource,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$PolicyDefinitionName,
        [Parameter()]
        [ValidateRange(1, [ushort]::MaxValue)]
        [ushort]$WaitSeconds = 60,
        [Parameter()]
        [ValidateRange(1, [ushort]::MaxValue)]
        [ushort]$MaxRetries = 30
    )

    # Policy compliance scan might be completed, but policy compliance state might still be null due to race conditions.
    # Hence waiting a few seconds and retrying to get the policy compliance state to avoid flaky tests.
    $retries = 0
    do {
        $isCompliant = (Get-AzPolicyState `
                -PolicyDefinitionName $PolicyDefinitionName `
                -Filter "ResourceId eq '$($Resource.Id)'" `
        ).IsCompliant
        
        # Success: Policy compliance state is not null.
        if ($null -ne $isCompliant) {
            break
        }
        # Failure: Policy compliance state is null, so wait a few seconds and retry when still below maximum retries.
        elseif ($retries -le $MaxRetries) {
            Write-Host "Policy '$($PolicyDefinitionName)' completed compliance scan for resource '$($Resource.Id)', but policy compliance state is null. Retrying..."
            Start-Sleep -Seconds $WaitSeconds
            $retries++
            continue # Not required, just defensive programming.
        }
        # Failure: Policy compliance state still null after maximum retries.
        else {
            throw "Policy '$($PolicyDefinitionName)' completed compliance scan for resource '$($Resource.Id)', but policy compliance state is null even after $($MaxRetries) retries."
        }
    } while ($retries -le $MaxRetries) # Prevent endless loop, just defensive programming.

    return $isCompliant
}