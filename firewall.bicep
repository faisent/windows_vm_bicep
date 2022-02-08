param location string
// param clusterName string
// param hubName string
param subnetName string = 'AzureFirewallSubnet'
param baseName string

// @allowed([
//   'dev'
//   'staging'
//   'prod'
// ])
// param environmentName string

// param logAnalytics bool = true
// param logAnalyticsWorkspace string = ''

// @description('An array of firewall application rule collections. https://docs.microsoft.com/en-us/azure/templates/microsoft.network/azurefirewalls?tabs=bicep#azurefirewallapplicationrulecollection')
// param applicationRuleCollections array = []
// @description('An array of firewall network rules collections. https://docs.microsoft.com/en-us/azure/templates/microsoft.network/azurefirewalls?tabs=bicep#azurefirewallnetworkrulecollection')
// param networkRuleCollections array = []

resource firewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${baseName}-vnet/${subnetName}'
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2021-05-01' existing = {
  name: '${baseName}-DNSFWPolicy'
}

resource firewallPublicIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${baseName}-firewall-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2021-02-01' = {
  name: '${baseName}-firewall'
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    firewallPolicy: {
      id: firewallPolicy.id
    }
    threatIntelMode: 'Alert'
    ipConfigurations: [
      {
        name: '${baseName}-firewall'
        properties: {
          publicIPAddress: {
            id: firewallPublicIP.id
          }
          subnet: {
            id: '${firewallSubnet.id}'
          }
        }
      }
    ]
//    applicationRuleCollections: applicationRuleCollections
    // networkRuleCollections: concat([
    //   {
    //     name: 'Default'
    //     properties: {
    //       priority: 100
    //       action: {
    //         type: 'Allow'
    //       }
    //       rules: [
    //         {
    //           name: 'ICMP'
    //           protocols: [
    //             'ICMP'
    //           ]
    //           sourceAddresses: [
    //             '*'
    //           ]
    //           destinationAddresses: [
    //             '*'
    //           ]
    //           destinationPorts: [
    //             '*'
    //           ]
    //         }
    //         {
    //           name: 'Web'
    //           protocols: [
    //             'TCP'
    //           ]
    //           sourceAddresses: [
    //             '*'
    //           ]
    //           destinationAddresses: [
    //             '*'
    //           ]
    //           destinationPorts: [
    //             '443'
    //             '80'
    //           ]
    //         }
    //         {
    //           name: 'NTP'
    //           protocols: [
    //             'UDP'
    //           ]
    //           sourceAddresses: [
    //             '*'
    //           ]
    //           destinationAddresses: [
    //             '*'
    //           ]
    //           destinationPorts: [
    //             '123'
    //           ]
    //         }
    //       ]
    //     }
    //   }
    //   {
    //     name: '200Paul'
    //     properties: {
    //       priority: 200
    //       action: {
    //         type: 'Allow'
    //       }
    //       rules: [
    //         {
    //           name: '200Paul-10_8'
    //           protocols: [
    //             'Any'
    //           ]
    //           sourceAddresses: [
    //             '10.8.0.0/16'
    //           ]
    //           destinationAddresses: [
    //             '*'
    //           ]
    //           destinationPorts: [
    //             '*'
    //           ]
    //         }
    //         {
    //           name: '200Paul-10_192'
    //           protocols: [
    //             'Any'
    //           ]
    //           sourceAddresses: [
    //             '10.192.0.0/16'
    //           ]
    //           destinationAddresses: [
    //             '*'
    //           ]
    //           destinationPorts: [
    //             '*'
    //           ]
    //         }
    //         {
    //           name: '200Paul-10_194'
    //           protocols: [
    //             'Any'
    //           ]
    //           sourceAddresses: [
    //             '10.194.0.0/16'
    //           ]
    //           destinationAddresses: [
    //             '*'
    //           ]
    //           destinationPorts: [
    //             '*'
    //           ]
    //         }
    //       ]
    //     }
    //   }
    // ], networkRuleCollections)
  }
}

/* resource firewallRoutes 'Microsoft.Network/routeTables@2021-02-01' = {
  name: '${clusterName}-${environmentName}-${hubName}-firewall-routes'
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: '${clusterName}-${environmentName}-${hubName}-firewall-routes'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: reference(firewall.id, '2021-02-01').ipConfigurations[0].properties.privateIpAddress
        }
      }
    ]
  }
} */

// resource firewallDiag 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = if(logAnalytics) {
//   name: '${clusterName}-${environmentName}-${hubName}-firewall-diag'
//   scope: firewall
//   properties: {
//     workspaceId: logAnalyticsWorkspace
//     logs: [
//       {
//         category: 'AzureFirewallApplicationRule'
//         enabled: logAnalytics
//       }
//       {
//         category: 'AzureFirewallNetworkRule'
//         enabled: logAnalytics
//       }
//       {
//         category: 'AzureFirewallDnsProxy'
//         enabled: logAnalytics
//       }
//     ]
//   }
// }

output id string = firewall.id
output privateIPAddress string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
output firewallName string = firewall.name
