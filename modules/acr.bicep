param name string
param location string
param acrAdminUserEnabled bool

@secure()
param adminCredentialsKeyVaultResourceId string

@secure()
param adminCredentialsKeyVaultSecretUserName  string

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


resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: last(split(adminCredentialsKeyVaultResourceId, '/'))
}

resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserName
  parent: adminCredentialsKeyVault
  properties: {
   value: acr.listCredentials().username
  }
 }
 
resource secretAdminPassword 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword1
  parent: adminCredentialsKeyVault
  properties: {
   value: acr.listCredentials().passwords[0].value
  }
 }

resource secretAdminPassword2 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword2
  parent: adminCredentialsKeyVault
  properties: {
   value: acr.listCredentials().passwords[1].value
  }
 }


output credentials object = {
  username: acr.listCredentials().username
  password: acr.listCredentials().passwords[0].value
}
