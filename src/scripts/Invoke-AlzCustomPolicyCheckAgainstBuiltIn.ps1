[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Coloured output required in this script")] 

[CmdletBinding()]
Param
(
    [string]
    [parameter(ValueFromPipeline)][ValidateSet(';', ',')][string]$CsvDelimiter = ';',

    [string]
    $FileTimeStampFormat = 'yyyyMMdd_HHmmss'
)

#region helper
if ($CsvDelimiter -eq ';') {
    $CsvDelimiterOpposite = ','
}
if ($CsvDelimiter -eq ',') {
    $CsvDelimiterOpposite = ';'
}
#endregion helper

#region AzAPICall
try {
    $azAPICallConf = initAzAPICall -DebugAzAPICall $True
}
catch {
    Write-Host "Install AzAPICall Powershell Module https://www.powershellgallery.com/packages/AzAPICall (aka.ms/AzAPICall)" -ForegroundColor DarkRed
    Write-Host "Command: Install-Module -Name AzAPICall" -ForegroundColor Yellow
    throw
}
#endregion AzAPICall

#region get ALZ policies.json
$ALZRetryMax = 5
$ALZRetryCount = 0
do {
    $ALZRetryCount++
    $ALZPoliciesRaw = Invoke-WebRequest -uri "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/eslzArm/managementGroupTemplates/policyDefinitions/policies.json"

    if ($ALZPoliciesRaw.StatusCode -ne 200) {
        Write-Output "getALZPolicies: $($ALZPoliciesRaw.StatusCode -eq 200) - try again in $($ALZRetryCount * 2) seconds"
        start-sleep -seconds ($ALZRetryCount * 2)
    }
}
until($ALZPoliciesRaw.StatusCode -eq 200 -or $ALZRetryCount -gt $ALZRetryMax)
if ($ALZRetryCount -gt 10 -and $ALZPoliciesRaw.StatusCode -ne 200) {
    Write-Output "ALZ Policies failed"
    throw
}
#endregion get ALZ policies.json

$jsonALZPolicies = $ALZPoliciesRaw.Content -replace "\[\[", '[' | ConvertFrom-Json
[regex]$extractVariableName = "(?<=\[variables\(')[^']+"
$refsPolicyDefinitionsAll = $extractVariableName.Matches($jsonALZPolicies.variables.loadPolicyDefinitions.All).Value
$refsPolicyDefinitions = $extractVariableName.Matches($jsonALZPolicies.variables.loadPolicyDefinitions.$($azapicallconf['checkContext'].Environment.Name)).Value
$listPolicyDefinitions = $refsPolicyDefinitionsAll + $refsPolicyDefinitions
$policyDefinitionsALZ = $listPolicyDefinitions.ForEach({ $jsonALZPolicies.variables.$_ })

if ($policyDefinitionsALZ.Count -eq 0) {
    throw "Found $($policyDefinitionsALZ.Count) ALZ Policy definitions for $($azapicallconf['checkContext'].Environment.Name)"
}
else {
    function getHash {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [object]
            $object
        )
        return [System.BitConverter]::ToString([System.Security.Cryptography.HashAlgorithm]::Create("sha256").ComputeHash([System.Text.Encoding]::UTF8.GetBytes($object)))
    }

    $currentTask = 'Getting BuiltIn Policy definitions'
    $uri = "$($azAPICallConf['azAPIEndpointUrls'].ARM)/providers/Microsoft.Authorization/policyDefinitions?api-version=2021-06-01&`$filter=policyType eq 'BuiltIn'"
    $method = 'GET'
    $policyDefinitionsBuiltIn = AzAPICall -AzAPICallConfiguration $azAPICallConf -uri $uri -method $method -currentTask $currentTask

    Write-Host "Found $($policyDefinitionsALZ.Count) ALZ Policy definitions for $($azapicallconf['checkContext'].Environment.Name)"
    Write-Host "Found $($policyDefinitionsBuiltIn.Count) BuiltIn Policy definitions for $($azapicallconf['checkContext'].Environment.Name)"

    $htHashesBuiltIn = @{}
    foreach ($policyDefinitionBuiltIn in $policyDefinitionsBuiltIn) {
        $policyObject = $policyDefinitionBuiltIn

        if ($policyObject.properties.parameters.effect.defaultvalue) {
            $arrEff = foreach ($eff in $policyObject.properties.parameters.effect.allowedValues) {
                $eff
            }
            $arrEff += $policyObject.properties.parameters.effect.defaultvalue
            $effectBuiltIn = ($arrEff | Sort-Object -Unique) -join "$CsvDelimiterOpposite "
        }
        else {
            if ($policyObject.properties.parameters.policyEffect.defaultValue) {
                $arrEff = foreach ($eff in $policyObject.properties.parameters.policyEffect.allowedValues) {
                    $eff
                }
                $arrEff += $policyObject.properties.parameters.policyEffect.defaultvalue
                $effectBuiltIn = ($arrEff | Sort-Object -Unique) -join "$CsvDelimiterOpposite "
            }
            else {
                $effectBuiltIn = $policyObject.Properties.policyRule.then.effect
            }
        }

        $htHashesBuiltIn.($policyObject.name) = @{}
        $htHashesBuiltIn.($policyObject.name).policy = $policyObject
        $htHashesBuiltIn.($policyObject.name).effectBuiltIn = $effectBuiltIn

        $htHashesBuiltIn.($policyObject.name).policyRuleHash = getHash -object ($policyObject.properties.policyRule | ConvertTo-Json -depth 99)
        $htHashesBuiltIn.($policyObject.name).policyRuleIfHash = getHash -object ($policyObject.properties.policyRule.if | ConvertTo-Json -depth 99)
        $htHashesBuiltIn.($policyObject.name).policyRuleThenHash = getHash -object ($policyObject.properties.policyRule.then | ConvertTo-Json -depth 99)
    }

    $arrayResults = [System.Collections.ArrayList]@()
    foreach ($policyDefinitionALZ in $policyDefinitionsALZ) {
        $policyObject = $policyDefinitionALZ | ConvertFrom-Json
        if ($policyObject.properties.parameters.effect.defaultvalue) {
            $arrEff = foreach ($eff in $policyObject.properties.parameters.effect.allowedValues) {
                $eff
            }
            $arrEff += $policyObject.properties.parameters.effect.defaultvalue
            $effectALZ = ($arrEff | Sort-Object -Unique) -join "$CsvDelimiterOpposite "
        }
        else {
            if ($policyObject.properties.parameters.policyEffect.defaultValue) {
                $arrEff = foreach ($eff in $policyObject.properties.parameters.policyEffect.allowedValues) {
                    $eff
                }
                $arrEff += $policyObject.properties.parameters.policyEffect.defaultvalue
                $effectALZ = ($arrEff | Sort-Object -Unique) -join "$CsvDelimiterOpposite "
            }
            else {
                $effectALZ = $policyObject.Properties.policyRule.then.effect
            }
        }

        $policyRuleHash = getHash -object ($policyObject.properties.policyRule | ConvertTo-Json -depth 99)
        if ($htHashesBuiltIn.values.policyRuleHash -contains $policyRuleHash) {
            $ref = ($htHashesBuiltIn.values.where({ $_.policyRuleHash -eq $policyRuleHash }) | Select-Object effectBuiltIn, @{Label = 'name'; Expression = { $_.policy.Name } }, @{Label = 'displayName'; Expression = { $_.policy.properties.displayName } })
            Write-Host "ALZ '$($policyObject.name)' policy-Rule matches a BuiltIn policy def: id:'$($ref.Name)' displayName: '$($ref.displayName)'" -ForegroundColor Magenta
            Write-Host " - AzA ALZ Link: https://www.azadvertizer.net/azpolicyadvertizer/$($policyObject.name).html" -ForegroundColor Magenta
            Write-Host " - AzA BuiltIn Link: https://www.azadvertizer.net/azpolicyadvertizer/$($ref.Name).html" -ForegroundColor Magenta

            $null = $arrayResults.Add([PSCustomObject]@{
                    ALZEffect                = $effectALZ
                    ALZPolicy                = $policyObject.name
                    ALZPolicyDisplayName     = $policyObject.properties.displayName
                    ALZPolicyLink            = "https://www.azadvertizer.net/azpolicyadvertizer/$($policyObject.name).html"
                    Match                    = 'policyRule'
                    MatchCount               = $ref.Count
                    BuilTinEffect            = $ref.effectBuiltIn
                    BuiltinPolicy            = $ref.Name
                    BuiltinPolicyDisplayName = $ref.displayName
                    BuiltinPolicyLink        = "https://www.azadvertizer.net/azpolicyadvertizer/$($ref.Name).html"
                })
        }

        $policyRuleIfHash = getHash -object ($policyObject.properties.policyRule.if | ConvertTo-Json -depth 99)
        if ($htHashesBuiltIn.values.policyRuleIfHash -contains $policyRuleIfHash) {
            $ref = ($htHashesBuiltIn.values.where({ $_.policyRuleIfHash -eq $policyRuleIfHash }) | Select-Object effectBuiltIn, @{Label = 'name'; Expression = { $_.policy.Name } }, @{Label = 'displayName'; Expression = { $_.policy.properties.displayName } })
            Write-Host "ALZ '$($policyObject.name)' policy-Rule-If match in $($ref.count) Builtin Policy defs"

            foreach ($entry in $ref) {

                $null = $arrayResults.Add([PSCustomObject]@{
                        ALZEffect                = $effectALZ
                        ALZPolicy                = $policyObject.name
                        ALZPolicyDisplayName     = $policyObject.properties.displayName
                        ALZPolicyLink            = "https://www.azadvertizer.net/azpolicyadvertizer/$($policyObject.name).html"
                        Match                    = 'policyRuleIf'
                        MatchCount               = $ref.Count
                        BuilTinEffect            = $entry.effectBuiltIn
                        BuiltinPolicy            = $entry.Name
                        BuiltinPolicyDisplayName = $entry.displayName
                        BuiltinPolicyLink        = "https://www.azadvertizer.net/azpolicyadvertizer/$($entry.Name).html"
                    })
            }
        }

        $policyRuleThenHash = getHash -object ($policyObject.properties.policyRule.then | ConvertTo-Json -depth 99)
        if ($htHashesBuiltIn.values.policyRuleThenHash -contains $policyRuleThenHash) {
            $ref = ($htHashesBuiltIn.values.where({ $_.policyRuleThenHash -eq $policyRuleThenHash }) | Select-Object effectBuiltIn, @{Label = 'name'; Expression = { $_.policy.Name } }, @{Label = 'displayName'; Expression = { $_.policy.properties.displayName } })
            Write-Host "ALZ '$($policyObject.name)' policy-Rule-Then match in $($ref.count) Builtin Policy defs"

            foreach ($entry in $ref) {
                $null = $arrayResults.Add([PSCustomObject]@{
                        ALZEffect                = $effectALZ
                        ALZPolicy                = $policyObject.name
                        ALZPolicyDisplayName     = $policyObject.properties.displayName
                        ALZPolicyLink            = "https://www.azadvertizer.net/azpolicyadvertizer/$($policyObject.name).html"
                        Match                    = 'policyRuleThen'
                        MatchCount               = $ref.Count
                        BuilTinEffect            = $entry.effectBuiltIn
                        BuiltinPolicy            = $entry.Name
                        BuiltinPolicyDisplayName = $entry.displayName
                        BuiltinPolicyLink        = "https://www.azadvertizer.net/azpolicyadvertizer/$($entry.Name).html"
                    })
            }
        }
    }

    $fileTimestamp = (Get-Date -Format $FileTimeStampFormat)
    $arrayResults | Export-Csv -delimiter $CsvDelimiter -path "alzvsbuiltin_$($fileTimestamp).csv"-Encoding utf8
}
