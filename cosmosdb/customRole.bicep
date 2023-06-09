param principalId string
param isNew bool = false

@description('管理者に許可する操作権限（Azure RBAC）')
var actions = [
  'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions/*'
  'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments/*'
]

var roleDefinitionName = 'CosmosDB Administrator Custom Role'
var roleDefinitionId = guid(subscription().id, 'role-cosmosdb-administrator-definition')
var roleAssignmentId = guid(roleDefinitionId, principalId)

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = if (isNew) {
  name: roleDefinitionId
  properties: {
    roleName: roleDefinitionName
    description: 'CosmosDB管理者権限ロール'
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
resource existingRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: roleDefinitionId
}
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (isNew) {
  name: roleAssignmentId
  properties: {
    principalId: principalId
    roleDefinitionId: existingRoleDefinition.id
  }
}
