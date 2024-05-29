targetScope = 'managementGroup'

@metadata({ message: 'The JSON version of this file is programatically generated from Bicep. PLEASE DO NOT UPDATE MANUALLY!!' })
@description('Provide a prefix (max 10 characters, unique at tenant-scope) for the Management Group hierarchy and other resources created as part of an Azure landing zone. DEFAULT VALUE = "alz"')
@maxLength(10)
param topLevelManagementGroupPrefix string = 'alz'

@description('Optionally set the deployment location for policies with Deploy If Not Exists effect. DEFAULT VALUE = "deployment().location"')
param location string = deployment().location

@description('Optionally set the scope for custom Policy Definitions used in Policy Set Definitions (Initiatives). Must be one of \'/\', \'/subscriptions/id\' or \'/providers/Microsoft.Management/managementGroups/id\'. DEFAULT VALUE = \'/providers/Microsoft.Management/managementGroups/\${topLevelManagementGroupPrefix}\'')
param scope string = tenantResourceId('Microsoft.Management/managementGroups', topLevelManagementGroupPrefix)

// Extract the environment name to dynamically determine which policies to deploy.
var cloudEnv = environment().name

// Default deployment locations used in templates
var defaultDeploymentLocationByCloudType = {
  AzureCloud: 'northeurope'
  AzureChinaCloud: 'chinaeast2'
  AzureUSGovernment: 'usgovvirginia'
}

// Used to identify template variables used in the templates for replacement.
var templateVars = {
  scope: '/providers/Microsoft.Management/managementGroups/contoso'
  defaultDeploymentLocation: '"location": "northeurope"'
  localizedDeploymentLocation: '"location": "${defaultDeploymentLocationByCloudType[cloudEnv]}"'
}

// The following var contains lists of files containing Policy Set Definition (Initiative) resources to load, grouped by compatibility with Cloud.
// To get a full list of Azure clouds, use the az cli command "az cloud list --output table"
// We use loadTextContent instead of loadJsonContent  as this allows us to perform string replacement operations against the imported templates.
var loadPolicySetDefinitions = {
  All: [
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Audit-UnusedResourcesCostOptimization.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Audit-TrustedLaunch.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deploy-Sql-Security.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deploy-Sql-Security_20240529.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-EncryptTransit.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-EncryptTransit_20240509.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-ALZ-Decomm.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-ALZ-Sandbox.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/DenyAction-DeleteProtection.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deploy-AUM-CheckUpdates.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-KeyVault.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-APIM.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-AppServices.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-Automation.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-CognitiveServices.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-Compute.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-ContainerApps.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-ContainerInstance.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-ContainerRegistry.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-CosmosDb.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-DataExplorer.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-DataFactory.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-EventGrid.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-EventHub.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-KeyVault-Sup.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-Kubernetes.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-MachineLearning.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-MySQL.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-Network.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-OpenAI.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-PostgreSQL.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-ServiceBus.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-SQL.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-Storage.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-Synapse.json') // FSI specific initiative
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Guardrails-VirtualDesktop.json') // FSI specific initiative
  ]
  AzureCloud: [
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deny-PublicPaaSEndpoints.json') // See AzureChinaCloud and AzureUSGovernment comments below for reasoning
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deploy-Diagnostics-LogAnalytics.json') // See AzureChinaCloud and AzureUSGovernment comments below for reasoning
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deploy-MDFC-Config.json') // See AzureChinaCloud and AzureUSGovernment comments below for reasoning
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deploy-MDFC-Config_20240319.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deploy-Private-DNS-Zones.json') // See AzureChinaCloud and AzureUSGovernment comments below for reasoning
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Encryption-CMK.json') // See AzureChinaCloud and AzureUSGovernment comments below for reasoning
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-ACSB.json') // Unable to validate if Guest Configuration is working in other clouds
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deploy-MDFC-DefenderSQL-AMA.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Backup.json') // Unable to validate if all Azure Site Recovery features are working in other clouds
  ]
  AzureChinaCloud: [
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deny-PublicPaaSEndpoints.AzureChinaCloud.json') // Due to missing built-in Policy Definitions ()
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deploy-Diagnostics-LogAnalytics.AzureChinaCloud.json') // Due to missing "Deploy-Diagnostics-AVDScalingPlans" custom Policy Definition
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deploy-MDFC-Config.AzureChinaCloud.json') // Due to missing built-in Policy Definitions (44433aa3-7ec2-4002-93ea-65c65ff0310a, 50ea7265-7d8c-429e-9a7d-ca1f410191c3, b40e7bcd-a1e5-47fe-b9cf-2f534d0bfb7d, 74c30959-af11-47b3-9ed2-a26e03f427a3, 1f725891-01c0-420a-9059-4fa46cb770b7, 2370a3c1-4a25-4283-a91a-c9c1a145fb2f, b7021b2b-08fd-4dc0-9de7-3c6ece09faf9, b99b73e7-074b-4089-9395-b7236f094491)
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deploy-Private-DNS-Zones.AzureChinaCloud.json') // Due to missing built-in Policy Definitions ()
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Encryption-CMK.AzureChinaCloud.json') // Due to missing built-in Policy Definitions (051cba44-2429-45b9-9649-46cec11c7119), and replacement custom Policy Definitions ("Deploy-MySQLCMKEffect", "Deploy-PostgreSQLCMKEffect")
  ]
  AzureUSGovernment: [
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deny-PublicPaaSEndpoints.AzureUSGovernment.json') // Due to missing built-in Policy Definitions (5e1de0e3-42cb-4ebc-a86d-61d0c619ca48, c9299215-ae47-4f50-9c54-8a392f68a052)
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deploy-Diagnostics-LogAnalytics.AzureUSGovernment.json') // Due to missing "Deploy-Diagnostics-AVDScalingPlans" custom Policy Definition
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deploy-MDFC-Config.AzureUSGovernment.json') // Due to missing built-in Policy Definitions (44433aa3-7ec2-4002-93ea-65c65ff0310a, 50ea7265-7d8c-429e-9a7d-ca1f410191c3, b40e7bcd-a1e5-47fe-b9cf-2f534d0bfb7d, 1f725891-01c0-420a-9059-4fa46cb770b7)
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Deploy-Private-DNS-Zones.AzureUSGovernment.json') // Due to missing built-in Policy Definitions (0b026355-49cb-467b-8ac4-f777874e175a)
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/Enforce-Encryption-CMK.AzureUSGovernment.json') // Due to missing built-in Policy Definitions (83cef61d-dbd1-4b20-a4fc-5fbc7da10833, 18adea5e-f416-4d0f-8aa8-d24321e3e274, 051cba44-2429-45b9-9649-46cec11c7119)
  ]
}

// The following vars are used to manipulate the imported Policy Set Definitions to replace Policy Definition scope values
var processPolicySetDefinitionsAll = [for content in loadPolicySetDefinitions.All: replace(content, templateVars.scope, scope)]
var processPolicySetDefinitionsAzureCloud = [for content in loadPolicySetDefinitions.AzureCloud: replace(content, templateVars.scope, scope)]
var processPolicySetDefinitionsAzureChinaCloud = [for content in loadPolicySetDefinitions.AzureChinaCloud: replace(content, templateVars.scope, scope)]
var processPolicySetDefinitionsAzureUSGovernment = [for content in loadPolicySetDefinitions.AzureUSGovernment: replace(content, templateVars.scope, scope)]

// The following vars are used to convert the imported Policy Set Definitions into objects from JSON
var policySetDefinitionsAll = [for content in processPolicySetDefinitionsAll: json(content)]
var policySetDefinitionsAzureCloud = [for content in processPolicySetDefinitionsAzureCloud: json(content)]
var policySetDefinitionsAzureChinaCloud = [for content in processPolicySetDefinitionsAzureChinaCloud: json(content)]
var policySetDefinitionsAzureUSGovernment = [for content in processPolicySetDefinitionsAzureUSGovernment: json(content)]

// The following var is used to compile the required Policy Definitions into a single object
var policySetDefinitionsByCloudType = {
  All: policySetDefinitionsAll
  AzureCloud: policySetDefinitionsAzureCloud
  AzureChinaCloud: policySetDefinitionsAzureChinaCloud
  AzureUSGovernment: policySetDefinitionsAzureUSGovernment
}

// The following var is used to extract the Policy Set Definitions into a single list for deployment
// This will contain all policy set definitions classified as available for All cloud environments, and those for the current cloud environment
var policySetDefinitions = concat(policySetDefinitionsByCloudType.All, policySetDefinitionsByCloudType[cloudEnv])

// Create the Policy Definitions as needed for the target cloud environment
// Depends on Policy Definitons to ensure they exist before creating dependent Policy Set Definitions (Initiatives)
resource PolicySetDefinitions 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = [for policy in policySetDefinitions: {
  // dependsOn: [
  //   PolicyDefinitions
  // ]
  name: policy.name
  properties: {
    description: policy.properties.description
    displayName: policy.properties.displayName
    metadata: policy.properties.metadata
    parameters: policy.properties.parameters
    policyType: policy.properties.policyType
    policyDefinitions: policy.properties.policyDefinitions
    policyDefinitionGroups: policy.properties.policyDefinitionGroups
  }
}]

// output policyDefinitionNames array = [for policy in policyDefinitions: policy.name]
output policySetDefinitionNames array = [for policy in policySetDefinitions: policy.name]
