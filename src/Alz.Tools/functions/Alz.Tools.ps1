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
                -ResourceObject ($ExportFormat -eq "Terraform" ? (Remove-Escaping -InputObject $policyDefinition) : $policyDefinition) `
                -ResourceType ("Microsoft.Authorization/policyDefinitions")
        }
        foreach ($policySetDefinition in $objectFromJson.variables.initiatives.policySetDefinitions) {
            ProcessObjectByResourceType `
                -ResourceObject ($ExportFormat -eq "Terraform" ? (Remove-Escaping -InputObject $policySetDefinition) : $policySetDefinition) `
                -ResourceType ("Microsoft.Authorization/policySetDefinitions")
        }
        foreach (
            $policySetDefinition in $objectFromJson.resources |
            Where-Object { $_.type -eq "Microsoft.Authorization/policyDefinitions" } |
            Where-Object { $_.name -ne "[variables('policies').policyDefinitions[copyIndex()].name]" }
        ) {
            ProcessObjectByResourceType `
                -ResourceObject ($ExportFormat -eq "Terraform" ? (Remove-Escaping -InputObject $policySetDefinition) : $policySetDefinition) `
                -ResourceType ("Microsoft.Authorization/policyDefinitions")
        }
        foreach (
            $policySetDefinition in $objectFromJson.resources |
            Where-Object { $_.type -eq "Microsoft.Authorization/policySetDefinitions" } |
            Where-Object { $_.name -ne "[variables('initiatives').policySetDefinitions[copyIndex()].name]" }
        ) {
            ProcessObjectByResourceType `
                -ResourceObject ($ExportFormat -eq "Terraform" ? (Remove-Escaping -InputObject $policySetDefinition) : $policySetDefinition) `
                -ResourceType ("Microsoft.Authorization/policySetDefinitions")
        }
    }
    # The following elseif block handles resource files stored in ARM template format
    elseif ($objectFromJson.type -in $allowedResourceTypes) {
        ProcessObjectByResourceType `
            -ResourceObject ($ExportFormat -eq "Terraform" ? (Remove-Escaping -InputObject $objectFromJson) : $objectFromJson) `
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

        [String[]]$outputText = $InputText |
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

function Register-AzureSubscription {
    [CmdletBinding()]
    param (
        [Parameter()][String[]]$Alias,
        [Parameter()][String]$BillingScope,
        [Parameter()][String]$Workload = "Production",
        [Parameter()][Switch]$SetParentManagementGroup,
        [Parameter()][Switch]$SetAddressPrefix
    )

    $aliasesApiVersion = [ProviderApiVersions]::GetLatestStableByType("Microsoft.Subscription/aliases")
    Write-Information "Set Subscription Alias API Version : $($aliasesApiVersion)" -InformationAction Continue
    $subscriptions = @()
    foreach ($subscriptionName in $Alias) {
        $requestPath = "/providers/Microsoft.Subscription/aliases/$($subscriptionName)?api-version=$($aliasesApiVersion)"
        $requestMethod = "PUT"
        $requestBody = @{
            properties = @{
                displayName          = $subscriptionName
                billingScope         = $BillingScope
                workload             = $Workload
                additionalProperties = @{}
            }
        } | ConvertTo-Json -Depth $jsonDepth
        $aliasResponse = Invoke-AzRestMethod -Method $requestMethod -Path $requestPath -Payload $requestBody
        $subscription = $aliasResponse.Content | ConvertFrom-Json
        $subscriptions += $subscription
        Write-Information "Created new Subscription Alias : $($subscriptionName) [$($subscription.properties.subscriptionId)]" -InformationAction Continue
    }

    if ($SetParentManagementGroup) {
        foreach ($subscription in $subscriptions) {
            $scope = $regex_subscriptionAlias.Matches($subscription.name)[0].Groups['scope'].Value
            Write-Information "Set parent management group : $($subscription.name) [$scope]" -InformationAction Continue
            $subscription | Add-Member -Type NoteProperty -Name parentManagementGroup -Value $scope
        }
    }

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

    $jobs = @()
    foreach ($subId in $SubscriptionId) {
        Set-AzContext -SubscriptionId $subId -WhatIf:$false | Out-Null

        $resourcesGroups = Get-AzResourceGroup |  Where-Object -Property "ResourceGroupName" -Like $Like

        if (($PSCmdlet.ShouldProcess($($resourcesGroups.ResourceGroupName | ConvertTo-Json -Compress))) -and ($resourcesGroups.Length -gt 0)) {
            $jobs += $resourcesGroups | Remove-AzResourceGroup -AsJob -Force
        }

        Write-Information " - Deleting [$($resourcesGroups.Length)] Resource Groups for Subscription [$($subId)] matching pattern [$($Like)]" -InformationAction Continue
    }

    Set-AzContext $originalCtx -WhatIf:$false | Out-Null

    return $jobs

}

function Invoke-RemoveMgHierarchy {
    [CmdletBinding()]
    param (
        [Parameter()][String[]]$ManagementGroupId,
        [Parameter()][Int]$SleepForSeconds = 10
    )

    $InvokeRemoveMgHierarchy = ${function:Invoke-RemoveMgHierarchy}.ToString()
    $ctx = Get-AzContext
    Write-Information ("Removing Management Group Hierarchy in batch: {0}" -f $($ManagementGroupId | ConvertTo-Json -Compress)) -InformationAction Continue
    $ManagementGroupId | ForEach-Object -Parallel {
        # Parse functions to parallel PS session
        ${function:Invoke-RemoveMgHierarchy} = $using:InvokeRemoveMgHierarchy
        # Set Azure context in parallel PS session
        Set-AzContext -Context $using:ctx | Out-Null
        # Get expanded properties of current Management Group
        $managementGroup = Get-AzManagementGroup -GroupId $_ -Expand -WarningAction SilentlyContinue
        # Process child Subscriptions under the current Management Group scope
        $childSubs = ($managementGroup.Children | Where-Object { $_.Type -eq "/subscriptions" }).Name
        foreach ($childSub in $childSubs) {
            Remove-AzManagementGroupSubscription -SubscriptionId $childSub -GroupName $managementGroup.Name -WarningAction SilentlyContinue
        }
        # Process child Management Groups under the current Management Group scope
        $childMgs = ($managementGroup.Children | Where-Object { $_.Type -eq "Microsoft.Management/managementGroups" }).Name
        if ($childMgs.Length -gt 0) {
            Invoke-RemoveMgHierarchy -ManagementGroupId $childMgs
        }
        # Pause to allow time for the backend to replicate
        Start-Sleep -Seconds $using:SleepForSeconds
        Remove-AzManagementGroup -GroupId $_ -WarningAction SilentlyContinue | Out-Null
        Write-Information ("Successfully removed Management Group: {0}" -f $_) -InformationAction Continue
    }
}
