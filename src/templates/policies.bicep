targetScope = 'managementGroup'

@metadata({ message: 'The JSON version of this file is programatically generated from Bicep. PLEASE DO NOT UPDATE MANUALLY!!' })
@description('Provide a prefix (max 10 characters, unique at tenant-scope) for the Management Group hierarchy and other resources created as part of an Azure landing zone. DEFAULT VALUE = "alz"')
@maxLength(10)
param topLevelManagementGroupPrefix string = 'alz'

@description('Optionally set the deployment location for policies with Deploy If Not Exists effect. DEFAULT VALUE = "deployment().location"')
param location string = deployment().location

@description('Optionally set the scope for custom Policy Definitions used in Policy Set Definitions (Initiatives). Must be one of \'/\', \'/subscriptions/id\' or \'/providers/Microsoft.Management/managementGroups/id\'. DEFAULT VALUE = \'/providers/Microsoft.Management/managementGroups/\${topLevelManagementGroupPrefix}\'')
param scope string = tenantResourceId('Microsoft.Management/managementGroups', topLevelManagementGroupPrefix)

// Extract the environment name to dynamically determine which policies to deploy.
var cloudEnv = environment().name

// Default deployment locations used in templates
var defaultDeploymentLocationByCloudType = {
  AzureCloud: 'northeurope'
  AzureChinaCloud: 'chinaeast2'
  AzureUSGovernment: 'usgovvirginia'
}

// Used to identify template variables used in the templates for replacement.
var templateVars = {
  scope: '/providers/Microsoft.Management/managementGroups/contoso'
  defaultDeploymentLocation: '"location": "northeurope"'
  localizedDeploymentLocation: '"location": "${defaultDeploymentLocationByCloudType[cloudEnv]}"'
}

var targetDeploymentLocationByCloudType = {
  AzureCloud: location ?? 'northeurope'
  AzureChinaCloud: location ?? 'chinaeast2'
  AzureUSGovernment: location ?? 'usgovvirginia'
}

var deploymentLocation = '"location": "${targetDeploymentLocationByCloudType[cloudEnv]}"'

// The following var contains lists of files containing Policy Definition resources to load, grouped by compatibility with Cloud.
// To get a full list of Azure clouds, use the az cli command "az cloud list --output table"
// We use loadTextContent instead of loadJsonContent  as this allows us to perform string replacement operations against the imported templates.
var loadPolicyDefinitions = {
  All: [
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Append-AppService-httpsonly.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Append-AppService-latestTLS.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Append-KV-SoftDelete.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Append-Redis-disableNonSslPort.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Append-Redis-sslEnforcement.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Audit-Disks-UnusedResourcesCostOptimization.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Audit-PublicIpAddresses-UnusedResourcesCostOptimization.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Audit-ServerFarms-UnusedResourcesCostOptimization.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Audit-AzureHybridBenefit.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-AppGW-Without-WAF.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-AppServiceApiApp-http.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-AppServiceFunctionApp-http.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-AppServiceWebApp-http.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-MySql-http.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-PostgreSql-http.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Private-DNS-Zones.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-PublicEndpoint-MariaDB.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-PublicIP.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-RDP-From-Internet.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-MgmtPorts-From-Internet.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Redis-http.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Sql-minTLS.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-SqlMi-minTLS.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Storage-minTLS.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Storage-SFTP.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Subnet-Without-Nsg.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Subnet-Without-Penp.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Subnet-Without-Udr.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-UDR-With-Specific-NextHop.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-VNET-Peer-Cross-Sub.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-VNET-Peering-To-Non-Approved-VNETs.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-VNet-Peering.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-StorageAccount-CustomDomain.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-FileServices-InsecureKerberos.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-FileServices-InsecureSmbChannel.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-FileServices-InsecureSmbVersions.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-FileServices-InsecureAuth.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-ASC-SecurityContacts.json') // Only difference is hard-coded template deployment location (handled by this template)
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Custom-Route-Table.json') // Equivalent to "Deploy-Default-Udr" in AzureChinaCloud and AzureUSGovernment but with differences
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-DDoSProtection.json') // Only difference is hard-coded template deployment location (handled by this template)
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-AA.json') // Additional AuditEvent category on L159..L162 needs validating for AzureChinaCloud and AzureUSGovernment
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ACI.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ACR.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-AnalysisService.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ApiForFHIR.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-APIMgmt.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ApplicationGateway.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Bastion.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-CDNEndpoints.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-CognitiveServices.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-CosmosDB.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Databricks.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-DataExplorerCluster.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-DataFactory.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-DLAnalytics.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-EventGridSub.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-EventGridSystemTopic.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-EventGridTopic.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ExpressRoute.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Firewall.json') // Only difference is hard-coded template deployment location (handled by this template)
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-FrontDoor.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Function.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-HDInsight.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-iotHub.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-LoadBalancer.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-LogAnalytics.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-LogicAppsISE.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MariaDB.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MediaService.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MlWorkspace.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MySQL.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-NetworkSecurityGroups.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-NIC.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-PostgreSQL.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-PowerBIEmbedded.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-RedisCache.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Relay.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SignalR.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SQLElasticPools.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SQLMI.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-TimeSeriesInsights.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-TrafficManager.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VirtualNetwork.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VM.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VMSS.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VNetGW.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WebServerFarm.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Website.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WVDAppGroup.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WVDHostPools.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WVDWorkspace.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-FirewallPolicy.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-MySQL-sslEnforcement.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Nsg-FlowLogs-to-LA.json') // Only difference is hard-coded template deployment location (handled by this template)
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Nsg-FlowLogs.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-PostgreSQL-sslEnforcement.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Sql-AuditingSettings.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-SQL-minTLS.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Sql-SecurityAlertPolicies.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Sql-Tde.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Sql-vulnerabilityAssessments.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Sql-vulnerabilityAssessments_20230706.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-SqlMi-minTLS.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Storage-sslEnforcement.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-VNET-HubSpoke.json') // Only difference is hard-coded template deployment location (handled by this template)
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Vm-autoShutdown.json') 
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Windows-DomainJoin.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VWanS2SVPNGW.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Audit-PrivateLinkDnsZones.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/DenyAction-DiagnosticLogs.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/DenyAction-ActivityLogs.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-UserAssignedManagedIdentity-VMInsights.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-MDFC-Arc-SQL-DCR-Association.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-MDFC-Arc-SQL-DefenderSQL-DCR.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-MDFC-SQL-AMA.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-MDFC-SQL-DefenderSQL-DCR.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-MDFC-SQL-DefenderSQL.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-APIM-TLS.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-AppGw-Without-Tls.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-AppService-without-BYOC.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-AzFw-Without-Policy.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-CognitiveServices-NetworkAcls.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-CognitiveServices-Resource-Kinds.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-CognitiveServices-RestrictOutboundNetworkAccess.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-EH-MINTLS.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-EH-Premium-CMK.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-LogicApp-Public-Network.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-LogicApps-Without-Https.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Service-Endpoints.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Storage-ContainerDeleteRetentionPolicy.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Storage-CopyScope.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Storage-CorsRules.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Storage-LocalUser.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Storage-NetworkAclsBypass.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Storage-NetworkAclsVirtualNetworkRules.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Storage-ResourceAccessRulesResourceId.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Storage-ResourceAccessRulesTenantId.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Storage-ServicesEncryption.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-LogicApp-TLS.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Modify-NSG.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Modify-UDR.json') // FSI specific policy
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Private-DNS-Generic.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/DenyAction-DeleteResources.json')
  ]
  AzureCloud: [
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Audit-MachineLearning-PrivateEndpointId.json') // Needs validating in AzureChinaCloud and AzureUSGovernment
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-AA-child-resources.json') // Needs validating in AzureChinaCloud (already used in AzureUSGovernment)
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Databricks-NoPublicIp.json') // Needs validating in AzureChinaCloud and AzureUSGovernment
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Databricks-Sku.json') // Needs validating in AzureChinaCloud and AzureUSGovernment
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-Databricks-VirtualNetwork.json') // Needs validating in AzureChinaCloud and AzureUSGovernment
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-MachineLearning-Aks.json') // Needs validating in AzureChinaCloud and AzureUSGovernment
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-MachineLearning-Compute-SubnetId.json') // Needs validating in AzureChinaCloud and AzureUSGovernment
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-MachineLearning-Compute-VmSize.json') // Needs validating in AzureChinaCloud and AzureUSGovernment
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-MachineLearning-ComputeCluster-RemoteLoginPortPublicAccess.json') // Needs validating in AzureChinaCloud and AzureUSGovernment
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-MachineLearning-ComputeCluster-Scale.json') // Needs validating in AzureChinaCloud and AzureUSGovernment
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-MachineLearning-HbiWorkspace.json') // Needs validating in AzureChinaCloud and AzureUSGovernment
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-MachineLearning-PublicAccessWhenBehindVnet.json') // Needs validating in AzureChinaCloud and AzureUSGovernment
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-MachineLearning-PublicNetworkAccess.json') // Needs validating in AzureChinaCloud and AzureUSGovernment
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Budget.json') // Needs validating in AzureChinaCloud (already used in AzureUSGovernment)
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-AVDScalingPlans.json') // No obvious reason for exclusion from AzureChinaCloud and AzureUSGovernment, impacts "Deploy-Diagnostics-LogAnalytics" Policy Set Definition
  ]
  AzureChinaCloud: [
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-AFSPaasPublicIP.AzureChinaCloud.json') // Used by "Deny-PublicPaaSEndpoints" Policy Set Definition to replace missing built-in Policy Definition in AzureChinaCloud
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-KeyVaultPaasPublicIP.AzureChinaCloud.json') // Used by "Deny-PublicPaaSEndpoints" Policy Set Definition to replace missing built-in Policy Definition in AzureChinaCloud
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-ActivityLogs-to-LA-workspace.AzureChinaCloud.json') // Need to validate whether built-in is still missing in AzureChinaCloud
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Default-Udr.AzureChinaCloud.json') // Equivalent to "Deploy-Custom-Route-Table" in AzureCloud but with differences (should remove once "Deploy-Custom-Route-Table" is validated in AzureChinaCloud)
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-MySQLCMKEffect.AzureChinaCloud.json') // Used by "Enforce-Encryption-CMK" Policy Set Definition to replace missing built-in Policy Definition in AzureChinaCloud
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-PostgreSQLCMKEffect.AzureChinaCloud.json') // Used by "Enforce-Encryption-CMK" Policy Set Definition to replace missing built-in Policy Definition in AzureChinaCloud
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Private-DNS-Azure-File-Sync.AzureChinaCloud.json') // Used by "Deploy-Private-DNS-Zones" Policy Set Definition to replace missing built-in Policy Definition in AzureChinaCloud
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Private-DNS-Azure-KeyVault.AzureChinaCloud.json') // Used by "Deploy-Private-DNS-Zones" Policy Set Definition to replace missing built-in Policy Definition in AzureChinaCloud
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Private-DNS-Azure-Web.AzureChinaCloud.json') // Used by "Deploy-Private-DNS-Zones" Policy Set Definition to replace missing built-in Policy Definition in AzureChinaCloud
  ]
  AzureUSGovernment: [
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deny-AA-child-resources.json') // Only difference is hard-coded template deployment location (handled by this template) + not tested in AzureChinaCloud
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Budget.json') // Only difference is hard-coded template deployment location (handled by this template) + not tested in AzureChinaCloud
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/Deploy-Default-Udr.AzureUSGovernment.json') // Equivalent to "Deploy-Custom-Route-Table" in AzureCloud but with differences (should remove once "Deploy-Custom-Route-Table" is validated in AzureUSGovernment)
  ]
}

// The following vars are used to manipulate the imported Policy Definitions to replace deployment location values
// Needs a double replace to handle updates in both templates for All clouds, and localized templates
var processPolicyDefinitionsAll = [for content in loadPolicyDefinitions.All: replace(replace(content, templateVars.defaultDeploymentLocation, deploymentLocation), templateVars.localizedDeploymentLocation, deploymentLocation)]
var processPolicyDefinitionsAzureCloud = [for content in loadPolicyDefinitions.AzureCloud: replace(replace(content, templateVars.defaultDeploymentLocation, deploymentLocation), templateVars.localizedDeploymentLocation, deploymentLocation)]
var processPolicyDefinitionsAzureChinaCloud = [for content in loadPolicyDefinitions.AzureChinaCloud: replace(replace(content, templateVars.defaultDeploymentLocation, deploymentLocation), templateVars.localizedDeploymentLocation, deploymentLocation)]
var processPolicyDefinitionsAzureUSGovernment = [for content in loadPolicyDefinitions.AzureUSGovernment: replace(replace(content, templateVars.defaultDeploymentLocation, deploymentLocation), templateVars.localizedDeploymentLocation, deploymentLocation)]


// The following vars are used to convert the imported Policy Definitions into objects from JSON
var policyDefinitionsAll = [for content in processPolicyDefinitionsAll: json(content)]
var policyDefinitionsAzureCloud = [for content in processPolicyDefinitionsAzureCloud: json(content)]
var policyDefinitionsAzureChinaCloud = [for content in processPolicyDefinitionsAzureChinaCloud: json(content)]
var policyDefinitionsAzureUSGovernment = [for content in processPolicyDefinitionsAzureUSGovernment: json(content)]


// The following var is used to compile the required Policy Definitions into a single object
var policyDefinitionsByCloudType = {
  All: policyDefinitionsAll
  AzureCloud: policyDefinitionsAzureCloud
  AzureChinaCloud: policyDefinitionsAzureChinaCloud
  AzureUSGovernment: policyDefinitionsAzureUSGovernment
}

// The following var is used to extract the Policy Definitions into a single list for deployment
// This will contain all policy definitions classified as available for All cloud environments, and those for the current cloud environment
var policyDefinitions = concat(policyDefinitionsByCloudType.All, policyDefinitionsByCloudType[cloudEnv])

// Create the Policy Definitions as needed for the target cloud environment
resource PolicyDefinitions 'Microsoft.Authorization/policyDefinitions@2020-09-01' = [for policy in policyDefinitions: {
  name: policy.name
  properties: {
    description: policy.properties.description
    displayName: policy.properties.displayName
    metadata: policy.properties.metadata
    mode: policy.properties.mode
    parameters: policy.properties.parameters
    policyType: policy.properties.policyType
    policyRule: policy.properties.policyRule
  }
}]

output policyDefinitionNames array = [for policy in policyDefinitions: policy.name]
