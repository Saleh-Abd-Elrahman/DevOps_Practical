@description('Name of the Key Vault')
param name string

@description('Location of the Key Vault')
param location string

@description('Enable vault for template deployment')
param enableVaultForDeployment bool

@description('Role assignments object')
param roleAssignments object

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: name
  location: location
  properties: {
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enabledForTemplateDeployment: enableVaultForDeployment
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}

resource kvRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(kv.id, roleAssignments.principalId, roleAssignments.roleDefinitionIdOrName)
  scope: kv
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // This is the ID for Key Vault Secrets User role
    principalId: roleAssignments.principalId
    principalType: roleAssignments.principalType
  }
}

output keyVaultName string = kv.name
output keyVaultResourceId string = kv.id
