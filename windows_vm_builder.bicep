// intent is to have a windows VM in Azure with a bastion connection (instead of a public ip) that can be spun up and/or torn down as needed

// scope to the subscription

targetScope = 'subscription'

@description('Basename of the resources to build')
param baseName string = 'seanbot-testing'

@description('Location of the deploy')
param location string = 'eastus'

@description('Network CIDR block - defaults to 10.0.0.0/24.  Basically the first three octets, nothing fancy here')
param CIDR string = '10.0.0'

@description('Tells the vnet creation module to enable custom DNS')
param dnsEnabled bool = false

// first we need a resource group to deploy into

module newResourceGroup 'modules/resourceGroup.bicep' = {
  name: '${baseName}-rg'
  params: {
    location: location
    rgName: '${baseName}-rg'
  }
}


// some routes

module newUDR 'modules/routetable.bicep' = {
  name: '${baseName}-udr'
  scope: resourceGroup(newResourceGroup.name)
  params: {
    location: location
    baseName: baseName
  }
}

// some security

module newNSG 'modules/networkSecurityGroup.bicep' = {
  name: '${baseName}-nsgs'
  scope: resourceGroup(newResourceGroup.name)
  params: {
    location: location
    baseName: baseName
  }
}

// a NAT for outbound egress 

module NATGateway 'modules/azureNat.bicep' = {
  name: '${baseName}-nat'
  scope: resourceGroup(newResourceGroup.name)
  params: {
    location: location
    baseName: baseName
  }
}

// next we need a vnet

module vmvNet 'modules/vnet.bicep' = {
  name: '${baseName}-vnet'
  scope: resourceGroup(newResourceGroup.name)
  params: {
    baseName: baseName
    location: location
    CIDR: CIDR
    dnsEnabled: dnsEnabled

  }
  dependsOn: [
    newResourceGroup
    newNSG
    NATGateway
  ]
}

// now we need a bastion service

module newBastion 'modules/bastionHost.bicep' = {
  name: '${baseName}-bastion'
  scope: resourceGroup(newResourceGroup.name)
  dependsOn: [
    vmvNet
  ]
  params: {
    baseName: baseName
    location: location
  }
}

// finally a VM

module newWindowsVM 'modules/windowsVM.bicep' = {
  name: '${baseName}-winvm'
  scope: resourceGroup(newResourceGroup.name)
  params: {
    baseName: baseName
    location: location
  }
  dependsOn: [
    newBastion
  ]
}

// testing creating firewalls and DNS policies here

// module firewallPolicy 'modules/dnsFirewallPolicy.bicep' = {
//   name: '${baseName}-DNSFWPolicy'
//   scope: resourceGroup(newResourceGroup.name)
//   params: {
//     baseName: baseName
//     location: location
//     dnsServers: '168.63.129.16'
// //    basePolicyId: ''
//   }
//   dependsOn: [
//     newResourceGroup
//   ]
// }

// module azureFirewall 'modules/firewall.bicep' = {
//   name: '${baseName}-Firewall'
//   scope: resourceGroup(newResourceGroup.name)
//   params: {
//     baseName: baseName
//     location: location
//   }
//   dependsOn: [
//     firewallPolicy
//     vmvNet
//   ]
// }

// module updatevNetDNS 'modules/vnet.bicep' = {
//   name: '${baseName}-dnsupdater'
//   scope: resourceGroup(newResourceGroup.name)
//   params: {
//     baseName: baseName
//     location: location
//     CIDR: CIDR
//     dnsServers: azureFirewall.outputs.privateIPAddress
//     dnsEnabled: true
//   }
//   dependsOn: [
//     vmvNet
//     azureFirewall
//   ]
// }
