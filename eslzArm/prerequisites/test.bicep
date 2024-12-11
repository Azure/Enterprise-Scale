targetScope = 'managementGroup'

param location string = 'uksouth'
param eslzRootName string = 'ALZ1'
param managementSubscriptionId string = '0f808fc8-eaf7-4731-bf31-8a318dcde228'

module alzPreReqsDeploy 'rg.bicep' = {
  scope: subscription(managementSubscriptionId)
  name: 'alzPreReqsDeploy'
  params: {
    location: location
  }
}

resource uaiRoleAsi 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(eslzRootName, managementSubscriptionId, location)
  properties: {
    principalId: alzPreReqsDeploy.outputs.uaiPrincipalId
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    principalType: 'ServicePrincipal'
  }
}
