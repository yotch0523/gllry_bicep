param principalId string
param isNew bool = false

@description('管理者に許可する操作権限（Azure RBAC）')
var actions = [
  'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions/*'
  'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments/*'
]

var roleDefinitionName = 'Administrator Custom Role'
var roleDefinitionId = guid(subscription().id, 'role-cosmosdb-administrator-definition')
var roleAssignmentId = guid(roleDefinitionId, principalId)

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = if (isNew) {
  name: roleDefinitionId
  properties: {
    roleName: roleDefinitionName
    description: 'CosmosDBに関する参照権限'
    type: 'customRole'
    permissions: [
      {
        actions: actions
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}
resource existingRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: roleDefinitionId
}
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentId
  properties: {
    principalId: principalId
    roleDefinitionId: existingRole.id
  }
}
