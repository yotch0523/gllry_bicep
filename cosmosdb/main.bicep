@description('リソースのリージョン')
param location string = resourceGroup().location
@description('Cosmos DBのアカウント名（44文字以内）')
param accountName string
@description('割り当て対象のサービスプリンシパルID(GUID形式)')
param principalId string
@description('Azure Active DirectoryのオブジェクトID(GUID形式)')
param administratorPrincipalId string

param isNew bool = false

var locations = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = if (isNew) {
  name: accountName
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    enableFreeTier: false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: locations
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
}

module customRole './customRole.bicep' = {
  name: 'customRoleDeploy'
  params : {
    principalId: administratorPrincipalId
  }
}
module servicePrincipalCustomRole './servicePrincipalCustomRole.bicep' = {
  name: 'servicePrincipalCustomRoleDeploy'
  params: {
    accountName: accountName
    principalId: principalId
  }
}
