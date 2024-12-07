param name string
param location string
param kind string
param serverFarmResourceId string
param siteConfig object
param appSettingsKeyValuePairs object
@secure()
param dockerRegistryServerUrl string
@secure()
param dockerRegistryServerUserName string
@secure()
param dockerRegistryServerPassword string


var dockerAppSettings = {
  DOCKER_REGISTRY_SERVER_URL: dockerRegistryServerUrl
  DOCKER_REGISTRY_SERVER_USERNAME: dockerRegistryServerUserName
  DOCKER_REGISTRY_SERVER_PASSWORD: dockerRegistryServerPassword
}

var mergedAppSettingsKeyValuePairs = union(appSettingsKeyValuePairs, dockerAppSettings)


resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: name
  location: location
  kind: kind
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: {
      // Include existing siteConfig properties
      linuxFxVersion: siteConfig.linuxFxVersion
      appCommandLine: siteConfig.appCommandLine
      // Add appSettings within siteConfig
      appSettings: [
        for key in objectKeys(mergedAppSettingsKeyValuePairs): {
          name: key
          value: mergedAppSettingsKeyValuePairs[key]
        }
      ]
    }
  }
  
}
