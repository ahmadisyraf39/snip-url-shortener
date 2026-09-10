@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Base name used to derive resource names (lowercase letters/numbers only)')
param baseName string = 'snipiac'

var storageAccountName = '${baseName}store3939'
var funcStorageAccountName = '${baseName}funcstore3939'
var functionAppName = '${baseName}-api-3939'
var cosmosAccountName = '${baseName}-cosmos-3939'

module storage 'modules/storage.bicep' = {
  name: 'storage-deploy'
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}

module cosmos 'modules/cosmos.bicep' = {
  name: 'cosmos-deploy'
  params: {
    location: location
    cosmosAccountName: cosmosAccountName
  }
}

module functionApp 'modules/functionapp.bicep' = {
  name: 'functionapp-deploy'
  params: {
    location: location
    functionAppName: functionAppName
    funcStorageAccountName: funcStorageAccountName
    staticWebsiteUrl: storage.outputs.staticWebsiteUrl
    cosmosDbAccountEndpoint: cosmos.outputs.cosmosAccountEndpoint
  }
}

module cosmosRbac 'modules/cosmos-rbac.bicep' = {
  name: 'cosmos-rbac-deploy'
  params: {
    cosmosAccountName: cosmos.outputs.cosmosAccountName
    principalId: functionApp.outputs.functionAppPrincipalId
  }
}

output staticWebsiteUrl string = storage.outputs.staticWebsiteUrl
output functionAppHostName string = functionApp.outputs.functionAppHostName
output functionAppName string = functionApp.outputs.functionAppName
output cosmosAccountName string = cosmos.outputs.cosmosAccountName
