@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Base name used to derive resource names (keep it short - 8 characters or fewer - to leave room for Azure Storage\'s 24-character account name limit)')
param baseName string = 'snipiac'

var uniqueSuffix = take(uniqueString(resourceGroup().id), 6)
var storageAccountName = '${baseName}store${uniqueSuffix}'
var funcStorageAccountName = '${baseName}funcstore${uniqueSuffix}'
var functionAppName = '${baseName}-api-${uniqueSuffix}'
var cosmosAccountName = '${baseName}-cosmos-${uniqueSuffix}'

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
