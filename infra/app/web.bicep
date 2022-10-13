param environmentName string
param location string = resourceGroup().location

param serviceName string = 'web'

module web '../core/host/staticwebapp/staticwebapp.bicep' = {
  name: '${serviceName}-staticwebapp-module'
  params: {
    environmentName: environmentName
    location: location
    serviceName: serviceName
  }
}

output WEB_NAME string = web.outputs.name
output WEB_URI string = web.outputs.uri
