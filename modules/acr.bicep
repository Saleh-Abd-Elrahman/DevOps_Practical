param name string
param location string
param acrAdminUserEnabled bool

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


output credentials object = {
  username: acr.listCredentials().username
  password: acr.listCredentials().passwords[0].value
}
