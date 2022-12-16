targetScope = 'managementGroup'

@metadata({ message: 'The JSON version of this file is programatically generated from Bicep. PLEASE DO NOT UPDATE MANUALLY!!' })
@description('Provide a prefix (max 10 characters, unique at tenant-scope) for the Management Group hierarchy and other resources created as part of an Azure landing zone. DEFAULT VALUE = "alz"')
@maxLength(10)
param topLevelManagementGroupPrefix string = 'alz'

@description('Optinally Used to set the assignableScopes for the Role Definitions. Must be one of \'/\', \'/subscriptions/id\' or \'/providers/Microsoft.Management/managementGroups/id\'. DEFAULT VALUE = \'/providers/Microsoft.Management/managementGroups/\${topLevelManagementGroupPrefix}\'')
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
  roleDisplayNameScope: '[contoso]'
}

// The following var contains lists of files containing Role Definition resources to load, grouped by compatibility with Cloud.
// To get a full list of Azure clouds, use the az cli command "az cloud list --output table"
// We use loadTextContent instead of loadJsonContent  as this allows us to perform string replacement operations against the imported templates.
var loadRoleDefinitions = {
  All: [
    loadTextContent('../resources/Microsoft.Authorization/roleDefinitions/Application-Owners.json')
  ]
  AzureCloud: []
  AzureChinaCloud: []
  AzureUSGovernment: []
}

// The following vars are used to manipulate the imported Role Definitions to replace values
// Needs a double replace to handle updates in both templates for All clouds, and localized templates
var processRoleDefinitionsAll = [for content in loadRoleDefinitions.All: replace(replace(content, templateVars.scope, scope), templateVars.roleDisplayNameScope, '[${topLevelManagementGroupPrefix}]')]
var processRoleDefinitionsAzureCloud = [for content in loadRoleDefinitions.AzureCloud: replace(replace(content, templateVars.scope, scope), templateVars.roleDisplayNameScope, '[${topLevelManagementGroupPrefix}]')]
var processRoleDefinitionsAzureChinaCloud = [for content in loadRoleDefinitions.AzureChinaCloud: replace(replace(content, templateVars.scope, scope), templateVars.roleDisplayNameScope, '[${topLevelManagementGroupPrefix}]')]
var processRoleDefinitionsAzureUSGovernment = [for content in loadRoleDefinitions.AzureUSGovernment: replace(replace(content, templateVars.scope, scope), templateVars.roleDisplayNameScope, '[${topLevelManagementGroupPrefix}]')]

// The following vars are used to convert the imported Role Definitions into objects from JSON
var roleDefinitionsAll = [for content in processRoleDefinitionsAll: json(content)]
var roleDefinitionsAzureCloud = [for content in processRoleDefinitionsAzureCloud: json(content)]
var roleDefinitionsAzureChinaCloud = [for content in processRoleDefinitionsAzureChinaCloud: json(content)]
var roleDefinitionsAzureUSGovernment = [for content in processRoleDefinitionsAzureUSGovernment: json(content)]

// The following var is used to compile the required Role Definitions into a single object
var roleDefinitionsByCloudType = {
  All: roleDefinitionsAll
  AzureCloud: roleDefinitionsAzureCloud
  AzureChinaCloud: roleDefinitionsAzureChinaCloud
  AzureUSGovernment: roleDefinitionsAzureUSGovernment
}

// The following var is used to extract the Role Definitions into a single list for deployment
// This will contain all Role Definitions classified as available for All cloud environments, and those for the current cloud environment
var roleDefinitions = concat(roleDefinitionsByCloudType.All, roleDefinitionsByCloudType[cloudEnv])

// Create the Role Definitions as needed for the target cloud environment
resource RoleDefinitions 'Microsoft.Authorization/roleDefinitions@2022-04-01' = [for role in roleDefinitions: {
  name: guid(role.roleName, topLevelManagementGroupPrefix)
  properties: {
    roleName: role.roleName
    description: role.description
    type: role.type
    permissions: role.permissions
    assignableScopes: role.assignableScopes
  }
}]

output roleDefinitionNames array = [for role in roleDefinitions: role.name]
