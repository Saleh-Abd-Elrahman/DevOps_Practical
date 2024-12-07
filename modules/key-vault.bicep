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
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionIdOrName)
    principalId: assignment.principalId
    principalType: assignment.principalType
  }
}]

output keyVaultResourceId string = keyVault.id
