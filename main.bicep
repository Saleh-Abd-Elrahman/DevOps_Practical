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
param keyVaultName string

@description('Name of the Key Vault secret for ACR Username')
param keyVaultSecretNameACRUsername string

@description('Name of the Key Vault secret for ACR Password')
param keyVaultSecretNameACRPassword1 string

@description('Name of the Key Vault secret for ACR Password 2')
param keyVaultSecretNameACRPassword2 string


module acr './modules/acr.bicep' = {
  name: 'acrModule'
  params: {
    adminCredentialsKeyVaultResourceId: keyvault.id
    adminCredentialsKeyVaultSecretUserName: keyVaultSecretNameACRUsername
    adminCredentialsKeyVaultSecretUserPassword1: keyVaultSecretNameACRPassword1
    adminCredentialsKeyVaultSecretUserPassword2: keyVaultSecretNameACRPassword2
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
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

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {

  name: keyVaultName
 
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

    dockerRegistryServerUserName: keyvault.getSecret(keyVaultSecretNameACRUsername)

    dockerRegistryServerPassword: keyvault.getSecret(keyVaultSecretNameACRPassword1)

  }

}
