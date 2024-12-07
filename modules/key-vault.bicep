param name string
param location string
param enableVaultForDeployment bool 
param roleAssignments array

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: name
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForDeployment: enableVaultForDeployment
  }
}

resource roleAssignmentsLoop 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for assignment in roleAssignments: {
  name: guid(keyVault.id, assignment.roleDefinitionIdOrName, assignment.principalId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // Key Vault Secrets User role ID
    principalId: assignment.principalId
    principalType: assignment.principalType
  }
}]

output keyVaultResourceId string = keyVault.id
