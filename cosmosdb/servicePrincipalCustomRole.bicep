@description('Cosmos DBのアカウント名（44文字以内）')
param accountName string
@description('Azure Active DirectoryのオブジェクトID(GUID形式)')
param principalId string
@description('ロール定義を新規にデプロイするかどうか')
param isNew bool = true

var roleDefinitionName = 'Read and Write Role'
var roleDefinitionId = guid(databaseAccount.id, 'sql-role-definition-for-api')
var roleAssignmentId = guid(roleDefinitionId, principalId)

@description('対象のプリンシパルに許可する操作権限')
var dataActions = [
  'Microsoft.DocumentDB/databaseAccounts/readMetadata'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed'
]

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: accountName
}
resource sqlRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2023-04-15' = if (isNew) {
  parent: databaseAccount
  name: roleDefinitionId
  properties: {
    roleName: roleDefinitionName
    type: 'CustomRole'
    assignableScopes: [
      databaseAccount.id
    ]
    permissions: [
      {
        dataActions: dataActions
      }
    ]
  }
}

resource existingRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2023-04-15' existing = {
  parent: databaseAccount
  name: roleDefinitionId
}
resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-04-15' = if (isNew) {
  parent: databaseAccount
  name: roleAssignmentId
  properties: {
    roleDefinitionId: existingRoleDefinition.id
    principalId: principalId
    scope: databaseAccount.id
  }
}
