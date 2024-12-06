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
    siteConfig: siteConfig
    appSettings: [
      // Transform the key-value pairs into name-value objects
      for key, value in appSettingsKeyValuePairs: {
        name: key
        value: value
      }
    ]
  }
  
}
