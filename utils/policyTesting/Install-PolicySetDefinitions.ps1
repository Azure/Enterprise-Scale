param(
  $managementGroupId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
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
