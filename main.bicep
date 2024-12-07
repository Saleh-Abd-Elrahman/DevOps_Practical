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
param keyVaultName string = 'myKeyVaultName'

@description('Enable vault for deployment')
param enableVaultForDeployment bool = true

@description('Role assignments for Key Vault')
param roleAssignments array = [
  {
    principalId: '7200f83e-ec45-4915-8c52-fb94147cfe5a'
    roleDefinitionIdOrName: 'Key Vault Secrets User'
    principalType: 'ServicePrincipal'
  }
]

@description('Key Vault secret name for ACR Admin Username')
param adminCredentialsKeyVaultSecretUserName string = 'acr-username'

@description('Key Vault secret name for ACR Admin Password #1')
param adminCredentialsKeyVaultSecretUserPassword1 string = 'acr-password1'

@description('Key Vault secret name for ACR Admin Password #2')
param adminCredentialsKeyVaultSecretUserPassword2 string = 'acr-password2'


// Deploy the Key Vault
module keyVaultModule './modules/key-vault.bicep' = {
  name: 'keyVaultModule'
  params: {
    name: keyVaultName
    location: location
    enableVaultForDeployment: enableVaultForDeployment
    roleAssignments: roleAssignments
  }
}


// Reference to the Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}


// Deploy ACR and store credentials in KV
module acr './modules/acr.bicep' = {
  name: 'acrModule'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
    adminCredentialsKeyVaultResourceId: keyVaultModule.outputs.keyVaultResourceId
    adminCredentialsKeyVaultSecretUserName: adminCredentialsKeyVaultSecretUserName
    adminCredentialsKeyVaultSecretUserPassword1: adminCredentialsKeyVaultSecretUserPassword1
    adminCredentialsKeyVaultSecretUserPassword2: adminCredentialsKeyVaultSecretUserPassword2
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

// Deploy Web App with secrets from Key Vault
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
    dockerRegistryServerUserName: keyVault.getSecret(adminCredentialsKeyVaultSecretUserName)
    dockerRegistryServerPassword: keyVault.getSecret(adminCredentialsKeyVaultSecretUserPassword1)
  }
}
