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
    appSettings: appSettingsKeyValuePairs
  }
  
}
