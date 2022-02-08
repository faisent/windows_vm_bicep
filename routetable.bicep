// creates a very basic route table

param baseName string
param location string

resource newUDR 'Microsoft.Network/routeTables@2021-05-01' = {
  name: '${baseName}-udr'
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'Internet'
        }
      }
    ]
  }
}

output udrID string = newUDR.id
