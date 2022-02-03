# windows_vm_bicep
Builds a windows VM in Azure using Bicep, connectivity via a Bastion host on the same network.

Modules to create:

Resource Group
Virtual Network with:
  Custom Route tables
  NSGs
  Azure Firewall acting as a DNS proxy
  Bastion ingress
Azure Windows VM (Win10proG2)

Once you're logged into your Azure subscription you can run this with defaults using:

az deployment sub create --template-file windows_vm_builder.bicep -l <some location> 
(note this is the region you're calling the api, not the location of the resources to be built {default:eastus})
