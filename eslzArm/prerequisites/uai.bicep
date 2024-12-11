param location string

resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: 'uai-alz-prereq'
  location: location
}

output uaiResourceId string = uai.id
output uaiPrincipalId string = uai.properties.principalId
