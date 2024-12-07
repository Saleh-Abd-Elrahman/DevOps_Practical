param name string
param location string
param acrAdminUserEnabled bool
param adminCredentialsKeyVaultResourceId string
@secure()
param adminCredentialsKeyVaultSecretUserName string
@secure()
param adminCredentialsKeyVaultSecretUserPassword1 string



resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: last(split(adminCredentialsKeyVaultResourceId, '/'))
}

resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: adminCredentialsKeyVaultSecretUserName
  parent: adminCredentialsKeyVault
  properties: {
    value: acr.listCredentials().username
  }
}

resource secretAdminUserPassword1 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: adminCredentialsKeyVaultSecretUserPassword1
  parent: adminCredentialsKeyVault
  properties: {
    value: acr.listCredentials().passwords[0].value
  }
}


output credentials object = {
  username: acr.listCredentials().username
  password: acr.listCredentials().passwords[0].value
}
