@description('The location for the resources')
param location string = resourceGroup().location

@description('Name of the ACR')
param containerRegistryName string

@description('Name of the container image')
param containerRegistryImageName string

@description('Version of the container image')
param containerRegistryImageVersion string

@description('Name of the App Service Plan')
param appServicePlanName string

@description('Name of the Web App')
param webAppName string

@description('Name of the Key Vault')
param KeyVaultName string


module keyVault './modules/key-vault.bicep' = {
  name: 'deployKeyVault'
  params: {
    name: '${KeyVaultName}-kv'
    location: location
    enableVaultForDeployment: true
    roleAssignments: [
      {
        principalId: '7200f83e-ec45-4915-8c52-fb94147cfe5a'
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

module acr './modules/acr.bicep' = {
  name: 'acrModule'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
    adminCredentialsKeyVaultResourceId: '4633458b-17de-408a-b874-0445c86b69e6'
    adminCredentialsKeyVaultSecretUserName: 'adminUserName'
    adminCredentialsKeyVaultSecretUserPassword1: 'adminPassword1'
    adminCredentialsKeyVaultSecretUserPassword2: 'adminPassword2'
  }
}


module appServicePlan './modules/asp.bicep' = {
  name: 'appServicePlanModule'
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    kind: 'Linux'
    reserved: true
  }
}

module webApp './modules/awa.bicep' = {
  name: 'webAppModule'
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {}
    dockerRegistryServerUrl: 'https://${containerRegistryName}.azurecr.io'
    dockerRegistryServerUserName: 'acr-username'
    dockerRegistryServerPassword: 'acr-password'
  }

}
