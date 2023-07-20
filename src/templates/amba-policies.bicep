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

// Unable to do the following commented out approach due to the error "The value must be a compile-time constant.bicep(BCP032)"
// See: https://github.com/Azure/bicep/issues/3816#issuecomment-1191230215

// The following vars are used to load the list of Policy Definitions to import
// var listPolicyDefinitionsAll = loadJsonContent('../data/policyDefinitions.All.json')
// var listPolicyDefinitionsAzureCloud = loadJsonContent('../data/policyDefinitions.AzureCloud.json')
// var listPolicyDefinitionsAzureChinaCloud = loadJsonContent('../data/policyDefinitions.AzureChinaCloud.json')
// var listPolicyDefinitionsAzureUSGovernment = loadJsonContent('../data/policyDefinitions.AzureUSGovernment.json')

// The following vars are used to load the list of Policy Set Definitions to import
// var listPolicySetDefinitionsAll = loadJsonContent('../data/policySetDefinitions.All.json')
// var listPolicySetDefinitionsAzureCloud = loadJsonContent('../data/policySetDefinitions.AzureCloud.json')
// var listPolicySetDefinitionsAzureChinaCloud = loadJsonContent('../data/policySetDefinitions.AzureChinaCloud.json')
// var listPolicySetDefinitionsAzureUSGovernment = loadJsonContent('../data/policySetDefinitions.AzureUSGovernment.json')

// The following vars are used to load the list of Policy Definitions to import
// var loadPolicyDefinitionsAll = [for item in listPolicyDefinitionsAll: loadTextContent(item)]
// var loadPolicyDefinitionsAzureCloud = [for item in listPolicyDefinitionsAzureCloud: loadTextContent(item)]
// var loadPolicyDefinitionsAzureChinaCloud = [for item in listPolicyDefinitionsAzureChinaCloud: loadTextContent(item)]
// var loadPolicyDefinitionsAzureUSGovernment = [for item in listPolicyDefinitionsAzureUSGovernment: loadTextContent(item)]

// The following vars are used to load the list of Policy Set Definitions to import
// var loadPolicySetDefinitionsAll = [for item in listPolicySetDefinitionsAll: loadTextContent(item)]
// var loadPolicySetDefinitionsAzureCloud = [for item in listPolicySetDefinitionsAzureCloud: loadTextContent(item)]
// var loadPolicySetDefinitionsAzureChinaCloud = [for item in listPolicySetDefinitionsAzureChinaCloud: loadTextContent(item)]
// var loadPolicySetDefinitionsAzureUSGovernment = [for item in listPolicySetDefinitionsAzureUSGovernment: loadTextContent(item)]

// The following var contains lists of files containing Policy Definition resources to load, grouped by compatibility with Cloud.
// To get a full list of Azure clouds, use the az cli command "az cloud list --output table"
// We use loadTextContent instead of loadJsonContent  as this allows us to perform string replacement operations against the imported templates.
var loadPolicyDefinitions = {
  All: [
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-aa_totaljob_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-activitylog-AzureFirewall-Del.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-activitylog-KeyVault-Del.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-activitylog-LAWorkspace-Del.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-activitylog-LAWorkspace-ReGen.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-activitylog-NSG-Del.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-activitylog-ResourceHealth-UnHealthly-alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-activitylog-RouteTable-Update.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-activitylog-ServiceHealth-Health.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-activitylog-ServiceHealth-Incident.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-activitylog-ServiceHealth-Maintenance.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-activitylog-ServiceHealth-Security.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-activitylog-VPNGate-Del.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-afw_firewallhealth_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-afw_snatportutilization_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-alertprocessingrule-deploy.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-ercir_arpavailability_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-ercir_bgpavailability_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-ercir_qosdropsbitsin_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-ercir_qosdropsbitsout_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-erg_bitsinpersecond_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-erg_bitsoutpersecond_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-erg_expressroutecpuutilization_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-kv_availability_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-kv_capacity_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-kv_latency_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-kv_requests_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-pdnsz_capacityutilization_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-pdnsz_queryvolume_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-pdnsz_recordsetcapacity_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-pdnsz_registrationcapacityutilization_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-pip_bytesinddosattack_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-pip_ddosattack_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-pip_packetsinddos_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-pip_vipavailability_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-rv_backuphealth_monitor.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-sa_availability_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vm_availablememory_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vm-dataDiskreadLatency_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vm-dataDiskSpace_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vm-dataDiskwriteLatency_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vm-HeartBeat_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vm-HeartBeatAlertRG.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vm-NetworkIn_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vm-NetworkOut_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vm-OSDiskreadLatency_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vm-OSDiskSpace_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vm-OSDiskwriteLatency_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vm-PercentCPU_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vm-PercentMemory_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vnet_ddosattack_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vnetg_bandwidthutilization_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vnetg_egress_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vnetg_egresspacketdropcount_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vnetg_egresspacketdropmismatch_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vnetg_expressroutebitspersecond_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vnetg_expressroutecpuutilization_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vnetg_ingress_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vnetg_ingresspacketdropcount_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vnetg_ingresspacketdropmismatch_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vpng_bandwidthutilization_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vpng_bgppeerstatus_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vpng_egress_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vpng_egresspacketdropcount_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vpng_egresspacketdropmismatch_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vpng_ingress_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vpng_ingresspacketdropcount_alert.json')
    loadTextContent('../resources/Microsoft.Authorization/policyDefinitions/amba/deploy-vpng_ingresspacketdropmismatch_alert.json')
  ]
  AzureCloud: []
  AzureChinaCloud: []
  AzureUSGovernment: []
}

// The following var contains lists of files containing Policy Set Definition (Initiative) resources to load, grouped by compatibility with Cloud.
// To get a full list of Azure clouds, use the az cli command "az cloud list --output table"
// We use loadTextContent instead of loadJsonContent  as this allows us to perform string replacement operations against the imported templates.
var loadPolicySetDefinitions = {
  All: [
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/amba/Deploy-Connectivity-Alerts.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/amba/Deploy-Identity-Alerts.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/amba/Deploy-LandingZone-Alerts.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/amba/Deploy-Management-Alerts.json')
    loadTextContent('../resources/Microsoft.Authorization/policySetDefinitions/amba/Deploy-ServiceHealth-Alerts.json')
  ]
  AzureCloud: []
  AzureChinaCloud: []
  AzureUSGovernment: []
}

// The following vars are used to manipulate the imported Policy Definitions to replace deployment location values
// Needs a double replace to handle updates in both templates for All clouds, and localized templates
var processPolicyDefinitionsAll = [for content in loadPolicyDefinitions.All: replace(replace(content, templateVars.defaultDeploymentLocation, deploymentLocation), templateVars.localizedDeploymentLocation, deploymentLocation)]
var processPolicyDefinitionsAzureCloud = [for content in loadPolicyDefinitions.AzureCloud: replace(replace(content, templateVars.defaultDeploymentLocation, deploymentLocation), templateVars.localizedDeploymentLocation, deploymentLocation)]
var processPolicyDefinitionsAzureChinaCloud = [for content in loadPolicyDefinitions.AzureChinaCloud: replace(replace(content, templateVars.defaultDeploymentLocation, deploymentLocation), templateVars.localizedDeploymentLocation, deploymentLocation)]
var processPolicyDefinitionsAzureUSGovernment = [for content in loadPolicyDefinitions.AzureUSGovernment: replace(replace(content, templateVars.defaultDeploymentLocation, deploymentLocation), templateVars.localizedDeploymentLocation, deploymentLocation)]

// The following vars are used to manipulate the imported Policy Set Definitions to replace Policy Definition scope values
var processPolicySetDefinitionsAll = [for content in loadPolicySetDefinitions.All: replace(content, templateVars.scope, scope)]
var processPolicySetDefinitionsAzureCloud = [for content in loadPolicySetDefinitions.AzureCloud: replace(content, templateVars.scope, scope)]
var processPolicySetDefinitionsAzureChinaCloud = [for content in loadPolicySetDefinitions.AzureChinaCloud: replace(content, templateVars.scope, scope)]
var processPolicySetDefinitionsAzureUSGovernment = [for content in loadPolicySetDefinitions.AzureUSGovernment: replace(content, templateVars.scope, scope)]

// The following vars are used to convert the imported Policy Definitions into objects from JSON
var policyDefinitionsAll = [for content in processPolicyDefinitionsAll: json(content)]
var policyDefinitionsAzureCloud = [for content in processPolicyDefinitionsAzureCloud: json(content)]
var policyDefinitionsAzureChinaCloud = [for content in processPolicyDefinitionsAzureChinaCloud: json(content)]
var policyDefinitionsAzureUSGovernment = [for content in processPolicyDefinitionsAzureUSGovernment: json(content)]

// The following vars are used to convert the imported Policy Set Definitions into objects from JSON
var policySetDefinitionsAll = [for content in processPolicySetDefinitionsAll: json(content)]
var policySetDefinitionsAzureCloud = [for content in processPolicySetDefinitionsAzureCloud: json(content)]
var policySetDefinitionsAzureChinaCloud = [for content in processPolicySetDefinitionsAzureChinaCloud: json(content)]
var policySetDefinitionsAzureUSGovernment = [for content in processPolicySetDefinitionsAzureUSGovernment: json(content)]

// The following var is used to compile the required Policy Definitions into a single object
var policyDefinitionsByCloudType = {
  All: policyDefinitionsAll
  AzureCloud: policyDefinitionsAzureCloud
  AzureChinaCloud: policyDefinitionsAzureChinaCloud
  AzureUSGovernment: policyDefinitionsAzureUSGovernment
}

// The following var is used to compile the required Policy Definitions into a single object
var policySetDefinitionsByCloudType = {
  All: policySetDefinitionsAll
  AzureCloud: policySetDefinitionsAzureCloud
  AzureChinaCloud: policySetDefinitionsAzureChinaCloud
  AzureUSGovernment: policySetDefinitionsAzureUSGovernment
}

// The following var is used to extract the Policy Definitions into a single list for deployment
// This will contain all policy definitions classified as available for All cloud environments, and those for the current cloud environment
var policyDefinitions = concat(policyDefinitionsByCloudType.All, policyDefinitionsByCloudType[cloudEnv])

// The following var is used to extract the Policy Set Definitions into a single list for deployment
// This will contain all policy set definitions classified as available for All cloud environments, and those for the current cloud environment
var policySetDefinitions = concat(policySetDefinitionsByCloudType.All, policySetDefinitionsByCloudType[cloudEnv])

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

// Create the Policy Definitions as needed for the target cloud environment
// Depends on Policy Definitons to ensure they exist before creating dependent Policy Set Definitions (Initiatives)
resource PolicySetDefinitions 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = [for policy in policySetDefinitions: {
  dependsOn: [
    PolicyDefinitions
  ]
  name: policy.name
  properties: {
    description: policy.properties.description
    displayName: policy.properties.displayName
    metadata: policy.properties.metadata
    parameters: policy.properties.parameters
    policyType: policy.properties.policyType
    policyDefinitions: policy.properties.policyDefinitions
    policyDefinitionGroups: policy.properties.policyDefinitionGroups
  }
}]

output policyDefinitionNames array = [for policy in policyDefinitions: policy.name]
output policySetDefinitionNames array = [for policy in policySetDefinitions: policy.name]
