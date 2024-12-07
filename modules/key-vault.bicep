param name string
param location string
param enableVaultForDeployment bool
@description('An array of role assignments to configure Key Vault Secrets User role on the Key Vault.')
param roleAssignments array

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: name
  location: location
  properties: {
    enabledForDeployment: enableVaultForDeployment
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}

resource roleAssignmentsKV 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [
  for assignment in roleAssignments: {
    name: guid(keyVault.id, assignment.principalId, assignment.roleDefinitionIdOrName)
    properties: {
      principalId: assignment.principalId
      // Key Vault Secrets User built-in role definition ID:
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
      principalType: assignment.principalType
      scope: keyVault.id
    }
  }
]

output keyVaultResourceId string = keyVault.id
