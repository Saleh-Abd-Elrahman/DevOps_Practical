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

@description('Role assignments for the Key Vault')
param roleAssignments array

@description('Name of the Key Vault.')
param keyVaultName string

@description('Name of the Key Vault secret for ACR username.')
param keyVaultSecretNameACRUsername string

@description('Name of the Key Vault secret for ACR password 1.')
param keyVaultSecretNameACRPassword1 string

module keyVaultModule './modules/key-vault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    name: keyVaultName
    location: location
    enableVaultForDeployment: true
    roleAssignments: roleAssignments
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}


module acr './modules/acr.bicep' = {
  name: 'acrModule'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
    adminCredentialsKeyVaultResourceId: keyVaultModule.outputs.keyVaultResourceId
    adminCredentialsKeyVaultSecretUserName: keyVaultSecretNameACRUsername
    adminCredentialsKeyVaultSecretUserPassword1: keyVaultSecretNameACRPassword1
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
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
    }
    dockerRegistryServerUrl: 'https://${containerRegistryName}.azurecr.io'
    dockerRegistryServerUserName: keyVault.getSecret(keyVaultSecretNameACRUsername)
    dockerRegistryServerPassword: keyVault.getSecret(keyVaultSecretNameACRPassword1)
  }

}
