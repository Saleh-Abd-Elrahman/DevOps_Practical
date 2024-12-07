param name string
param location string
param acrAdminUserEnabled bool

@secure()
param adminCredentialsKeyVaultResourceId string

@secure()
param adminCredentialsKeyVaultSecretUserName string

@secure()
param adminCredentialsKeyVaultSecretUserPassword1 string

@secure()
param adminCredentialsKeyVaultSecretUserPassword2 string

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

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: adminCredentialsKeyVaultResourceId
}

resource adminUserNameSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserName
  parent: keyVault
  properties: {
    value: acr.listCredentials().username
  }
}

resource adminPasswordSecret1 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword1
  parent: keyVault
  properties: {
    value: acr.listCredentials().passwords[0].value
  }
}

resource adminPasswordSecret2 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword2
  parent: keyVault
  properties: {
    value: acr.listCredentials().passwords[0].value
  }
}

