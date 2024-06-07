#!/usr/bin/pwsh

using module "../Alz.Enums/"
using module "../Alz.Classes/"

###############################################
# Configure PSScriptAnalyzer rule suppression #
###############################################

# The following SuppressMessageAttribute entries are used to surpress
# PSScriptAnalyzer tests against known exceptions as per:
# https://github.com/powershell/psscriptanalyzer#suppressing-rules
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Function targets multiple line endings', Scope = 'Function', Target = 'Edit-LineEndings')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Function does not change system state', Scope = 'Function', Target = 'Remove-Escaping')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'SleepForSeconds', Justification = 'Used in child process', Scope = 'Function', Target = 'Invoke-RemoveMgHierarchy')]
param ()

#######################################
# Common variables used within module #
#######################################

[Int]$jsonDepth = 100

[Regex]$regex_schema_deploymentParameters = "http[s]?:\/\/schema\.management\.azure\.com\/schemas\/([0-9-]{10})\/deploymentParameters\.json#"
[Regex]$regex_schema_managementGroupDeploymentTemplate = "http[s]?:\/\/schema\.management\.azure\.com\/schemas\/([0-9-]{10})\/managementGroupDeploymentTemplate\.json#"
[Regex]$regex_firstLeftSquareBrace = "(?<=`")(\[)"
[Regex]$regex_escapedLeftSquareBrace = "(?<=`")(\[\[)"
[Regex]$regex_subscriptionAlias = "(?<prefix>[\w-]+?)-(?<scope>\w+)-?(?<secondOctet>[1-2]?[0-9]?[0-9])?$"

[String[]]$allowedResourceTypes = @(
    "Microsoft.Authorization/policyAssignments"
    "Microsoft.Authorization/policyDefinitions"
    "Microsoft.Authorization/policySetDefinitions"
    "Microsoft.Authorization/roleAssignments"
    "Microsoft.Authorization/roleDefinitions"
    "Microsoft.Management/managementGroups"
    "Microsoft.Management/managementGroups/subscriptions"
)

[String[]]$removePolicyEscapingByFormat = @(
    "Terraform"
    "Bicep"
)

[String[]]$removePolicySetEscapingByFormat = @(
    "Terraform"
)

[String[]]$removeResourceEscapingByFormat = @(
    "Terraform"
)

################################
# Functions used within module #
################################

function ProcessObjectByResourceType {
    [CmdletBinding()]
    [OutputType([Object])]
    param (
        [Parameter()][Object]$ResourceObject,
        [Parameter()][String]$ResourceType
    )
    try {
        switch ($ResourceType.ToLower()) {
            "microsoft.authorization/policyassignments" {
                $outputObject = [PolicyAssignment]::new($ResourceObject)
            }
            "microsoft.authorization/policydefinitions" {
                $outputObject = [PolicyDefinition]::new($ResourceObject)
            }
            "microsoft.authorization/policysetdefinitions" {
                $outputObject = [PolicySetDefinition]::new($ResourceObject)
                # Workaround for policySetDefinitions that only have a single policyDefinition. PowerShell tires to convert to an object in that scenario.
                if($outputObject.properties.policyDefinitions.GetType().ToString() -eq "PolicySetDefinitionPropertiesPolicyDefinitions") {
                    $outputObject.properties.policyDefinitions = @($outputObject.properties.policyDefinitions)
                }
            }
            "microsoft.authorization/roleassignments" {
                $outputObject = [RoleAssignment]::new($ResourceObject)
            }
            "microsoft.authorization/roledefinitions" {
                $outputObject = [RoleDefinition]::new($ResourceObject)
            }
            Default {
                Write-Warning "Unsupported resource type: $($ResourceType)"
                $outputObject = $ResourceObject
            }
        }
    }
    catch [System.Management.Automation.RuntimeException] {
        Write-Error $_.Exception.Message
    }

    return $outputObject

}

function Add-Escaping {
    [CmdletBinding()]
    param (
        [Parameter()][Object]$InputObject
    )

    # A number of sources store the required definition in variables
    # which use escaping for ARM functions so they are correctly
    # processed within copy_loops. These may need to be added when
    # converting from a native ARM template.
    $output = $InputObject |
    ConvertTo-Json -Depth $jsonDepth |
    ForEach-Object { $_ -replace $regex_firstLeftSquareBrace, "[[" } |
    ConvertFrom-Json

    return $output
}

function Remove-Escaping {
    [CmdletBinding()]
    param (
        [Parameter()][Object]$InputObject
    )

    # A number of sources store the required definition in variables
    # which use escaping for ARM functions so they are correctly
    # processed within copy_loops. These may need to be removed when
    # converting to a native ARM template.
    $output = $InputObject |
    ConvertTo-Json -Depth $jsonDepth |
    ForEach-Object { $_ -replace $regex_escapedLeftSquareBrace, "[" } |
    ConvertFrom-Json

    return $output
}

function GetObjectByResourceTypeFromJson {
    [CmdletBinding()]
    [OutputType([Object])]
    param (
        [Parameter()][String]$Id,
        [Parameter()][String[]]$InputJSON,
        [Parameter()][ExportFormat]$ExportFormat
    )

    # Try catch is used to gracefully handle type conversion errors when the input contains invalid JSON
    try {
        $objectFromJson = $InputJSON | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        throw $_.Exception.Message
    }

    # The following block handles processing files in the format generated by the AzOps output
    # e.g. azopsreference/ folder in Azure/Enterprise-Scale repository
    if ($regex_schema_deploymentParameters.IsMatch($objectFromJson."`$schema")) {
        if ($objectFromJson.parameters.input.value.ResourceType) {
            ProcessObjectByResourceType `
                -ResourceObject ($objectFromJson.parameters.input.value) `
                -ResourceType ($objectFromJson.parameters.input.value.ResourceType)
        }
    }
    # The following block handles processing files in the format used by the ALZ reference deployments
    # e.g. eslzArm/managementGroupTemplates/policyDefinitions/ folder in Azure/Enterprise-Scale repository
    elseif ($regex_schema_managementGroupDeploymentTemplate.IsMatch($objectFromJson."`$schema")) {
        foreach ($policyDefinition in $objectFromJson.variables.policies.policyDefinitions) {
            ProcessObjectByResourceType `
                -ResourceObject ($ExportFormat -in $removePolicyEscapingByFormat ? (Remove-Escaping -InputObject $policyDefinition) : $policyDefinition) `
                -ResourceType ("Microsoft.Authorization/policyDefinitions")
        }
        foreach ($policySetDefinition in $objectFromJson.variables.initiatives.policySetDefinitions) {
            ProcessObjectByResourceType `
                -ResourceObject ($ExportFormat -in $removePolicySetEscapingByFormat ? (Remove-Escaping -InputObject $policySetDefinition) : $policySetDefinition) `
                -ResourceType ("Microsoft.Authorization/policySetDefinitions")
        }
        foreach (
            $policyDefinition in $objectFromJson.resources |
            Where-Object { $_.type -eq "Microsoft.Authorization/policyDefinitions" } |
            Where-Object { $_.name -ne "[variables('policies').policyDefinitions[copyIndex()].name]" }
        ) {
            ProcessObjectByResourceType `
                -ResourceObject ($ExportFormat -in $removePolicyEscapingByFormat ? (Remove-Escaping -InputObject $policyDefinition) : $policyDefinition) `
                -ResourceType ("Microsoft.Authorization/policyDefinitions")
        }
        foreach (
            $policySetDefinition in $objectFromJson.resources |
            Where-Object { $_.type -eq "Microsoft.Authorization/policySetDefinitions" } |
            Where-Object { $_.name -ne "[variables('initiatives').policySetDefinitions[copyIndex()].name]" }
        ) {
            ProcessObjectByResourceType `
                -ResourceObject ($ExportFormat -in $removePolicySetEscapingByFormat ? (Remove-Escaping -InputObject $policySetDefinition) : $policySetDefinition) `
                -ResourceType ("Microsoft.Authorization/policySetDefinitions")
        }
    }
    # The following elseif block handles all policy definitions stored in ARM template format
    elseif ($objectFromJson.type -eq "Microsoft.Authorization/policyDefinitions") {
        ProcessObjectByResourceType `
            -ResourceObject ($ExportFormat -in $removePolicyEscapingByFormat ? (Remove-Escaping -InputObject $objectFromJson) : $objectFromJson) `
            -ResourceType $objectFromJson.type
    }
    # The following elseif block handles all policy set definitions stored in ARM template format
    elseif ($objectFromJson.type -eq "Microsoft.Authorization/policySetDefinitions") {
        ProcessObjectByResourceType `
            -ResourceObject ($ExportFormat -in $removePolicySetEscapingByFormat ? (Remove-Escaping -InputObject $objectFromJson) : $objectFromJson) `
            -ResourceType $objectFromJson.type
    }
    # The following elseif block handles all other allowed resource types stored in ARM template format
    elseif ($objectFromJson.type -in $allowedResourceTypes) {
        ProcessObjectByResourceType `
            -ResourceObject ($ExportFormat -in $removeResourceEscapingByFormat ? (Remove-Escaping -InputObject $objectFromJson) : $objectFromJson) `
            -ResourceType $objectFromJson.type
    }
    # The following block handles processing generic files where the source content is unknown
    # High probability of incorrect format if this happens.
    else {
        Write-Warning "Unable to find converter for input object: $Id"
    }

}

function ProcessFile {
    [CmdletBinding()]
    param (
        [Parameter()][String]$FilePath,
        [Parameter()][ExportFormat]$ExportFormat
    )

    $content = Get-Content -Path $FilePath

    $output = GetObjectByResourceTypeFromJson `
        -Id $FilePath `
        -InputJSON $content `
        -ExportFormat $ExportFormat

    return $output
}

function Invoke-UseCacheFromModule {
    param (
        [String]$Directory = "./"
    )
    [ProviderApiVersions]::LoadCacheFromDirectory($Directory)
}

function Invoke-UpdateCacheInModule {
    param (
        [String]$Directory = "./"
    )
    [ProviderApiVersions]::SaveCacheToDirectory($Directory)
}

function Edit-LineEndings {
    [CmdletBinding()]
    [OutputType([String[]])]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [String[]]$InputText,
        [Parameter()][LineEndingTypes]$LineEnding = "Unix"
    )

    Begin {

        Switch ("$LineEnding".ToLower()) {
            "darwin" { $eol = "`r" }
            "unix" { $eol = "`n" }
            "win" { $eol = "`r`n" }
        }

    }

    Process {

        [String[]]$outputText += $InputText |
        ForEach-Object { $_ -replace "`r`n", "`n" } |
        ForEach-Object { $_ -replace "`r", "`n" } |
        ForEach-Object { $_ -replace "`n", "$eol" }

    }

    End {

        return $outputText

    }

}

function ConvertTo-ArmTemplateResource {
    [CmdletBinding()]
    param (
        [Parameter()][String]$FilePath,
        [Parameter()][ExportFormat]$ExportFormat = "Raw",
        [Parameter()][Switch]$AsJson
    )

    $content = ProcessFile `
        -FilePath $FilePath `
        -ExportFormat $ExportFormat

    $output = $content.Format($ExportFormat)

    if ($AsJson) {
        return $output | ConvertTo-Json -Depth $jsonDepth
    }
    else {
        return $output
    }

}

function ConvertTo-LibraryArtifact {
    [CmdletBinding()]
    param (
        [Parameter()][String[]]$InputPath,
        [Parameter()][String]$InputFilter = "*.json",
        [Parameter()][String]$OutputPath = "./",
        [Parameter()][String]$FileNamePrefix = "",
        [Parameter()][String]$FileNameSuffix = ".json",
        [Parameter()][ExportFormat]$ExportFormat = "Raw",
        [Parameter()][Switch]$Recurse
    )
    $inputFiles = foreach ($path in $InputPath) {
        Get-ChildItem -Path $path -Recurse:$Recurse -Filter $InputFilter
    }

    [Object[]]$outputItems = foreach ($inputFile in $inputFiles) {
        $content = ProcessFile `
            -FilePath $inputFile.FullName `
            -ExportFormat $ExportFormat
        foreach ($item in $content | Where-Object { $_ }) {
            [PSCustomObject]@{
                InputFilePath  = $inputFile.FullName
                OutputFilePath = ($OutputPath + "/" + $item.GetFileName($FileNamePrefix, $FileNameSuffix, $ExportFormat)) -replace "//", "/"
                OutputTemplate = $item.Format($ExportFormat)
            }
        }
    }

    return $outputItems

}

function Export-LibraryArtifact {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()][String[]]$InputPath,
        [Parameter()][String]$InputFilter = "*.json",
        [ValidateScript({ $_.foreach({ $_ -in $allowedResourceTypes }) })]
        [Parameter()][String[]]$ResourceTypeFilter = @(),
        [Parameter()][String]$OutputPath = "./",
        [Parameter()][String]$FileNamePrefix = "",
        [Parameter()][String]$FileNameSuffix = ".json",
        [Parameter()][LineEndingTypes]$LineEnding = "Unix",
        [Parameter()][ExportFormat]$ExportFormat = "Raw",
        [Parameter()][Switch]$Recurse
    )

    $libraryArtifacts = ConvertTo-LibraryArtifact `
        -InputPath $InputPath `
        -InputFilter $InputFilter `
        -OutputPath $OutputPath `
        -FileNamePrefix $FileNamePrefix `
        -FileNameSuffix $FileNameSuffix `
        -ExportFormat $ExportFormat `
        -Recurse:$Recurse

    if ($ResourceTypeFilter.Length -eq 0) {
        Write-Verbose "Using default ResourceTypeFilter. Will process all valid resource types."
        $ResourceTypeFilter = [ProviderApiVersions]::ListTypes()
    }
    else {
        Write-Verbose "Using custom ResourceTypeFilter. Will process the following resource types:`n $($ResourceTypeFilter.foreach({" - " + $_ +"`n"}))"
    }

    foreach ($libraryArtifact in $libraryArtifacts) {
        $libraryArtifactMessage = ("Processing file... `n" + `
                " - Input  : $($libraryArtifact.InputFilePath) `n" + `
                " - Output : $($libraryArtifact.OutputFilePath)")

        if ($libraryArtifact.OutputTemplate.type -in $ResourceTypeFilter) {
            if ($PSCmdlet.ShouldProcess($libraryArtifact.OutputFilePath)) {
                $libraryArtifactFile = $libraryArtifact.OutputTemplate |
                ConvertTo-Json -Depth $jsonDepth |
                Edit-LineEndings -LineEnding $LineEnding |
                New-Item -Path $libraryArtifact.OutputFilePath -ItemType File -Force
                $libraryArtifactMessage += "`n [COMPLETE]"
                Write-Verbose $libraryArtifactMessage
                Write-Information "Output File : $($libraryArtifactFile.FullName) [COMPLETE]" -InformationAction Continue
            }
        }
        else {
            $libraryArtifactMessage += "`n [SKIPPING] Resource Type not in ResourceTypeFilter."
            Write-Verbose $libraryArtifactMessage
        }
    }
}

function Set-AzureSubscriptionAlias {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([Object[]])]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'PutAliasWithBillingScope')]
        [Parameter(Mandatory = $true, ParameterSetName = 'PutAliasWithSubscriptionId')]
        [Parameter(Mandatory = $true, ParameterSetName = 'GetAliasOnly')]
        [String[]]$Alias,
        [Parameter(Mandatory = $true, ParameterSetName = 'PutAliasWithBillingScope')]
        [String]$BillingScope,
        [Parameter(Mandatory = $true, ParameterSetName = 'PutAliasWithSubscriptionId')]
        [String]$SubscriptionId,
        [Parameter(Mandatory = $false, ParameterSetName = 'PutAliasWithBillingScope')]
        [String]$Workload = "Production",
        [Parameter(Mandatory = $false, ParameterSetName = 'PutAliasWithBillingScope')]
        [Parameter(Mandatory = $false, ParameterSetName = 'PutAliasWithSubscriptionId')]
        [Parameter(Mandatory = $false, ParameterSetName = 'GetAliasOnly')]
        [Switch]$SetParentManagementGroup,
        [Parameter(Mandatory = $false, ParameterSetName = 'PutAliasWithBillingScope')]
        [Parameter(Mandatory = $false, ParameterSetName = 'PutAliasWithSubscriptionId')]
        [Parameter(Mandatory = $false, ParameterSetName = 'GetAliasOnly')]
        [Switch]$SetAddressPrefix
    )

    # Get the latest stable API version
    $aliasesApiVersion = [ProviderApiVersions]::GetLatestStableByType("Microsoft.Subscription/aliases")
    Write-Information "Using Subscription Alias API Version : $($aliasesApiVersion)" -InformationAction Continue

    # Logic to determine whether to GET an existing Alias or PUT a new one
    $GetExistingAlias = [string]::IsNullOrEmpty($BillingScope) -and [string]::IsNullOrEmpty($SubscriptionId)
    $requestMethod = $GetExistingAlias ? "GET" : "PUT"

    # Process Alias value(s)
    $aliasResponses = @()
    foreach ($subscriptionName in $Alias) {
        Write-Verbose "Microsoft.Subscription/aliases/$($subscriptionName) [$requestMethod]"
        $requestPath = "/providers/Microsoft.Subscription/aliases/$($subscriptionName)?api-version=$($aliasesApiVersion)"
        if (-not [string]::IsNullOrEmpty($BillingScope)) {
            $action = "PutAliasWithBillingScope"
            $requestBodyObject = @{
                properties = @{
                    displayName          = $subscriptionName
                    billingScope         = $BillingScope
                    workload             = $Workload
                    additionalProperties = @{}
                }
            }
        }
        elseif (-not [string]::IsNullOrEmpty($SubscriptionId)) {
            $action = "PutAliasWithSubscriptionId"
            $requestBodyObject = @{
                properties = @{
                    subscriptionId       = $SubscriptionId
                    additionalProperties = @{}
                }
            }
        }
        else {
            $action = "GetAliasOnly"
            $requestBodyObject = @{}
        }
        $requestBody = $requestBodyObject | ConvertTo-Json -Depth $jsonDepth
        if ($PSCmdlet.ShouldProcess("$subscriptionName", "$action")) {
            $aliasResponse = Invoke-AzRestMethod -Method $requestMethod -Path $requestPath -Payload $requestBody
        }
        else {
            $aliasResponse = [ordered]@{
                StatusCode = "200 (WHAT IF)"
                Method     = "GET (WHAT IF)"
                Content    = [ordered]@{
                    id         = "/providers/Microsoft.Subscription/aliases/$subscriptionName"
                    name       = "$subscriptionName"
                    type       = "Microsoft.Subscription/aliases"
                    properties = [ordered]@{
                        subscriptionId    = "00000000-0000-0000-0000-000000000000"
                        provisioningState = "Succeeded"
                    }
                } | ConvertTo-Json -Depth $jsonDepth
            }
        }
        $aliasResponses += $aliasResponse
        Write-Verbose "Microsoft.Subscription/aliases/$($subscriptionName) [$($aliasResponse.StatusCode)]"
    }

    # For newly created Subscriptions, wait until all return StatusCode 200 and Provisioning State Succeeded
    $aliasResponses | Where-Object -Property StatusCode -EQ "201" | ForEach-Object {
        $aliasResponseContent = $_.Content | ConvertFrom-Json
        $retryCount = 0
        $SleepSeconds = 1
        do {
            $retryCount++
            $aliasResponse = Invoke-AzRestMethod -Method GET -Path "$($aliasResponseContent.id)?api-version=$($aliasesApiVersion)"
            $aliasResponseContent = $aliasResponse.Content | ConvertFrom-Json
            $subscriptionId = $aliasResponseContent.properties.subscriptionId
            $provisioningState = $aliasResponseContent.properties.provisioningState
            Write-Verbose "(Retry=$retryCount) $($aliasResponseContent.id) [$($aliasResponse.StatusCode)] [$($subscriptionId)] [$($provisioningState)]"
            if (($aliasResponse.StatusCode -eq "200") -and ($provisioningState -eq "Succeeded")) {
                $endLoop = $true
            }
            else {
                Start-Sleep -Seconds $SleepSeconds
                $SleepSeconds = 2 * $SleepSeconds
            }
            if ($retryCount -eq 10) {
                $endLoop = $true
            }
        } until ($endLoop)
    }

    # Add each subscription to the return object
    $subscriptions = @()
    $aliasResponses | ForEach-Object {
        if ($aliasResponse.StatusCode -eq "201") {
            $status = "NEW"
        }
        elseif ($aliasResponse.StatusCode -eq "200") {
            $status = "EXISTING"
        }
        elseif ($aliasResponse.StatusCode -eq "200 (WHAT IF)") {
            $status = "WHAT IF"
        }
        else {
            $status = "UNKNOWN" # Consider whether to throw an error here
        }
        $subscription = $_.Content | ConvertFrom-Json
        $subscriptions += $subscription
        Write-Information "[$status] Subscription Alias : $($subscription.name) [$($subscription.properties.subscriptionId)]" -InformationAction Continue
    }

    # Determine the parent management group if SetParentManagementGroup is specified
    if ($SetParentManagementGroup) {
        foreach ($subscription in $subscriptions) {
            $scope = $regex_subscriptionAlias.Matches($subscription.name)[0].Groups['scope'].Value
            Write-Information "Set parent management group : $($subscription.name) [$scope]" -InformationAction Continue
            $subscription | Add-Member -Type NoteProperty -Name parentManagementGroup -Value $scope
        }
    }

    # Determine the assigned address prefix if SetAddressPrefix is specified
    if ($SetAddressPrefix) {
        $secondOctetFallback = 100
        $secondOctetLog = @()
        foreach ($subscription in $subscriptions) {
            $secondOctetValue = $regex_subscriptionAlias.Matches($subscription.name)[0].Groups['secondOctet'].Value
            $secondOctet = [string]::IsNullOrEmpty($secondOctetValue) ? $secondOctetFallback : $secondOctetValue
            if ($secondOctet -in $secondOctetLog) {
                throw "Overlapping address space (at secondOctet) detected."
            }
            if ($secondOctet -in $secondOctetFallback) {
                $secondOctetFallback += 10
            }
            $addressPrefix = "10.$secondOctet.0.0/24"
            Write-Information "Set address prefix : $($subscription.name) [$addressPrefix]" -InformationAction Continue
            $subscription | Add-Member -Type NoteProperty -Name addressPrefix -Value $addressPrefix
        }
    }

    return $subscriptions

}

function Invoke-RemoveRsgByPattern {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()][String[]]$SubscriptionId,
        [Parameter()][String]$Like
    )

    $originalCtx = Get-AzContext

    $WhatIfPrefix = ""
    if ($WhatIfPreference) {
        $WhatIfPrefix = "What if: "
    }

    $jobs = @()
    foreach ($subId in $SubscriptionId) {
        Set-AzContext -SubscriptionId $subId -WhatIf:$false | Out-Null

        $resourcesGroups = Get-AzResourceGroup |  Where-Object -Property "ResourceGroupName" -Like $Like

        Write-Information "$($WhatIfPrefix)Deleting [$($resourcesGroups.Length)] Resource Groups for Subscription [$($subId)] matching pattern [$($Like)]" -InformationAction Continue

        if ($resourcesGroups.Length -gt 0) {
            if ($PSCmdlet.ShouldProcess($($resourcesGroups.ResourceGroupName | ConvertTo-Json -Compress), "Remove-AzResourceGroup")) {
                $jobs += $resourcesGroups | Remove-AzResourceGroup -AsJob -Force
            }
        }

    }

    Set-AzContext $originalCtx -WhatIf:$false | Out-Null

    return $jobs

}

function Invoke-RemoveDeploymentByPattern {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()][String[]]$SubscriptionId,
        [Parameter()][String[]]$ManagementGroupId,
        [Parameter()][String]$Like,
        [Parameter()][Switch]$IncludeTenantScope
    )

    $originalCtx = Get-AzContext

    $WhatIfPrefix = ""
    if ($WhatIfPreference) {
        $WhatIfPrefix = "What if: "
    }

    $jobs = @()

    foreach ($subId in $SubscriptionId) {
        Set-AzContext -SubscriptionId $subId -WhatIf:$false | Out-Null

        $deployments = Get-AzSubscriptionDeployment |  Where-Object -Property "DeploymentName" -Like $Like

        Write-Information "$($WhatIfPrefix)Deleting [$($deployments.Length)] Deployments for Subscription [$($subId)] matching pattern [$($Like)]" -InformationAction Continue

        if ($deployments.Length -gt 0) {
            if ($PSCmdlet.ShouldProcess($($deployments.DeploymentName | ConvertTo-Json -Compress), "Remove-AzSubscriptionDeployment")) {
                $jobs += $deployments | Remove-AzSubscriptionDeployment -AsJob
            }
        }

    }

    foreach ($mgId in $ManagementGroupId) {
        $deployments = Get-AzManagementGroupDeployment -ManagementGroupId $mgId |  Where-Object -Property "DeploymentName" -Like $Like

        Write-Information "$($WhatIfPrefix)Deleting [$($deployments.Length)] Deployments for Management Group [$($mgId)] matching pattern [$($Like)]" -InformationAction Continue

        if ($deployments.Length -gt 0) {
            if ($PSCmdlet.ShouldProcess($($deployments.DeploymentName | ConvertTo-Json -Compress), "Remove-AzManagementGroupDeployment")) {
                $jobs += $deployments | Remove-AzManagementGroupDeployment -AsJob
            }
        }

    }

    if ($IncludeTenantScope) {
        $deployments = Get-AzTenantDeployment |  Where-Object -Property "DeploymentName" -Like $Like

        Write-Information "$($WhatIfPrefix)Deleting [$($deployments.Length)] Deployments for Tenant [$($originalCtx.Tenant.Id)] matching pattern [$($Like)]" -InformationAction Continue

        if ($deployments.Length -gt 0) {
            if ($PSCmdlet.ShouldProcess($($deployments.DeploymentName | ConvertTo-Json -Compress), "Remove-AzTenantDeployment")) {
                $jobs += $deployments | Remove-AzTenantDeployment -AsJob
            }
        }

    }

    Set-AzContext $originalCtx -WhatIf:$false | Out-Null

    return $jobs

}

function Invoke-RemoveOrphanedRoleAssignment {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()][String[]]$SubscriptionId
    )

    $originalCtx = Get-AzContext

    $WhatIfPrefix = ""
    if ($WhatIfPreference) {
        $WhatIfPrefix = "What if: "
    }

    # Get the latest stable API version
    $roleAssignmentsApiVersion = [ProviderApiVersions]::GetLatestStableByType("Microsoft.Authorization/roleAssignments")
    Write-Information "Using Role Assignments API Version : $($roleAssignmentsApiVersion)" -InformationAction Continue

    foreach ($subId in $SubscriptionId) {

        # Use Rest API to ensure correct permissions are assigned when looking up
        # whether identity exists, otherwise Get-AzRoleAssignment will always
        # return `objectType : "unknown"` for all assignments with no errors.

        # Get Role Assignments
        $getRequestPath = "/subscriptions/$($subId)/providers/Microsoft.Authorization/roleAssignments?api-version=$($roleAssignmentsApiVersion)"
        $getResponse = Invoke-AzRestMethod -Method "GET" -Path $getRequestPath
        $roleAssignments = ($getResponse.Content | ConvertFrom-Json).value

        # Check for valid response
        if ($getResponse.StatusCode -ne "200") {
            throw $getResponse.Content
        }
        try {
            # If invalid response, $roleAssignments will be null and throw an error
            $roleAssignments.GetType() | Out-Null
        }
        catch {
            throw $getResponse.Content
        }

        # Get a list of assigned principalId values and lookup against Microsoft Entra ID
        $principalsRequestUri = "https://graph.microsoft.com/v1.0/directoryObjects/microsoft.graph.getByIds"
        $principalsRequestBody = @{
            ids = $roleAssignments.properties.principalId
        } | ConvertTo-Json -Depth $jsonDepth
        $principalsResponse = Invoke-AzRestMethod -Method "POST" -Uri $principalsRequestUri -Payload $principalsRequestBody -WhatIf:$false
        $principalIds = ($principalsResponse.Content | ConvertFrom-Json).value.id

        # Find all Role Assignments where the principalId is not found in Microsoft Entra ID
        $orphanedRoleAssignments = $roleAssignments | Where-Object {
            ($_.properties.scope -eq "/subscriptions/$($subId)") -and
            ($_.properties.principalId -notin $principalIds)
        }

        # Delete orphaned Role Assignments
        Write-Information "$($WhatIfPrefix)Deleting [$($orphanedRoleAssignments.Length)] orphaned Role Assignments for Subscription [$($subId)]" -InformationAction Continue
        $orphanedRoleAssignments | ForEach-Object {
            if ($PSCmdlet.ShouldProcess("$($_.id)", "Remove-AzRoleAssignment")) {
                $deleteRequestPath = "$($_.id)?api-version=$($roleAssignmentsApiVersion)"
                $deleteResponse = Invoke-AzRestMethod -Method "DELETE" -Path $deleteRequestPath
                # Check for valid response
                if ($deleteResponse.StatusCode -ne "200") {
                    throw $deleteResponse.Content
                }
            }
        }

    }

    Set-AzContext $originalCtx -WhatIf:$false | Out-Null

}

function Invoke-RemoveMgHierarchy {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()][String[]]$ManagementGroupId
    )

    $InvokeRemoveMgHierarchy = ${function:Invoke-RemoveMgHierarchy}.ToString()

    $ctx = Get-AzContext

    $WhatIfPrefix = ""
    if ($WhatIfPreference) {
        $WhatIfPrefix = "What if: "
    }

    # Get list of existing Management Groups
    $managementGroupIds = (Get-AzManagementGroup).Name

    Write-Information ("$($WhatIfPrefix)Removing Management Group Hierarchy in batch: {0}" -f $($ManagementGroupId | ConvertTo-Json -Compress)) -InformationAction Continue

    # Log warning for non-existing Management Group
    $ManagementGroupId | Where-Object { $_ -notin $managementGroupIds } | ForEach-Object {
        Write-Warning "'/providers/Microsoft.Management/managementGroups/$_' not found"
    }

    # Process existing Management Groups
    $ManagementGroupId | Where-Object { $_ -in $managementGroupIds } | ForEach-Object -Parallel {

        # Set WhatIfPreference from parent session
        $WhatIfPreference = $using:WhatIfPreference

        # Parse functions from parent session
        ${function:Invoke-RemoveMgHierarchy} = $using:InvokeRemoveMgHierarchy

        # Set Azure context from parent session
        Set-AzContext -Context $using:ctx | Out-Null

        # Get expanded properties of current Management Group
        $managementGroup = Get-AzManagementGroup -GroupId $_ -Expand -WarningAction SilentlyContinue

        # Process child Subscriptions under the current Management Group scope
        $childSubs = ($managementGroup.Children | Where-Object { $_.Type -eq "/subscriptions" }).Name
        foreach ($childSub in $childSubs) {
            Remove-AzManagementGroupSubscription -SubscriptionId $childSub -GroupName $managementGroup.Name -WhatIf:$WhatIfPreference -WarningAction SilentlyContinue
            Write-Output "/subscriptions/$childSub"
        }

        # Process child Management Groups under the current Management Group scope
        $childMgs = ($managementGroup.Children | Where-Object { $_.Type -match "^(\/providers\/)?(Microsoft\.Management\/managementGroups)$" }).Name
        if ($childMgs.Length -gt 0) {
            Invoke-RemoveMgHierarchy -ManagementGroupId $childMgs
        }

        Remove-AzManagementGroup -GroupId $_ -WhatIf:$WhatIfPreference -WarningAction SilentlyContinue | Out-Null

        Write-Output "/providers/Microsoft.Management/managementGroups/$_"

    }

}
