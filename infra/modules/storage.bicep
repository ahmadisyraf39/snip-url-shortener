@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Globally-unique storage account name (lowercase letters/numbers, 3-24 chars)')
param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: true
  }
}

resource enableStaticWebsite 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'enable-static-website'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.60.0'
    retentionInterval: 'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'OnSuccess'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: storageAccountName
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: storageAccount.listKeys().keys[0].value
      }
    ]
    scriptContent: 'az storage blob service-properties update --account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_KEY --static-website --index-document index.html --404-document index.html'
  }
}

output staticWebsiteUrl string = storageAccount.properties.primaryEndpoints.web
output storageAccountName string = storageAccount.name
