Import-Module -Name Az.Resources

<#
.SYNOPSIS
Cleans up any Azure resources created during the test.

.DESCRIPTION
Cleans up any Azure resources created during the test. If any clean-up operation fails, the whole test will fail. Used as is from https://github.com/fawohlsc/azure-policy-testing.

.PARAMETER CleanUp
The script block specifying the clean-up operations.

.EXAMPLE
AzCleanUp {
    Remove-AzResourceGroup -Name $ResourceGroup.ResourceGroupName -Force
}
#>
function AzCleanUp {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [ScriptBlock] $CleanUp
    )

    try {
        # Remember $ErrorActionPreference.
        $errorAction = $ErrorActionPreference

        # Stop clean-up on errors, since $ErrorActionPreference defaults to 'Continue' in PowerShell.
        $ErrorActionPreference = "Stop" 

        # Execute clean-up script.
        $CleanUp.Invoke()

        # Reset $ErrorActionPreference to previous value.
        $ErrorActionPreference = $errorAction
    }
    catch {
        throw "Clean-up failed with message: '$($_)'"
    }
}

<#
.SYNOPSIS
Retries the test on transient errors.

.DESCRIPTION
Retries the script block when a transient errors occurs during test execution. Used as is from https://github.com/fawohlsc/azure-policy-testing.

.PARAMETER Retry
The script block specifying the test.

.PARAMETER MaxRetries
The maximum amount of retries in case of transient errors (Default: 3 times).

.EXAMPLE
AzRetry {
    # When a dedicated resource group should be created for the test
    if ($ResourceGroup) {
        try {
            $resourceGroup = New-ResourceGroupTest
            Invoke-Command -ScriptBlock $Test -ArgumentList $resourceGroup
        }
        finally {
            # Stops on failures during clean-up 
            CleanUp {
                Remove-AzResourceGroup -Name $ResourceGroup.ResourceGroupName -Force -AsJob
            }
        }
    }
    else {
        Invoke-Command -ScriptBlock $Test
    }
}
#>
function AzRetry {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [ScriptBlock] $Retry,
        [Parameter()]
        [ValidateRange(1, [ushort]::MaxValue)]
        [ushort]$MaxRetries = 3
    )

    $retries = 0
    do {
        try {
            $Retry.Invoke()

            # Exit loop when no exception was thrown.
            break
        }
        catch {
            # Determine root cause exception.
            $innermostException = Get-InnermostException $_.Exception
           
            # Rethrow exception when maximum retries are reached.
            if ($retries -ge $MaxRetries) {
                throw (New-Object System.Management.Automation.RuntimeException("Test failed even after $($MaxRetries) retries.", $_.Exception))
            }
            # Retry when exception is caused by a transient error.
            elseif ($innermostException -is [System.Threading.Tasks.TaskCanceledException]) {
                Write-Host "Test failed due to a transient error. Retrying..."
                $retries++
                continue
            }
            # Rethrow exception when it is caused by a non-transient error.
            else {
                throw $_.Exception
            }
        }
    } while ($retries -le $MaxRetries) # Prevent endless loop, just defensive programming.
}

<#
.SYNOPSIS
Wraps a test targeting Azure.

.DESCRIPTION
Wraps a test targeting Azure. Also retries the test on transient errors. Used as is from https://github.com/fawohlsc/azure-policy-testing.

.PARAMETER Test
The script block specifying the test.

.PARAMETER ResourceGroup
Creates a dedicated resource group for the test, which is automatically cleaned up afterwards.

.EXAMPLE
AzTest -ResourceGroup {
    param($ResourceGroup)
    
    # Your test code leveraging the resource group, which is automatically cleaned up afterwards.
}

.EXAMPLE
AzTest {
    try {
        # Your test code
    }
    finally {
        # Don't forget to wrap your clean-up operations in AzCleanUp, otherwise failures during clean-up might remain unnoticed.
        AzCleanUp {
            # Your clean-up code
        }
    }
}
#>
function AzTest {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [ScriptBlock] $Test,
        [Parameter()]
        [Switch] $ResourceGroup
    )

    # Retries the test on transient errors.
    AzRetry {
        # When a dedicated resource group should be created for the test.
        if ($ResourceGroup) {
            try {
                $resourceGroup = New-ResourceGroupTest
                Invoke-Command -ScriptBlock $Test -ArgumentList $resourceGroup
            }
            finally {
                # Stops on failures during clean-up. 
                AzCleanUp {
                    Remove-AzResourceGroup -Name $ResourceGroup.ResourceGroupName -Force -AsJob
                }
            }
        }
        else {
            Invoke-Command -ScriptBlock $Test
        }
    }
}

<#
.SYNOPSIS
Gets the innermost exception.

.DESCRIPTION
Gets the innermost exception or root cause. Used as is from https://github.com/fawohlsc/azure-policy-testing.

.PARAMETER Exception
The exception.

.EXAMPLE
$innermostException = Get-InnermostException $_.Exception

.EXAMPLE
$innermostException = Get-InnermostException -Exception $_.Exception
#>
function Get-InnermostException {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [System.Exception] $Exception
    )

    # Innermost exceptions do not have an inner exception.
    if ($null -eq $Exception.InnerException) {
        return $Exception
    }
    else {
        return Get-InnermostException $Exception.InnerException
    }
}

<#
.SYNOPSIS
Gets the default Azure region.

.DESCRIPTION
Gets the default Azure region, e.g. northeurope.

.EXAMPLE
$location = Get-ResourceLocationDefault
#>
function Get-ResourceLocationDefault {
    return "uksouth"
}

<#
.SYNOPSIS
Create a dedicated resource group for an automated test case.

.DESCRIPTION
Create a dedicated resource group for an automated test case. The resource group name will be a GUID to avoid naming collisions. Used as is from https://github.com/fawohlsc/azure-policy-testing.

.PARAMETER Location
The Azure region where the resource group is created, e.g. northeurope. When no location is provided, the default location is retrieved by using Get-ResourceLocationDefault.

.EXAMPLE
$resourceGroup = New-ResourceGroupTest

.EXAMPLE
$resourceGroup = New-ResourceGroupTest -Location "westeurope"
#>
function New-ResourceGroupTest {
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Location = (Get-ResourceLocationDefault)
    )
    
    $resourceGroup = New-AzResourceGroup -Name (New-Guid).Guid -Location $Location
    return $resourceGroup
}