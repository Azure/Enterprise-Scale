Describe 'Private DNS MultiZone contracts' {
    BeforeAll {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $definitionRoot = Join-Path $repoRoot 'src\resources\Microsoft.Authorization'
        $policy = Get-Content -Raw (Join-Path $definitionRoot 'policyDefinitions\Deploy-Private-DNS-Generic-MultiZone.json') | ConvertFrom-Json -AsHashtable -Depth 100
        $initiative = Get-Content -Raw (Join-Path $definitionRoot 'policySetDefinitions\Deploy-Private-DNS-Zones.json') | ConvertFrom-Json -AsHashtable -Depth 100
        $assignment = Get-Content -Raw (Join-Path $repoRoot 'eslzArm\managementGroupTemplates\policyAssignments\DINE-PrivateDNSZonesPolicyAssignment.json') | ConvertFrom-Json -AsHashtable -Depth 100
        $rule = $policy.properties.policyRule
        $details = $rule.then.details
        $template = $details.deployment.properties.template
        $zoneParameters = @('privateDnsZoneId', 'privateDnsZoneId2', 'privateDnsZoneId3', 'privateDnsZoneId4')
        $slots = @(
            @{
                Reference = 'DINE-Private-DNS-Azure-HealthDataServices'
                ResourceType = 'Microsoft.HealthcareApis/workspaces'
                GroupId = 'healthcareworkspace'
                Keys = @('azureHealthDataServicesPrivateDnsZoneId', 'azureHealthDataServicesDicomPrivateDnsZoneId')
                Zones = @('privatelink.azurehealthcareapis.com', 'privatelink.dicom.azurehealthcareapis.com')
            }
            @{
                Reference = 'DINE-Private-DNS-Azure-PowerBI'
                ResourceType = 'Microsoft.PowerBI/privateLinkServicesForPowerBI'
                GroupId = 'tenant'
                Keys = @('azurePowerBIAnalysisPrivateDnsZoneId', 'azurePowerBIDedicatedPrivateDnsZoneId', 'azurePowerBIPowerQueryPrivateDnsZoneId')
                Zones = @('privatelink.analysis.windows.net', 'privatelink.pbidedicated.windows.net', 'privatelink.prod.powerquery.microsoft.com')
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

    It 'wires each service to exactly one MultiZone reference and every required Portal zone' {
        $assignedParameters = @($assignment.resources | Where-Object type -EQ 'Microsoft.Authorization/policyAssignments')[0].properties.parameters
        foreach ($slot in $slots) {
            $references = @($initiative.properties.policyDefinitions | Where-Object policyDefinitionReferenceId -EQ $slot.Reference)
            $references.Count | Should -Be 1
            $reference = $references[0]
            $reference.policyDefinitionId | Should -Be '/providers/Microsoft.Management/managementGroups/contoso/providers/Microsoft.Authorization/policyDefinitions/Deploy-Private-DNS-Generic-MultiZone'
            $reference.parameters.resourceType.value | Should -Be $slot.ResourceType
            $reference.parameters.groupId.value | Should -Be $slot.GroupId
            $reference.parameters.location.value | Should -Be '*'
            @($reference.parameters.Keys | Where-Object { $_ -like 'privateDnsZoneId*' }).Count | Should -Be $slot.Keys.Count
            $reference.parameters.effect.value | Should -Match "'Disabled', parameters\('effect'\)"
            for ($i = 0; $i -lt $slot.Keys.Count; $i++) {
                $key = $slot.Keys[$i]
                $zone = $slot.Zones[$i]
                $initiative.properties.parameters[$key].defaultValue | Should -Be ''
                if ($key -eq 'azurePowerBIPowerQueryPrivateDnsZoneId') {
                    # Opt-in in dnsZoneNames mode: the Terraform and Bicep hub modules do not create this zone.
                    $initiative.properties.parameters.dnsZoneNames.defaultValue.ContainsKey($key) | Should -BeFalse
                }
                else {
                    $initiative.properties.parameters.dnsZoneNames.defaultValue[$key] | Should -Be $zone
                }
                $reference.parameters[$zoneParameters[$i]].value | Should -Match ([regex]::Escape("union(createObject('$key', ''), parameters('dnsZoneNames')).$key"))
                $reference.parameters.effect.value | Should -Match ([regex]::Escape("parameters('$key')"))
                $assignment.variables.policyParameterMapping[$key] | Should -Be "[concat(variables('baseId'), '$zone')]"
                $assignedParameters[$key].value | Should -Be "[variables('policyParameterMapping').$key]"
                foreach ($path in @('eslzArm\eslz-portal.json', 'eslzArm\eslzArm.terraform-sync.param.json', 'eslzArm\eslzArm.test.param.hns.json')) {
                    $text = Get-Content -Raw (Join-Path $repoRoot $path)
                    $text | Should -Match ([regex]::Escape('"' + $zone + '"'))
                }
            }
        }
    }
}
