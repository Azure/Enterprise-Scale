# Static contract tests for the private DNS coverage added to Deploy-Private-DNS-Zones for Azure/Azure-Landing-Zones#461:
# Bot Service Token (built-in 6a4e6f44), Deploy-Private-DNS-Generic slots for services without a built-in policy,
# and Deploy-Private-DNS-Generic-MultiZone slots for services that need several private DNS zones.

BeforeDiscovery {
    $zoneWiring = @(
        @{ Key = 'azureBotServiceTokenPrivateDnsZoneId'; Zone = 'privatelink.token.botframework.com'; InDefaultNames = $true }
        @{ Key = 'azureSqlServerPrivateDnsZoneId'; Zone = 'privatelink.database.windows.net'; InDefaultNames = $true }
        @{ Key = 'azureApiManagementPrivateDnsZoneId'; Zone = 'privatelink.azure-api.net'; InDefaultNames = $true }
        @{ Key = 'azureMySQLPrivateDnsZoneId'; Zone = 'privatelink.mysql.database.azure.com'; InDefaultNames = $true }
        @{ Key = 'azurePostgreSQLPrivateDnsZoneId'; Zone = 'privatelink.postgres.database.azure.com'; InDefaultNames = $true }
        @{ Key = 'azureCosmosPostgreSQLPrivateDnsZoneId'; Zone = 'privatelink.postgres.cosmos.azure.com'; InDefaultNames = $true }
        @{ Key = 'azureDigitalTwinsPrivateDnsZoneId'; Zone = 'privatelink.digitaltwins.azure.net'; InDefaultNames = $true }
        @{ Key = 'azureManagedHSMPrivateDnsZoneId'; Zone = 'privatelink.managedhsm.azure.net'; InDefaultNames = $true }
        @{ Key = 'azurePurviewAccountPrivateDnsZoneId'; Zone = 'privatelink.purview.azure.com'; InDefaultNames = $true }
        @{ Key = 'azurePurviewPortalPrivateDnsZoneId'; Zone = 'privatelink.purviewstudio.azure.com'; InDefaultNames = $true }
        @{ Key = 'azureHealthDataServicesPrivateDnsZoneId'; Zone = 'privatelink.azurehealthcareapis.com'; InDefaultNames = $true }
        @{ Key = 'azureHealthDataServicesDicomPrivateDnsZoneId'; Zone = 'privatelink.dicom.azurehealthcareapis.com'; InDefaultNames = $true }
        @{ Key = 'azurePowerBIAnalysisPrivateDnsZoneId'; Zone = 'privatelink.analysis.windows.net'; InDefaultNames = $true }
        @{ Key = 'azurePowerBIDedicatedPrivateDnsZoneId'; Zone = 'privatelink.pbidedicated.windows.net'; InDefaultNames = $true }
        # Opt-in in dnsZoneNames mode: the Terraform and Bicep hub modules do not create this zone.
        @{ Key = 'azurePowerBIPowerQueryPrivateDnsZoneId'; Zone = 'privatelink.prod.powerquery.microsoft.com'; InDefaultNames = $false }
    )
    $genericSlots = @(
        @{ Reference = 'DINE-Private-DNS-Azure-SqlServer'; Key = 'azureSqlServerPrivateDnsZoneId'; ResourceType = 'Microsoft.Sql/servers'; GroupId = 'sqlServer' }
        @{ Reference = 'DINE-Private-DNS-Azure-ApiManagement'; Key = 'azureApiManagementPrivateDnsZoneId'; ResourceType = 'Microsoft.ApiManagement/service'; GroupId = 'Gateway' }
        @{ Reference = 'DINE-Private-DNS-Azure-MySQL'; Key = 'azureMySQLPrivateDnsZoneId'; ResourceType = 'Microsoft.DBforMySQL/flexibleServers'; GroupId = 'mysqlServer' }
        @{ Reference = 'DINE-Private-DNS-Azure-PostgreSQL'; Key = 'azurePostgreSQLPrivateDnsZoneId'; ResourceType = 'Microsoft.DBforPostgreSQL/flexibleServers'; GroupId = 'postgresqlServer' }
        @{ Reference = 'DINE-Private-DNS-Azure-CosmosPostgreSQL'; Key = 'azureCosmosPostgreSQLPrivateDnsZoneId'; ResourceType = 'Microsoft.DBforPostgreSQL/serverGroupsv2'; GroupId = 'coordinator' }
        @{ Reference = 'DINE-Private-DNS-Azure-DigitalTwins'; Key = 'azureDigitalTwinsPrivateDnsZoneId'; ResourceType = 'Microsoft.DigitalTwins/digitalTwinsInstances'; GroupId = 'API' }
        @{ Reference = 'DINE-Private-DNS-Azure-ManagedHSM'; Key = 'azureManagedHSMPrivateDnsZoneId'; ResourceType = 'Microsoft.KeyVault/managedHSMs'; GroupId = 'managedhsm' }
        @{ Reference = 'DINE-Private-DNS-Azure-Purview-Account'; Key = 'azurePurviewAccountPrivateDnsZoneId'; ResourceType = 'Microsoft.Purview/accounts'; GroupId = 'account' }
        @{ Reference = 'DINE-Private-DNS-Azure-Purview-Portal'; Key = 'azurePurviewPortalPrivateDnsZoneId'; ResourceType = 'Microsoft.Purview/accounts'; GroupId = 'portal' }
    )
}

BeforeAll {
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
    function Get-RepoJson([string]$Path) { Get-Content -Raw (Join-Path $repoRoot $Path) | ConvertFrom-Json -AsHashtable -Depth 100 }
    $initiative = Get-RepoJson 'src/resources/Microsoft.Authorization/policySetDefinitions/Deploy-Private-DNS-Zones.json'
    $generic = Get-RepoJson 'src/resources/Microsoft.Authorization/policyDefinitions/Deploy-Private-DNS-Generic.json'
    $policy = Get-RepoJson 'src/resources/Microsoft.Authorization/policyDefinitions/Deploy-Private-DNS-Generic-MultiZone.json'
    $assignment = Get-RepoJson 'eslzArm/managementGroupTemplates/policyAssignments/DINE-PrivateDNSZonesPolicyAssignment.json'
    $assignedParameters = @($assignment.resources | Where-Object type -EQ 'Microsoft.Authorization/policyAssignments')[0].properties.parameters
    $hubZoneLists = @('eslzArm/eslz-portal.json', 'eslzArm/eslzArm.terraform-sync.param.json', 'eslzArm/eslzArm.test.param.hns.json') |
        ForEach-Object { @{ Path = $_; Text = Get-Content -Raw (Join-Path $repoRoot $_) } }
    $customDefinitionPrefix = '/providers/Microsoft.Management/managementGroups/contoso/providers/Microsoft.Authorization/policyDefinitions/'
    $rule = $policy.properties.policyRule
    $details = $rule.then.details
    $template = $details.deployment.properties.template
    $zoneParameters = @('privateDnsZoneId', 'privateDnsZoneId2', 'privateDnsZoneId3', 'privateDnsZoneId4')
    function Get-Reference([string]$Id) { , @($initiative.properties.policyDefinitions | Where-Object policyDefinitionReferenceId -EQ $Id) }
    function Get-GuardedZoneExpression([string]$Key) { "union(createObject('$Key', ''), parameters('dnsZoneNames')).$Key" }
}

Describe 'Private DNS zone wiring <Key>' -ForEach $zoneWiring {
    It 'is an optional initiative parameter with the expected dnsZoneNames default' {
        $parameter = $initiative.properties.parameters[$Key]
        $parameter.type | Should -Be 'string'
        $parameter.defaultValue | Should -Be ''
        $parameter.metadata.strongType | Should -Be 'Microsoft.Network/privateDnsZones'
        if ($InDefaultNames) {
            $initiative.properties.parameters.dnsZoneNames.defaultValue[$Key] | Should -Be $Zone
        }
        else {
            $initiative.properties.parameters.dnsZoneNames.defaultValue.ContainsKey($Key) | Should -BeFalse
        }
    }

    It 'is passed by the Portal assignment and the zone is created by the Portal hub' {
        $assignment.variables.policyParameterMapping[$Key] | Should -Be "[concat(variables('baseId'), '$Zone')]"
        $assignedParameters[$Key].value | Should -Be "[variables('policyParameterMapping').$Key]"
        foreach ($list in $hubZoneLists) {
            $list.Text | Should -Match ([regex]::Escape('"' + $Zone + '"')) -Because $list.Path
        }
    }
}

Describe 'Bot Service Token reference' {
    It 'uses built-in 6a4e6f44 with the Token group ID' {
        $references = Get-Reference 'DINE-Private-DNS-Azure-BotService-Token'
        $references.Count | Should -Be 1
        $reference = $references[0]
        $reference.policyDefinitionId | Should -Be '/providers/Microsoft.Authorization/policyDefinitions/6a4e6f44-f2af-4082-9702-033c9e88b9f8'
        $reference.definitionVersion | Should -Be '1.*.*'
        @($reference.parameters.Keys | Sort-Object) | Should -Be @('effect', 'privateDnsZoneId', 'privateEndpointGroupId')
        $reference.parameters.privateEndpointGroupId.value | Should -Be 'Token'
        $reference.parameters.privateDnsZoneId.value | Should -Match ([regex]::Escape((Get-GuardedZoneExpression 'azureBotServiceTokenPrivateDnsZoneId')))
        $reference.parameters.effect.value | Should -Match ([regex]::Escape("parameters('azureBotServiceTokenPrivateDnsZoneId')"))
        $reference.parameters.effect.value | Should -Match "'Disabled', parameters\('effect'\)"
    }

    It 'keeps the existing Bot reference on the built-in default group ID' {
        $references = Get-Reference 'DINE-Private-DNS-Azure-BotService'
        $references.Count | Should -Be 1
        $references[0].policyDefinitionId | Should -Be '/providers/Microsoft.Authorization/policyDefinitions/6a4e6f44-f2af-4082-9702-033c9e88b9f8'
        $references[0].parameters.ContainsKey('privateEndpointGroupId') | Should -BeFalse
        $references[0].parameters.effect.value | Should -Be "[[parameters('effect')]"
    }
}

Describe 'Deploy-Private-DNS-Generic' {
    It 'matches a wildcard or an exact private endpoint location' {
        [version]$generic.properties.metadata.version | Should -BeGreaterOrEqual ([version]'2.2.0')
        $location = $generic.properties.policyRule.if.allOf[0].anyOf
        $location.Count | Should -Be 2
        $location[0].value | Should -Be "[[parameters('location')]"
        $location[0].equals | Should -Be '*'
        $location[1].field | Should -Be 'location'
        $location[1].equals | Should -Be "[[parameters('location')]"
    }

    It 'deploys into the endpoint location and grants permissions on the zone' {
        $generic.properties.policyRule.then.details.deployment.properties.parameters.location.value | Should -Be "[[field('location')]"
        $generic.properties.parameters.privateDnsZoneId.metadata.assignPermissions | Should -BeTrue
    }
}

Describe 'Generic private DNS slot <Reference>' -ForEach $genericSlots {
    It 'uses Deploy-Private-DNS-Generic with fixed resource type, group ID and wildcard location' {
        $references = Get-Reference $Reference
        $references.Count | Should -Be 1
        $reference = $references[0]
        $reference.policyDefinitionId | Should -Be ($customDefinitionPrefix + 'Deploy-Private-DNS-Generic')
        $reference.definitionVersion | Should -Be '1.*.*'
        $reference.parameters.resourceType.value | Should -Be $ResourceType
        $reference.parameters.groupId.value | Should -Be $GroupId
        $reference.parameters.location.value | Should -Be '*'
        foreach ($name in $reference.parameters.Keys) { $generic.properties.parameters.Keys | Should -Contain $name }
    }

    It 'guards the dnsZoneNames lookup and is disabled when the zone is empty' {
        $reference = (Get-Reference $Reference)[0]
        $reference.parameters.privateDnsZoneId.value | Should -Match ([regex]::Escape((Get-GuardedZoneExpression $Key)))
        $reference.parameters.privateDnsZoneId.value | Should -Not -Match ([regex]::Escape("parameters('dnsZoneNames').$Key"))
        $reference.parameters.effect.value | Should -Match ([regex]::Escape("parameters('$Key')"))
        $reference.parameters.effect.value | Should -Match "'Disabled', parameters\('effect'\)"
    }
}

Describe 'Deploy-Private-DNS-Generic-MultiZone' {
    BeforeAll {
        $slots = @(
            @{
                Reference = 'DINE-Private-DNS-Azure-HealthDataServices'
                ResourceType = 'Microsoft.HealthcareApis/workspaces'
                GroupId = 'healthcareworkspace'
                Keys = @('azureHealthDataServicesPrivateDnsZoneId', 'azureHealthDataServicesDicomPrivateDnsZoneId')
            }
            @{
                Reference = 'DINE-Private-DNS-Azure-PowerBI'
                ResourceType = 'Microsoft.PowerBI/privateLinkServicesForPowerBI'
                GroupId = 'tenant'
                Keys = @('azurePowerBIAnalysisPrivateDnsZoneId', 'azurePowerBIDedicatedPrivateDnsZoneId', 'azurePowerBIPowerQueryPrivateDnsZoneId')
            }
        )
    }

    It 'exposes four optional string zone IDs with assignPermissions' {
        foreach ($name in $zoneParameters) {
            $parameter = $policy.properties.parameters[$name]
            $parameter.type | Should -Be 'String'
            $parameter.ContainsKey('defaultValue') | Should -BeTrue
            $parameter.defaultValue | Should -Be ''
            $parameter.metadata.strongType | Should -Be 'Microsoft.Network/privateDnsZones'
            $parameter.metadata.assignPermissions | Should -BeTrue
        }
    }

    It 'excludes all-empty zone assignments from evaluation' {
        $guard = @($rule.if.allOf | Where-Object { $_.ContainsKey('value') })
        $guard.Count | Should -Be 1
        $guard[0].value | Should -Be "[[concat(parameters('privateDnsZoneId'), parameters('privateDnsZoneId2'), parameters('privateDnsZoneId3'), parameters('privateDnsZoneId4'))]"
        $guard[0].notEquals | Should -Be ''
    }

    It 'supports wildcard or exact location without deploying into the wildcard location' {
        $location = @($rule.if.allOf | Where-Object { $_.ContainsKey('anyOf') -and $_.anyOf[0].ContainsKey('value') })[0].anyOf
        $location[0].value | Should -Be "[[parameters('location')]"
        $location[0].equals | Should -Be '*'
        $location[1].field | Should -Be 'location'
        $location[1].equals | Should -Be "[[parameters('location')]"
        $details.deployment.properties.parameters.location.value | Should -Be "[[field('location')]"
    }

    It 'requires resource type and group ID within the same automatic or manual connection' {
        $connections = @($rule.if.allOf | Where-Object { $_.ContainsKey('anyOf') -and $_.anyOf[0].ContainsKey('count') })[0].anyOf
        $connections.Count | Should -Be 2
        for ($i = 0; $i -lt 2; $i++) {
            $property = @('privateLinkServiceConnections', 'manualPrivateLinkServiceConnections')[$i]
            $prefix = "Microsoft.Network/privateEndpoints/$property"
            $connections[$i].count.field | Should -Be "$prefix`[*]"
            $where = $connections[$i].count.where.allOf
            $where[0].field | Should -Be "$prefix`[*].privateLinkServiceId"
            $where[0].contains | Should -Be "[[parameters('resourceType')]"
            $where[1].field | Should -Be "$prefix`[*].groupIds[*]"
            $where[1].equals | Should -Be "[[parameters('groupId')]"
            $connections[$i].greaterOrEquals | Should -Be 1
        }
    }

    It 'preserves workload-owned groups and checks every supplied zone in deployedByPolicy' {
        $existence = $details.existenceCondition.anyOf
        $existence[0].field | Should -Be 'name'
        $existence[0].notEquals | Should -Be 'deployedByPolicy'
        $checks = $existence[1].allOf
        $checks.Count | Should -Be 4
        for ($i = 0; $i -lt 4; $i++) {
            $expression = "[[parameters('$($zoneParameters[$i])')]"
            $checks[$i].anyOf[0].value | Should -Be $expression
            $checks[$i].anyOf[0].equals | Should -Be ''
            $check = $checks[$i].anyOf[1]
            $check.count.field | Should -Be 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups/privateDnsZoneConfigs[*]'
            $check.count.where.field | Should -Be 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups/privateDnsZoneConfigs[*].privateDnsZoneId'
            $check.count.where.equals | Should -Be $expression
            $check.greaterOrEquals | Should -Be 1
        }
    }

    It 'filters all four empty slots from the single deployedByPolicy resource' {
        $template.resources.Count | Should -Be 1
        $template.resources[0].name | Should -Be "[[concat(parameters('privateEndpointName'), '/deployedByPolicy')]"
        $parts = for ($i = 0; $i -lt 4; $i++) {
            $name = $zoneParameters[$i]
            $config = "zoneConfig$($i + 1)"
            $template.variables[$config].properties.privateDnsZoneId | Should -Be "[[parameters('$name')]"
            $details.deployment.properties.parameters[$name].value | Should -Be "[[parameters('$name')]"
            "if(empty(parameters('$name')), createArray(), createArray(variables('$config')))"
        }
        $template.resources[0].properties.privateDnsZoneConfigs | Should -Be ("[[concat(" + ($parts -join ', ') + ")]")
    }

    It 'wires each service to exactly one MultiZone reference with guarded zone IDs' {
        foreach ($slot in $slots) {
            $references = Get-Reference $slot.Reference
            $references.Count | Should -Be 1
            $reference = $references[0]
            $reference.policyDefinitionId | Should -Be ($customDefinitionPrefix + 'Deploy-Private-DNS-Generic-MultiZone')
            $reference.definitionVersion | Should -Be '1.*.*'
            $reference.parameters.resourceType.value | Should -Be $slot.ResourceType
            $reference.parameters.groupId.value | Should -Be $slot.GroupId
            $reference.parameters.location.value | Should -Be '*'
            @($reference.parameters.Keys | Where-Object { $_ -like 'privateDnsZoneId*' }).Count | Should -Be $slot.Keys.Count
            $reference.parameters.effect.value | Should -Match "'Disabled', parameters\('effect'\)"
            for ($i = 0; $i -lt $slot.Keys.Count; $i++) {
                $key = $slot.Keys[$i]
                $reference.parameters[$zoneParameters[$i]].value | Should -Match ([regex]::Escape((Get-GuardedZoneExpression $key)))
                $reference.parameters.effect.value | Should -Match ([regex]::Escape("parameters('$key')"))
            }
        }
    }
}

Describe 'Deploy-Private-DNS-Zones invariants' {
    It 'has unique policy definition reference IDs' {
        $duplicates = @($initiative.properties.policyDefinitions.policyDefinitionReferenceId | Group-Object | Where-Object Count -GT 1)
        $duplicates.Count | Should -Be 0 -Because ($duplicates.Name -join ', ')
    }

    It 'maps each resource type and group ID to at most one custom slot' {
        $slots = @($initiative.properties.policyDefinitions |
                Where-Object { $_.parameters.ContainsKey('resourceType') } |
                ForEach-Object { "$($_.parameters.resourceType.value)|$($_.parameters.groupId.value)".ToLowerInvariant() })
        $slots.Count | Should -BeGreaterThan 0
        @($slots | Group-Object | Where-Object Count -GT 1).Count | Should -Be 0
    }

    It 'only references initiative parameters that exist' {
        $missing = foreach ($reference in $initiative.properties.policyDefinitions) {
            foreach ($name in $reference.parameters.Keys) {
                foreach ($match in [regex]::Matches([string]$reference.parameters[$name].value, "parameters\('([^']+)'\)")) {
                    if (-not $initiative.properties.parameters.ContainsKey($match.Groups[1].Value)) {
                        "$($reference.policyDefinitionReferenceId)/$name -> $($match.Groups[1].Value)"
                    }
                }
            }
        }
        @($missing).Count | Should -Be 0 -Because ($missing -join '; ')
    }

    It 'receives only known parameters from the Portal assignment' {
        foreach ($name in $assignedParameters.Keys) { $initiative.properties.parameters.Keys | Should -Contain $name }
        foreach ($name in $assignment.variables.policyParameterMapping.Keys) { $assignedParameters.Keys | Should -Contain $name }
    }
}