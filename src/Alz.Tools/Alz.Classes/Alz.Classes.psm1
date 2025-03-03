#!/usr/bin/pwsh

using module "../Alz.Enums/"

#############################
# ProviderApiVersions Class #
#############################

# [ProviderApiVersions] class is used to create cache of latest API versions for all Azure Providers.
# This can be used to retrieve the latest or stable API version in string format.
# Can also output the API version as a param string for use within a Rest API request.
# To minimise the number of Rest API requests needed, this class creates a cache and populates.
# it with all results from the request. The cache is then used to return the requested result.
# Need to store and lookup the key in lowercase to avoid case sensitivity issues while providing
# better performance as allows using ContainsKey method to search for key in cache.
# Should be safe to ignore case as Providers are not case sensitive.
class ProviderApiVersions {

    # Public class properties
    [String]$Provider
    [String]$ResourceType
    [String]$Type
    [Array]$ApiVersions

    # Static properties
    hidden static [String]$ProvidersApiVersion = "2020-06-01"

    # Default empty constructor
    ProviderApiVersions() {
    }

    # Default constructor using PSCustomObject to populate object
    ProviderApiVersions([PSCustomObject]$PSCustomObject) {
        $this.Provider = $PSCustomObject.Provider
        $this.ResourceType = $PSCustomObject.ResourceType
        $this.Type = $PSCustomObject.Type
        $this.ApiVersions = $PSCustomObject.ApiVersions
    }

    # Static method to get Api Version using Type
    static [Array] GetByType([String]$Type) {
        if ([ProviderApiVersions]::Cache.Count -lt 1) {
            [ProviderApiVersions]::UpdateCache()
        }
        $private:ProviderApiVersionsFromCache = [ProviderApiVersions]::SearchCache($Type)
        return $private:ProviderApiVersionsFromCache.ApiVersions
    }

    # Static method to get latest Api Version using Type
    static [String] GetLatestByType([String]$Type) {
        $private:GetLatestByType = [ProviderApiVersions]::GetByType($Type) |
        Sort-Object -Descending |
        Select-Object -First 1
        return $private:GetLatestByType
    }

    # Static method to get latest stable Api Version using Type
    # If no stable release, will return latest
    static [String] GetLatestStableByType([String]$Type) {
        $private:GetByType = [ProviderApiVersions]::GetByType($Type)
        $private:GetLatestStableByType = $private:GetByType |
        Where-Object { $_ -Match "^[0-9-]{10}$" } |
        Sort-Object -Descending |
        Select-Object -First 1
        if ($private:GetLatestStableByType) {
            return $private:GetLatestStableByType.ToString()
        }
        else {
            return [ProviderApiVersions]::GetLatestByType($Type).ToString()
        }
    }

    static [String[]] ListTypes() {
        if ([ProviderApiVersions]::Cache.Count -lt 1) {
            [ProviderApiVersions]::UpdateCache()
        }
        $private:ShowCacheTypes = [ProviderApiVersions]::ShowCache().Type | Sort-Object
        return $private:ShowCacheTypes
    }

    # Static property to store cache of ProviderApiVersions using a threadsafe
    # dictionary variable to allow caching across parallel jobs
    # https://docs.microsoft.com/powershell/module/microsoft.powershell.core/foreach-object#example-14--using-thread-safe-variable-references
    static [System.Collections.Concurrent.ConcurrentDictionary[String, ProviderApiVersions]]$Cache

    # Static method to show all entries in Cache
    static [ProviderApiVersions[]] ShowCache() {
        return ([ProviderApiVersions]::Cache).Values
    }

    # Static method to show all entries in Cache matching the specified type using the specified release type
    static [ProviderApiVersions[]] SearchCache([String]$Type) {
        return [ProviderApiVersions]::Cache[$Type.ToString().ToLower()]
    }

    # Static method to return [Boolean] for Resource Type in Cache query using the specified release type
    static [Boolean] InCache([String]$Type) {
        if ([ProviderApiVersions]::Cache) {
            $private:CacheKeyLowercase = $Type.ToString().ToLower()
            $private:InCache = ([ProviderApiVersions]::Cache).ContainsKey($private:CacheKeyLowercase)
            if ($private:InCache) {
                Write-Verbose "[ProviderApiVersions] Resource Type found in Cache [$Type]"
            }
            else {
                Write-Verbose "[ProviderApiVersions] Resource Type not found in Cache [$Type]"
            }
            return $private:InCache
        }
        else {
            # The following prevents needing to initialize the cache
            # manually if not exist on first attempt to use
            [ProviderApiVersions]::InitializeCache()
            return $false
        }
    }

    # Static method to update Cache using current Subscription from context
    static [Void] UpdateCache() {
        $private:SubscriptionId = (Get-AzContext).Subscription.Id
        [ProviderApiVersions]::UpdateCache($private:SubscriptionId)
    }

    # Static method to update Cache using specified SubscriptionId
    static [Void] UpdateCache([String]$SubscriptionId) {
        $private:Method = "GET"
        $private:Path = "/subscriptions/$subscriptionId/providers?api-version=$([ProviderApiVersions]::ProvidersApiVersion)"
        $private:PSHttpResponse = Invoke-AzRestMethod -Method $private:Method -Path $private:Path
        $private:PSHttpResponseContent = $private:PSHttpResponse.Content
        $private:Providers = ($private:PSHttpResponseContent | ConvertFrom-Json).value
        if ($private:Providers) {
            [ProviderApiVersions]::InitializeCache()
        }
        foreach ($private:Provider in $private:Providers) {
            Write-Verbose "[ProviderApiVersions] Processing Provider Namespace [$($private:Provider.namespace)]"
            foreach ($private:Type in $private:Provider.resourceTypes) {
                # Check for latest ApiVersions and add to cache
                [ProviderApiVersions]::AddToCache(
                    $private:Provider.namespace.ToString(),
                    $private:Type.resourceType.ToString(),
                    $private:Type.ApiVersions
                )
            }
        }
    }

    # Static method to add provider instance to Cache
    hidden static [Void] AddToCache([String]$Provider, [String]$ResourceType, [Array]$ApiVersions) {
        Write-Debug "[ProviderApiVersions] Adding [$($Provider)/$($ResourceType)] to Cache"
        $private:AzStateProviderObject = [PsCustomObject]@{
            Provider     = "$Provider"
            ResourceType = "$ResourceType"
            Type         = "$Provider/$ResourceType"
            ApiVersions  = $ApiVersions
        }
        $private:CacheKey = "$Provider/$ResourceType"
        $private:CacheKeyLowercase = $private:CacheKey.ToString().ToLower()
        $private:CacheValue = [ProviderApiVersions]::new($private:AzStateProviderObject)
        $private:TryAdd = ([ProviderApiVersions]::Cache).TryAdd($private:CacheKeyLowercase, $private:CacheValue)
        if ($private:TryAdd) {
            Write-Verbose "[ProviderApiVersions] Added Resource Type to Cache [$private:CacheKey]"
        }
    }

    # Static method to initialize Cache
    # Will also reset cache if exists
    static [Void] InitializeCache() {
        Write-Verbose "[ProviderApiVersions] Initializing Cache (Empty)"
        [ProviderApiVersions]::Cache = [System.Collections.Concurrent.ConcurrentDictionary[String, ProviderApiVersions]]::new()
    }

    # Static method to clear all entries from Cache
    static [Void] ClearCache() {
        [ProviderApiVersions]::InitializeCache()
    }

    # Static method to save all entries from Cache to filesystem
    static [Void] SaveCacheToDirectory() {
        [ProviderApiVersions]::SaveCacheToDirectory("./")
    }

    # Static method to save all entries from Cache to filesystem
    static [Void] SaveCacheToDirectory([String]$Directory) {
        if ([ProviderApiVersions]::Cache.Count -lt 1) {
            [ProviderApiVersions]::UpdateCache()
        }
        $private:saveCachePath = "$Directory/ProviderApiVersions"
        [ProviderApiVersions]::Cache |
        ConvertTo-Json -Depth 10 -Compress |
        Out-File -FilePath "$($private:saveCachePath).json" `
            -Force
        try {
            Compress-Archive -Path "$($private:saveCachePath).json" `
                -DestinationPath "$($private:saveCachePath).zip" `
                -Force
        }
        finally {
            Remove-Item -Path "$($private:saveCachePath).json" `
                -Force
        }
    }

    # Static method to load all entries from filesystem to Cache
    static [Void] LoadCacheFromDirectory() {
        [ProviderApiVersions]::LoadCacheFromDirectory("./")
    }

    # Static method to load all entries from filesystem to Cache
    static [Void] LoadCacheFromDirectory([String]$Directory) {
        [ProviderApiVersions]::ClearCache()
        $private:loadCachePath = "$Directory/ProviderApiVersions"
        Expand-Archive -Path "$($private:loadCachePath).zip" `
            -DestinationPath "$Directory" `
            -Force
        try {
            $private:loadCacheObject = Get-Content `
                -Path "$($private:loadCachePath).json" `
                -Force |
            ConvertFrom-Json
            foreach ($key in $private:loadCacheObject.psobject.Properties.Name) {
                $private:value = $private:loadCacheObject."$key"
                ([ProviderApiVersions]::Cache).TryAdd($key, $private:value)
            }
        }
        catch {
            Write-Error $_.Exception.Message
        }
        finally {
            Remove-Item -Path "$($private:loadCachePath).json" `
                -Force
        }
    }

}

###############
# ALZ Classes #
###############

# The ALZ classes are used to create resource objects with consistent
# formatting for all Azure resources handled by the ALZ Tools module.

class ALZBase : System.Collections.Specialized.OrderedDictionary {

    ALZBase(): base() {}

    [String] ToString() {
        if ($this.GetType() -notin "String", "Boolean", "Int") {
            return $this | ConvertTo-Json -Depth 1 -WarningAction SilentlyContinue | ConvertFrom-Json
        }
        else {
            return $this
        }
    }

}

class PolicyAssignmentProperties : ALZBase {
    [String]$displayName = ""
    [Object]$policyDefinitionId = ""
    [String]$scope = ""
    [String[]]$notScopes = @()
    [Object]$parameters = @{}
    [String]$description = ""
    [Object]$metadata = @{}
    [String]$enforcementMode = "Default"

    PolicyAssignmentProperties(): base() {}

    PolicyAssignmentProperties([Object]$that): base() {
        $this.displayName = $that.displayName
        $this.policyDefinitionId = $that.policyDefinitionId
        $this.scope = $that.scope
        $this.notScopes = $that.notScopes ?? $this.notScopes
        $this.parameters = $that.parameters ?? $this.parameters
        $this.description = $that.description ?? $that.displayName
        $this.metadata = $that.metadata ?? $this.metadata
        $this.enforcementMode = ([PolicyAssignmentPropertiesEnforcementMode]($that.enforcementMode ?? $this.enforcementMode)).ToString()
    }

}

class PolicyAssignmentIdentity : ALZBase {
    [String]$type = "None"

    PolicyAssignmentIdentity(): base() {}

    PolicyAssignmentIdentity([Object]$that): base() {
        $this.type = ([PolicyAssignmentIdentityType]($that.type ?? $this.type)).ToString()
    }

}

class PolicyDefinitionProperties : ALZBase {
    [String]$policyType = "NotSpecified"
    [String]$mode = ""
    [String]$displayName = ""
    [String]$description = ""
    [Object]$metadata = @{}
    [Object]$parameters = @{}
    [Object]$policyRule = @{}

    PolicyDefinitionProperties(): base() {}

    PolicyDefinitionProperties([Object]$that): base() {
        $this.policyType = ([PolicySetDefinitionPropertiesPolicyType]($that.policyType ?? $this.policyType)).ToString()
        $this.mode = ([PolicyDefinitionPropertiesMode]($that.mode)).ToString()
        $this.displayName = $that.displayName
        $this.description = $that.description ?? $that.displayName
        $this.metadata = $that.metadata ?? $this.metadata
        $this.parameters = $that.parameters ?? $this.parameters
        $this.policyRule = $that.policyRule
    }

}

class PolicySetDefinitionPropertiesPolicyDefinitions : ALZBase {
    [String]$policyDefinitionReferenceId = ""
    [String]$policyDefinitionId = ""
    [Object]$parameters = @{}
    [Array]$groupNames = @()

    PolicySetDefinitionPropertiesPolicyDefinitions(): base() {}

    PolicySetDefinitionPropertiesPolicyDefinitions([Object]$that): base() {
        $this.policyDefinitionReferenceId = $that.policyDefinitionReferenceId
        $this.policyDefinitionId = $that.policyDefinitionId
        $this.parameters = $that.parameters ?? $this.parameters
        $this.groupNames = $that.groupNames ?? $this.groupNames
    }

}

class PolicySetDefinitionPropertiesPolicyDefinitionGroup : ALZBase {
    [String]$name = ""
    [String]$displayName = ""
    [String]$category = ""
    [String]$description = ""
    [String]$additionalMetadataId = ""

    PolicySetDefinitionPropertiesPolicyDefinitionGroup(): base() {}

    PolicySetDefinitionPropertiesPolicyDefinitionGroup([Object]$that): base() {
        $this.name = $that.name
        $this.displayName = $that.displayName
        $this.category = $that.category
        $this.description = $that.description
        $this.additionalMetadataId = $that.additionalMetadataId
    }

}

class PolicySetDefinitionProperties : ALZBase {
    [String]$policyType = "NotSpecified"
    [String]$displayName = ""
    [String]$description = ""
    [Object]$metadata = @{}
    [Object]$parameters = @{}
    [Array]$policyDefinitions = @()
    [Array]$policyDefinitionGroups = $null

    PolicySetDefinitionProperties(): base() {}

    PolicySetDefinitionProperties([Object]$that): base() {
        $this.policyType = ([PolicySetDefinitionPropertiesPolicyType]($that.policyType ?? $this.policyType)).ToString()
        $this.displayName = $that.displayName ?? ""
        $this.description = $that.description ?? $that.displayName
        $this.metadata = $that.metadata ?? $this.metadata
        $this.parameters = $that.parameters ?? $this.parameters
        $this.policyDefinitions = foreach ($policyDefinition in $that.policyDefinitions) {
            [PolicySetDefinitionPropertiesPolicyDefinitions]::new($policyDefinition)
        }
        $this.policyDefinitionGroups = foreach ($policyDefinitionGroup in $that.policyDefinitionGroups) {
            [PolicySetDefinitionPropertiesPolicyDefinitionGroup]::new($that.policyDefinitionGroups)
        }
    }

}

class RoleAssignmentProperties : ALZBase {
    RoleAssignmentProperties(): base() {}
}

class RoleDefinitionPropertiesPermissions {
    [String[]]$actions = @()
    [String[]]$notActions = @()
    [String[]]$dataActions = @()
    [String[]]$notDataActions = @()

    RoleDefinitionPropertiesPermissions(): base() {}

    RoleDefinitionPropertiesPermissions([Object]$that): base() {
        $this.actions = $that.actions ?? $this.actions
        $this.notActions = $that.notActions ?? $that.notActions
        $this.dataActions = $that.dataActions ?? $this.dataActions
        $this.notDataActions = $that.notDataActions ?? $this.notDataActions
    }

}

class RoleDefinitionProperties : ALZBase {
    [String]$roleName = ""
    [String]$description = ""
    [String]$type = "customRole"
    [Array]$permissions = @()
    [Array]$assignableScopes = @()

    RoleDefinitionProperties(): base() {}

    RoleDefinitionProperties([Object]$that): base() {
        $this.roleName = $that.roleName
        $this.description = $that.description ?? $that.roleName
        $this.type = $that.type ?? $this.type
        $this.permissions = @(
            [PolicyAssignmentIdentity]::new($that.permissions[0])
        )
        $this.assignableScopes = $that.assignableScopes ?? $this.assignableScopes
    }

}

class ArmTemplateResource : ALZBase {

    # Public class properties
    # Need to declare base object properties with default values to set order
    [String]$name = ""
    [String]$type = ""
    [String]$apiVersion = ""
    [Object]$scope = $null # Needs to be declared as object to avoid null returning empty string in JSON output
    [Object]$properties = @{}

    # Hidden static class properties
    hidden static [GetFileNameCaseModifier]$GetFileNameCaseModifier = "ToLower" # Default to make lowercase
    hidden static [Regex]$regexReplaceFileNameCharacters = "\W" # Default to replace all non word characters
    hidden static [String]$GetFileNameSubstituteCharacter = "_"
    hidden static [Regex]$regexExtractProviderId = "\/providers\/(?!.*\/providers\/)[\/\w-.]+"

    ArmTemplateResource(): base() {}

    ArmTemplateResource([PSCustomObject]$that): base() {
        $this.name = $that.name
        $this.type = $that.ResourceType ?? $that.type
        $this.apiVersion = $that.apiVersion
        $this.scope = if ($that.scope.Length -gt 0) { $that.scope } else { $null }
        $this.properties = $that.properties
    }

    # Initialize [ArmTemplateResource] object
    [Void] SetApiVersion([String]$ResourceType) {
        $this.apiVersion = [ProviderApiVersions]::GetLatestStableByType($ResourceType)
    }

    # String modifier for template languages
    static [String] ConvertToTemplateVariable([String]$Variable, [ExportFormat]$ExportFormat) {
        $TemplateVariable = "$Variable"
        Switch ($ExportFormat) {
            "Jinja2" { $TemplateVariable = "{{ $Variable }}" }
            "Terraform" { $TemplateVariable = "`${$Variable}" }
            Default { $TemplateVariable = "$Variable" }
        }
        return $TemplateVariable
    }

    # Update resource values as per requirements for export format
    [Object] Format([ExportFormat]$ExportFormat) {
        if ($this.type -eq "Microsoft.Authorization/policyAssignments") {
            $this.properties.scope = [ArmTemplateResource]::ConvertToTemplateVariable("current_scope_resource_id", $ExportFormat)
            $this.properties.policyDefinitionId = [ArmTemplateResource]::ConvertToTemplateVariable("root_scope_resource_id", $ExportFormat)
            $this.location = [ArmTemplateResource]::ConvertToTemplateVariable("default_location", $ExportFormat)
        }
        if ($this.type -eq "Microsoft.Authorization/policyDefinitions") {
            $this.properties.policyType = "Custom"
        }
        if ($this.type -eq "Microsoft.Authorization/policySetDefinitions") {
            $this.properties.policyType = "Custom"
            foreach ($policyDefinition in $this.properties.policyDefinitions) {
                $regexMatches = [ArmTemplateResource]::regexExtractProviderId.Matches($policyDefinition.policyDefinitionId)
                $policyDefinitionId = switch ($ExportFormat) {
                    "ArmResource" { "/providers/Microsoft.Management/managementGroups/contoso$($regexMatches.Value)" }
                    "ArmVariable" { "[concat(variables('scope'), '$($regexMatches.Value)')]" }
                    "Bicep" { "`${varTargetManagementGroupResourceId}$($regexMatches.Value)" }
                    "Raw" { "$($policyDefinition.policyDefinitionId)" }
                    "Jinja2" { "$([ArmTemplateResource]::ConvertToTemplateVariable("root_scope_resource_id", $ExportFormat))$($regexMatches.Value)" }
                    "Terraform" { "$([ArmTemplateResource]::ConvertToTemplateVariable("root_scope_resource_id", $ExportFormat))$($regexMatches.Value)" }
                    Default { "$($policyDefinition.policyDefinitionId)" }
                }
                if ($regexMatches.Index -gt 0) {
                    $policyDefinition.policyDefinitionId = "$policyDefinitionId"
                }
                else {
                    $policyDefinition.policyDefinitionId = $regexMatches.Value
                }
            }
        }
        return $this
    }

    [String] GetFileName() {
        $fileName = $this.GetFileName("", ".json", "Raw")
        return $fileName
    }

    [String] GetFileName([String]$Prefix, [String]$Suffix, [ExportFormat]$ExportFormat) {
        $fileName = "$($this.name)"
        if ($ExportFormat -eq "Terraform") {
            # Perform character substitution
            $fileName = [ArmTemplateResource]::regexReplaceFileNameCharacters.Replace($fileName, [ArmTemplateResource]::GetFileNameSubstituteCharacter)
            # Modify case
            $fileName = $fileName.$([ArmTemplateResource]::GetFileNameCaseModifier)()
        }
        $fileName = $Prefix + $fileName + $Suffix
        return $fileName
    }

}

class PolicyAssignment : ArmTemplateResource {

    # Need to re-declare base object properties with default values to maintain order
    [String]$name = ""
    [String]$type = ""
    [String]$apiVersion = ""
    [String]$scope = ""
    [Object]$properties = @{}
    [String]$location = ""
    [Object]$identity = @{}

    PolicyAssignment(): base() {}

    PolicyAssignment([PSCustomObject]$that): base($that) {
        $this.type = "Microsoft.Authorization/policyAssignments"
        $this.SetApiVersion($this.type)
        $this.location = $that.location
        $this.identity = [PolicyAssignmentIdentity]::new($that.identity)
        $this.properties = [PolicyAssignmentProperties]::new($this.properties)
    }

}

class PolicyDefinition : ArmTemplateResource {

    PolicyDefinition(): base() {}

    PolicyDefinition([PSCustomObject]$that): base($that) {
        $this.type = "Microsoft.Authorization/policyDefinitions"
        $this.SetApiVersion($this.type)
        $this.properties = [PolicyDefinitionProperties]::new($this.properties)
    }

}

class PolicySetDefinition : ArmTemplateResource {

    PolicySetDefinition(): base() {}

    PolicySetDefinition([PSCustomObject]$that): base($that) {
        $this.type = "Microsoft.Authorization/policySetDefinitions"
        $this.SetApiVersion($this.type)
        $this.properties = [PolicySetDefinitionProperties]::new($this.properties)
    }

}

class RoleAssignment : ArmTemplateResource {

    RoleAssignment(): base() {}

    RoleAssignment([PSCustomObject]$that): base($that) {
        $this.type = "Microsoft.Authorization/roleAssignments"
        $this.SetApiVersion($this.type)
        $this.properties = [RoleAssignmentProperties]::new($this.properties)
    }
}

class RoleDefinition : ArmTemplateResource {

    RoleDefinition(): base() {}

    RoleDefinition([PSCustomObject]$that): base($that) {
        $this.type = "Microsoft.Authorization/roleDefinitions"
        $this.SetApiVersion($this.type)
        $this.properties = [RoleDefinitionProperties]::new($this.properties)
    }

}
