param(
  $managementGroupId = "6da17bdb-c2cc-4a35-8f10-cded38ebfc47",
  $policySetDefinitionFolderPath = "./src/resources/Microsoft.Authorization/policySetDefinitions",
  $policySetFileName = "Deploy-Private-DNS-Zones.json",
  $uninstall = $false
)

$policySetDefinition = Get-Content -Raw "$policySetDefinitionFolderPath/$policySetFileName"
$policySetDefinition = $policySetDefinition.Replace("[[", "[")
$policySetDefinitionObject = ConvertFrom-Json $policySetDefinition
$apiVersion = $policySetDefinitionObject.apiVersion
$policySetDefinitionName = $policySetDefinitionObject.name

$policySetDefinitionFinal = @{
  properties = $policySetDefinitionObject.properties
}

$policySetDefinitionFinalJson = ConvertTo-Json $policySetDefinitionFinal -Depth 100

$uri = "/providers/Microsoft.Management/managementGroups/$($managementGroupId)/providers/Microsoft.Authorization/policySetDefinitions/$($policySetDefinitionName)?api-version=$($apiVersion)"

if($uninstall) {
  Invoke-AzRestMethod `
    -Method DELETE `
    -Path $uri
  return
}

Invoke-AzRestMethod `
  -Method PUT `
  -Path $uri `
  -Payload $policySetDefinitionFinalJson
