param environmentName string
param location string = resourceGroup().location
param principalId string = ''

// The application frontend
module web './app/web.bicep' = {
  name: 'web-resources'
  params: {
    environmentName: environmentName
    location: location
  }
}

// The application backend
module api './app/api.bicep' = {
  name: 'api-resources'
  params: {
    environmentName: environmentName
    location: location
    applicationInsightsName: monitoring.outputs.APPLICATIONINSIGHTS_NAME
    appServicePlanId: appServicePlan.outputs.AZURE_APP_SERVICE_PLAN_ID
    keyVaultName: keyVault.outputs.AZURE_KEY_VAULT_NAME
    storageAccountName: storage.outputs.NAME
    allowedOrigins: [web.outputs.URI]
  }
}

// The application database
module cosmos './app/db.bicep' = {
  name: 'cosmos-resources'
  params: {
    environmentName: environmentName
    location: location
    keyVaultName: keyVault.outputs.AZURE_KEY_VAULT_NAME
  }
}

// Configure api to use cosmos
module apiCosmosConfig './core/host/appservice-config-cosmos.bicep' = {
  name: 'api-cosmos-config-resources'
  params: {
    appServiceName: api.outputs.NAME
    cosmosDatabaseName: cosmos.outputs.AZURE_COSMOS_DATABASE_NAME
    cosmosConnectionStringKey: cosmos.outputs.AZURE_COSMOS_CONNECTION_STRING_KEY
    cosmosEndpoint: cosmos.outputs.AZURE_COSMOS_ENDPOINT
  }
}

// Backing storage for Azure functions backend API
module storage './core/storage/storage-account.bicep' = {
  name: 'storage-resources'
  params: {
    environmentName: environmentName
    location: location
  }
}

// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan './core/host/appserviceplan-functions.bicep' = {
  name: 'appserviceplan-resources'
  params: {
    environmentName: environmentName
    location: location
  }
}

// Store secrets in a keyvault
module keyVault './core/security/keyvault.bicep' = {
  name: 'keyvault-resources'
  params: {
    environmentName: environmentName
    location: location
    principalId: principalId
  }
}

// Monitor application with Azure Monitor
module monitoring './core/monitor/monitoring.bicep' = {
  name: 'monitoring-resources'
  params: {
    environmentName: environmentName
    location: location
  }
}

output AZURE_COSMOS_ENDPOINT string = cosmos.outputs.AZURE_COSMOS_ENDPOINT
output AZURE_COSMOS_CONNECTION_STRING_KEY string = cosmos.outputs.AZURE_COSMOS_CONNECTION_STRING_KEY
output AZURE_COSMOS_DATABASE_NAME string = cosmos.outputs.AZURE_COSMOS_DATABASE_NAME
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.AZURE_KEY_VAULT_ENDPOINT
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.APPLICATIONINSIGHTS_CONNECTION_STRING
output WEB_URI string = web.outputs.URI
output API_URI string = api.outputs.URI
