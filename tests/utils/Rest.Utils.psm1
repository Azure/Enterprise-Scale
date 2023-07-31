Import-Module -Name Az.Resources

<#
.SYNOPSIS
Await an asynchronous operation against the Azure REST API.

.DESCRIPTION
Helper method to await an asynchronous operation against the Azure REST API. Used as is from https://github.com/fawohlsc/azure-policy-testing.

.PARAMETER HttpResponse
The HTTP response returned from the asynchronous operation.

.PARAMETER MaxRetries
The maximum retries to monitor the status of the asynchronous operation (Default: 100 times).

.EXAMPLE
if ($httpResponse.StatusCode -eq 202) {
    $asyncOperation = $httpResponse | Wait-AsyncOperation
    if ($asyncOperation.Status -ne "Succeeded") {
        throw "Asynchronous operation failed with message: '$($asyncOperation)'"
    }
}

.LINK
https://github.com/Azure/azure-powershell/issues/13293

.LINK
https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/async-operations#status-codes-for-asynchronous-operations

.LINK
https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/async-operations#url-to-monitor-status
#>
function Wait-AsyncOperation {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [Microsoft.Azure.Commands.Profile.Models.PSHttpResponse]$HttpResponse,
        [Parameter()]
        [ValidateRange(1, [uint32]::MaxValue)]
        [uint32]$MaxRetries = 100
    )

    # Asynchronous operations either return HTTP status code 201 (Created) or 202 (Accepted).
    # See also: https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/async-operations#status-codes-for-asynchronous-operations
    if ($HttpResponse.StatusCode -notin @(201, 202)) {
        throw "HTTP response status code must be either '201' or '202' to indicate an asynchronous operation."
    }
        
    # Extracting retry after from HTTP Response Headers.
    # See also: https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/async-operations#url-to-monitor-status
    $retryAfter = $HttpResponse 
    | Get-HttpResponseHeaderValues -HeaderName "Retry-After" 
    | Select-Object -First 1 

    # Extracting status URL from HTTP Response Headers.
    $statusUrl = $HttpResponse 
    | Get-HttpResponseHeaderValues -HeaderName "Azure-AsyncOperation" 
    | Select-Object -First 1 
   
    if ($null -eq $statusUrl) {
        $statusUrl = $HttpResponse 
        | Get-HttpResponseHeaderValues -HeaderName "Location" 
        | Select-Object -First 1 
    }

    if ($null -eq $statusUrl) {
        throw "HTTP response does not contain any header 'Azure-AsyncOperation' or 'Location' containing the URL to monitor the status of the asynchronous operation."
    }

    # Convert status URL to path.
    $statusPath = $statusUrl.Replace("https://management.azure.com", "")
    
    # Monitor status of asynchronous operation.
    $httpResponse = $null
    $retries = 0
    do {
        $asyncOperation = Invoke-AzRestMethod -Path $statusPath -Method "GET"
        | Select-Object -ExpandProperty Content
        | ConvertFrom-Json
        
        if ($asyncOperation.Status -in @("Succeeded", "Failed", "Canceled")) {
            break
        }
        else {
            Start-Sleep -Second $retryAfter
            $retries++
        }
    } until ($retries -gt $MaxRetries) # Prevent endless loop, just defensive programming.

    if ($retries -gt $MaxRetries) {
        throw "Status of asynchronous operation '$($statusPath)' could not be retrieved even after $($MaxRetries) retries."
    }

    return $asyncOperation
}

<#
.SYNOPSIS
Gets HTTP header values from a HTTP response.

.DESCRIPTION
Helper method to extract HTTP header values from a HTTP response. Used as is from https://github.com/fawohlsc/azure-policy-testing.

.PARAMETER HttpResponse
The HTTP response.

.PARAMETER HeaderName
The name of the HTTP header.

.EXAMPLE
$statusUrl = $HttpResponse | Get-HttpResponseHeaderValues -HeaderName "Azure-AsyncOperation" | Select-Object -First 1
#>
function Get-HttpResponseHeaderValues {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [Microsoft.Azure.Commands.Profile.Models.PSHttpResponse]$HttpResponse,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$HeaderName
    )

    $headerValues = New-Object System.Collections.Generic.List[string] 
    $httpResponse.Headers.TryGetValues($HeaderName, [ref] $headerValues) > $null
    return $headerValues
}