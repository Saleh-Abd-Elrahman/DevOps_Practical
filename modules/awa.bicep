param name string
param location string
param kind string
param serverFarmResourceId string
param siteConfig object
param appSettingsKeyValuePairs object


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
        for key in objectKeys(appSettingsKeyValuePairs): {
          name: key
          value: appSettingsKeyValuePairs[key]
        }
      ]
    }
  }
  
}
