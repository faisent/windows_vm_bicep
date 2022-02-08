// builds an outbound NAT service for vm connectivity to the Internet

param baseName string
param location string

resource NATIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${baseName}-nat-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource AzureNAT 'Microsoft.Network/natGateways@2021-05-01' = {
  name: '${baseName}-nat'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIpAddresses: [
      {
        id: NATIP.id
      }
    ]
  }
}
