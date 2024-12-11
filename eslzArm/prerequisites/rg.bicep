targetScope = 'subscription'

param location string

resource rg 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: 'rg-alz-prereqs'
  location: location
}

module uaiDeployment 'uai.bicep' = {
  scope: rg
  name: 'uaiDeployment'
  params: {
    location: location
  }
}

output uaiResourceId string = uaiDeployment.outputs.uaiResourceId
output uaiPrincipalId string = uaiDeployment.outputs.uaiPrincipalId
