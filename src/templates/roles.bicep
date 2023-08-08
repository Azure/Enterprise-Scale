targetScope = 'managementGroup'

// Extract the environment name to dynamically determine which policies to deploy.
var cloudEnv = environment().name

// The following var contains lists of files containing Role Definition resources to load, grouped by compatibility with Cloud.
var loadRoleDefinitions = {
  All: [
    loadJsonContent('../resources/Microsoft.Authorization/roleDefinitions/Application-Owners.json')
    loadJsonContent('../resources/Microsoft.Authorization/roleDefinitions/Network-Management.json')
    loadJsonContent('../resources/Microsoft.Authorization/roleDefinitions/Security-Operations.json')
    loadJsonContent('../resources/Microsoft.Authorization/roleDefinitions/Subscription-Owner.json')
  ]
  AzureCloud: []
  AzureChinaCloud: []
  AzureUSGovernment: []
}

// The following var is used to compile the required Role Definitions into a single object
var roleDefinitionsByCloudType = {
  All: loadRoleDefinitions.All
  AzureCloud: loadRoleDefinitions.AzureCloud
  AzureChinaCloud: loadRoleDefinitions.AzureChinaCloud
  AzureUSGovernment: loadRoleDefinitions.AzureUSGovernment
}

// The following var is used to extract the Role Definitions into a single list for deployment
// This will contain all Role Definitions classified as available for All cloud environments, and those for the current cloud environment
var roleDefinitions = concat(roleDefinitionsByCloudType.All, roleDefinitionsByCloudType[cloudEnv])

// Create the Role Definitions as needed for the target cloud environment
resource RoleDefinitions 'Microsoft.Authorization/roleDefinitions@2022-04-01' = [for role in roleDefinitions: {
  name: guid(role.properties.roleName, managementGroup().name)
  properties: {
    roleName: '[${managementGroup().name}] ${role.properties.roleName}'
    description: role.properties.description
    type: role.properties.type
    permissions: role.properties.permissions
    assignableScopes: [
      managementGroup().id
    ]
  }
}]
