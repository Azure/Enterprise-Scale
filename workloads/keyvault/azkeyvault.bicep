@description('Specifies the name of the KeyVault, this value must be globally unique.')
param vaultName string = 'keyvault-${uniqueString(resourceGroup().id)}'

@description('Specifies the Azure location where the key vault should be created.')
param location string = resourceGroup().location

@description('Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param enabledForDeployment bool = false

@description('Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enabledForDiskEncryption bool = false

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enabledForTemplateDeployment bool = false

@description('Property specifying whether protection against purge is enabled for this vault.  This property does not accept false but enabled here to allow for this to be optional, if false, the property will not be set.')
param enablePurgeProtection bool = true

@description('Property that controls how data actions are authorized. When true, the key vault will use Role Based Access Control (RBAC) for authorization of data actions, and the access policies specified in vault properties will be ignored.')
param enableRbacAuthorization bool = false

@description('Property to specify whether the \'soft delete\' functionality is enabled for this key vault. If it\'s not set to any value(true or false) when creating new key vault, it will be set to true by default. Once set to true, it cannot be reverted to false.')
param enableSoftDelete bool = true

@minValue(7)
@maxValue(90)
@description('softDelete data retention days, only used if enableSoftDelete is true. It accepts >=7 and <=90.')
param softDeleteRetentionInDays int = 7

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

@allowed([
  'None'
  'AzureServices'
])
@description('Tells what traffic can bypass network rules. This can be \'AzureServices\' or \'None\'. If not specified the default is \'AzureServices\'.')
param networkRuleBypassOptions string = 'AzureServices'

@allowed([
  'Allow'
  'Deny'
])
@description('The default action when no rule from ipRules and from virtualNetworkRules match. This is only used after the bypass property has been evaluated.')
param NetworkRuleAction string = 'Allow'

@description('An array of IPv4 addresses or rangea in CIDR notation, e.g. \'124.56.78.91\' (simple IP address) or \'124.56.78.0/24\' (all addresses that start with 124.56.78).')
param ipRules array = []

@description('An complex object array that contains the complete definition of the access policy.')
param accessPolicies array = []

@description('An array for resourceIds for the virtualNetworks allowed to access the vault.')
param virtualNetworkRules array = []

@allowed([
  'Standard'
  'Premium'
])
@description('Specifies whether the key vault is a standard vault or a premium vault.')
param skuName string = 'Standard'

@description('Provide the resourceId for the application centric Log Analytics workspace if you want to enable diagnostics for the KeyVault. If no resourceId is provided, the resource will be ignored.')
param logAnalyticsResourceId string = ''

@description('Tags to be assigned to the KeyVault.')
param tags object = {}

resource vaultName_resource 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: vaultName
  location: location
  tags: tags
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: skuName
    }
    accessPolicies: [for item in accessPolicies: {
      tenantId: item.tenantId
      objectId: item.objectId
      permissions: item.permissions
    }]
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: (enableSoftDelete ? softDeleteRetentionInDays : json('null'))
    enableRbacAuthorization: enableRbacAuthorization
    enablePurgeProtection: (enablePurgeProtection ? enablePurgeProtection : json('null'))
    networkAcls: {
      bypass: networkRuleBypassOptions
      defaultAction: NetworkRuleAction
      ipRules: [for item in ipRules: {
        value: item
      }]
      virtualNetworkRules: [for item in virtualNetworkRules: {
        id: item
      }]
    }
  }
}

resource vaultName_Microsoft_Insights_diagSetting 'Microsoft.KeyVault/vaults/providers/diagnosticSettings@2017-05-01-preview' = if (!empty(logAnalyticsResourceId)) {
  name: '${vaultName}/Microsoft.Insights/diagSetting'
  location: location
  properties: {
    workspaceId: logAnalyticsResourceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
        timeGrain: null
      }
    ]
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
  }
  dependsOn: []
}

output vaultName string = vaultName
output vaultResourceGroup string = resourceGroup().name
output location string = location
