param name string
param location string
param enableVaultForDeployment bool
param roleAssignments array

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enabledForDeployment: enableVaultForDeployment
    tenantId: subscription().tenantId
  }
}

resource keyVaultRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleAssignment in roleAssignments: {
  name: guid(keyVault.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
  properties: {
    principalId: roleAssignment.principalId
    principalType: roleAssignment.principalType
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName)
  }
}]

output keyVaultResourceId string = keyVault.id
