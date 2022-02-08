// builds a simple vnet with a bastion subnet and a subnet for IaaS

@description('Base name of the hub-spoke network')
param baseName string = 'seanbot'

@description('Location for this deploy')
param location string = 'eastus'

@description('CIDR of the vnet hub, considering a /24 and use only the first three octets (eg 10.10.10)')
param CIDR string = '10.0.0'

@description('DNS Servers for this vNet')
param dnsServers string = ''

@description('Enables custom dns for this vnet')
param dnsEnabled bool = false

// end intiial parameter add

resource newUDR 'Microsoft.Network/routeTables@2021-05-01' existing = {
  name: '${baseName}-udr'
}

resource IaaSNSG 'Microsoft.Network/networkSecurityGroups@2021-05-01' existing = {
  name: '${baseName}-IaaS-nsg'
}

resource bastionNSG 'Microsoft.Network/networkSecurityGroups@2021-05-01' existing = {
  name: '${baseName}-bastion-nsg'
}

resource NATGW 'Microsoft.Network/natGateways@2021-05-01' existing = {
  name: '${baseName}-nat'
}

resource newvNet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${baseName}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${CIDR}.0/24'
      ]
    }
    dhcpOptions: dnsEnabled ? {
       dnsServers: [
         dnsServers
       ]
    } : {
    }
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '${CIDR}.0/26'
          networkSecurityGroup: {
            id: bastionNSG.id
          }
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '${CIDR}.64/26'
        }
      }
      {
        name: 'IaaS-subnet'
        properties: {
          addressPrefix: '${CIDR}.128/25'
          routeTable: {
            id: newUDR.id
          }
          networkSecurityGroup: {
            id: IaaSNSG.id
          }
          natGateway: {
            id: NATGW.id
          }
        }
      }
    ]
  }
}

output vnetID string = newvNet.id
