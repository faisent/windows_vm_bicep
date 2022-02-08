// this is an attempt to deal with the race condition of needing a vNet before you can install
// a firewall on it, but wanting to update that vNet to use the firewall as its DNS proxy

param baseName string
param location string

resource azureFirewall 'Microsoft.Network/azureFirewalls@2021-05-01' existing = {
  name: '${baseName}-firewall'
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: '${baseName}-vnet'
}

resource vmvNet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${baseName}-vnet'
  location: location
  properties: {
    dhcpOptions: {
      dnsServers: [
        azureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
      ]
    }
  }
}

