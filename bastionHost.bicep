// sets up a Bastion so that you can access vms from the portal on its vNet without public IPs on each vm or having boot diags

param baseName string
param location string

// get vnet details
resource existingvNet 'Microsoft.Network/virtualnetworks@2015-05-01-preview' existing = {
  name: '${baseName}-vnet'
}

resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  parent: existingvNet
  name: 'AzureBastionSubnet'
}

resource newBastionPublicIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${baseName}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource newBastion 'Microsoft.Network/bastionHosts@2021-05-01' = {
  name: '${baseName}-bastion'
  location: location
  tags: {
  }
  sku: {
    name: 'Basic'
  }
  properties: {
    ipConfigurations: [
      {
 //  don't think this is needed:     id: 'string'
        name: 'bastionIPConfiguration'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: newBastionPublicIP.id
          }
          subnet: {
            id: existingSubnet.id
          }
        }
      }
    ]
  }
}
