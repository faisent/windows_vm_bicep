// creates a policy that can be applied to a firewall enabling custom DNS and proxy
// designed to be linked to a base policy which I don't think we're using yet

param baseName string
param location string
param dnsServers string = '10.8.1.60, 10.8.1.61'
// param basePolicyId string 

resource DNSFWPolicy 'Microsoft.Network/firewallPolicies@2021-05-01' = {
  name: '${baseName}-DNSFWPolicy'
  location: location
  properties: {
    // basePolicy: {
    //   id: basePolicyId
    // }
    dnsSettings: {
      enableProxy: true
      servers: [
        dnsServers
      ]
    }
  }
}
