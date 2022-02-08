// this should drop a new windows vm into the IaaS-subnet and allow access via Bastion

param baseName string
param location string
param adminAccount string
param adminPassword string

resource virtualNetwork 'Microsoft.Network/virtualnetworks@2015-05-01-preview' existing = {
  name: '${baseName}-vnet'
}

resource IaaSSubnet 'Microsoft.Network/virtualnetworks/subnets@2015-06-15' existing = {
  parent: virtualNetwork
  name: 'IaaS-subnet'
}

resource newWindowsVM 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: '${baseName}-winvm'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v3'
    }
    networkProfile: {
      networkApiVersion: '2020-11-01'
      networkInterfaceConfigurations: [
        {
          name: 'interface-1'
          properties: {
            deleteOption: 'Delete'
            ipConfigurations: [
              {
                name: 'ipconfig-1'
                properties: {
                  primary: true
                  privateIPAddressVersion: 'IPv4'
                  subnet: {
                    id: IaaSSubnet.id
                  }
                }
              }
            ]
            primary: true
          }
        }
      ]
    }
    osProfile: {
      computerName: 'riskiqbi'
      adminUsername: adminAccount
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        offer: 'Windows-10'
        publisher: 'MicrosoftWindowsDesktop'
        sku: '21h1-pro-g2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        deleteOption: 'Delete'
        diskSizeGB: 127
      }
    }
  }
}
