// simple resource group builder

targetScope = 'subscription'

@description('The location of this RG')
param location string = 'eastus'

@description('The name of this resource group')
param rgName string = 'seanbot-testing-rg'

resource newRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
  tags: {
  }
}

output resourceGroupBuild string = newRG.name
