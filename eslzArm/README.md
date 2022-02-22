# Enterprise-Scale Landing Zones ARM templates

> The Bicep version is now available in Public Preview here: [https://github.com/Azure/ALZ-Bicep](https://github.com/Azure/ALZ-Bicep)

This folder contains the first-party ARM templates for Enterprise-Scale which and are being used when deploying and bootstrapping in the Azure Portal, which is our recommendation as it will 1) save you tremendous amount of time, 2) accelerate your journey, and 3) optionally bootstrap your GitHub repository with ready-to-use ARM templates if you want to pivot to infrastructure-as-code post deployment.

For customers who cannot deploy via portal, but rather want to clone the repository and sequence the deployments on their own using the same ARM templates, they can follow the manual deployment instructions below.

> **Note:** There's a strict sequencing required in order to achieve the same outcome as when deploying via the Azure portal, and any modification and changes to the templates are not supported.

## Do-It-Yourself deployment instructions for Enterprise-Scale using Azure PowerShell

Prerequisites:

* [Azure PowerShell module](https://docs.microsoft.com/powershell/azure/install-az-ps?view=azps-6.3.0)
* [Sign in and get started](https://docs.microsoft.com/powershell/azure/get-started-azureps?view=azps-6.3.0#sign-in-to-azure)
* [Configure Azure permissions for ARM tenant deployments](https://github.com/Azure/Enterprise-Scale/blob/main/docs/EnterpriseScale-Setup-azure.md)
* [How to clone a GitHub repository](https://docs.github.com/github/creating-cloning-and-archiving-repositories/cloning-a-repository-from-github/cloning-a-repository)

There are two sets of instructions; one for deploying to Azure global regions, and another for deploying specifically to Azure China regions. This is due to minor difference in services which are available in Azure global and in Azure China, but the feature parity gap is narrowing. Here are the quick links to bring you to the specific set of instructions:

1. [Deploying in Azure global regions](#deploying-in-azure-global-regions)
2. [Deploying in Azure China regions](./README-AzureChina.md)

#### Deploying in Azure global regions

````powershell

# Do-It-Yourself instructions for deploying Enterprise-Scale in Azure global regions

# Change the variables below to contain the right values for your tenant, subscription, address space etc.

$ESLZPrefix = "ESLZ"
$Location = "westeurope"
$DeploymentName = "EntScale"
$TenantRootGroupId = (Get-AzTenant).Id
$ManagementSubscriptionId = "<replace me>"
$ConnectivitySubscriptionId = "<replace me>"
$ConnectivityAddressPrefix = "<replace me>"
$IdentitySubscriptionId = "<replace me>"
$SecurityContactEmailAddress = "<replace@this.address>"
$CorpConnectedLandingZoneSubscriptionId = "<replace me>" 
$OnlineLandingZoneSubscriptionId = "<replace me>"

# Deploying management group structure for Enterprise-Scale

New-AzManagementGroupDeployment -Name $DeploymentName `
                                -ManagementGroupId $TenantRootGroupId `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\mgmtGroupStructure\mgmtGroups.json `
                                -topLevelManagementGroupPrefix $ESLZPrefix `
                                -Verbose

# Deploy core policy definitions to ESLZ intermediate root management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-policy1" `
                                -ManagementGroupId $ESLZPrefix `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyDefinitions\policies.json `
                                -topLevelManagementGroupPrefix $ESLZPrefix `
                                -Verbose

# Deploy policy initiative for preventing usage of public endpoint for Azure PaaS services

New-AzManagementGroupDeployment -Name "$($DeploymentName)-policy2" `
                                -ManagementGroupId $ESLZPrefix `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyDefinitions\DENY-PublicEndpointsPolicySetDefinition.json `
                                -Verbose

# Deploying policy initiative for associating private DNS zones with private endpoints for Azure PaaS services

New-AzManagementGroupDeployment -Name "$($DeploymentName)-policy3" `
                                -ManagementGroupId $ESLZPrefix `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyDefinitions\DINE-PrivateDNSZonesPolicySetDefinition.json `
                                -Verbose

# Add dedicated subscription for platform management

New-AzManagementGroupDeployment -Name "$($DeploymentName)-mgsub" `
                                -ManagementGroupId "$($ESLZPrefix)-management" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\subscriptionOrganization\subscriptionOrganization.json `
                                -targetManagementGroupId "$($ESLZPrefix)-management" `
                                -subscriptionId $ManagementSubscriptionId `
                                -Verbose

# Add dedicated subscription for platform connectivity

New-AzManagementGroupDeployment -Name "$($DeploymentName)-connsub" `
                                -ManagementGroupId "$($ESLZPrefix)-connectivity" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\subscriptionOrganization\subscriptionOrganization.json `
                                -targetManagementGroupId "$($ESLZPrefix)-connectivity" `
                                -subscriptionId $ConnectivitySubscriptionId `
                                -Verbose

# Add dedicated subscription for platform identity

New-AzManagementGroupDeployment -Name "$($DeploymentName)-idsub" `
                                -ManagementGroupId "$($ESLZPrefix)-identity" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\subscriptionOrganization\subscriptionOrganization.json `
                                -targetManagementGroupId "$($ESLZPrefix)-identity" `
                                -subscriptionId $IdentitySubscriptionId `
                                -Verbose

# Deploy Log Analytics Workspace to the platform management subscription

Select-AzSubscription -SubscriptionName $ManagementSubscriptionId

New-AzSubscriptionDeployment -Name "$($DeploymentName)-la" `
                             -Location $Location `
                             -TemplateFile .\eslzArm\subscriptionTemplates\logAnalyticsWorkspace.json `
                             -rgName "$($ESLZPrefix)-mgmt" `
                             -workspaceName "$($ESLZPrefix)-law" `
                             -workspaceRegion $Location `
                             -retentionInDays "30" `
                             -automationAccountName "$($ESLZPrefix)-aauto" `
                             -automationRegion $Location `
                             -Verbose

# Deploy Log Analytics Solutions to the Log Analytics workspace in the platform management subscription

Select-AzSubscription -SubscriptionName $ManagementSubscriptionId

New-AzSubscriptionDeployment -Name "$($DeploymentName)-la-solution" `
                             -Location $Location `
                             -TemplateFile .\eslzArm\subscriptionTemplates\logAnalyticsSolutions.json `
                             -rgName "$($ESLZPrefix)-mgmt" `
                             -workspaceName "$($ESLZPrefix)-law" `
                             -workspaceRegion $Location `
                             -Verbose
                             
# Assign Azure Policy to enforce Log Analytics workspace on the management, management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-la-policy" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-LogAnalyticsPolicyAssignment.json `
                                -retentionInDays "30" `
                                -rgName "$($ESLZPrefix)-mgmt" `
                                -ManagementGroupId "$($eslzPrefix)-management" `
                                -topLevelManagementGroupPrefix $ESLZPrefix `
                                -logAnalyticsWorkspaceName "$($ESLZPrefix)-law" `
                                -workspaceRegion $Location `
                                -automationAccountName "$($ESLZPrefix)-aauto" `
                                -automationRegion $Location `
                                -Verbose

# Assign Azure Policy to enforce diagnostic settings for subscriptions on top level management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-sub-diag" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-ActivityLogPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $ESLZPrefix `
                                -logAnalyticsResourceId "/subscriptions/$($ManagementSubscriptionId)/resourceGroups/$($eslzPrefix)-mgmt/providers/Microsoft.OperationalInsights/workspaces/$($eslzPrefix)-law" `
                                -ManagementGroupId $ESLZPrefix `
                                -Verbose

# Assign Azure Policy to enforce diagnostic settings for subscriptions on top level management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-resource-diag" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-ResourceDiagnosticsPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $ESLZPrefix `
                                -logAnalyticsResourceId "/subscriptions/$($ManagementSubscriptionId)/resourceGroups/$($eslzPrefix)-mgmt/providers/Microsoft.OperationalInsights/workspaces/$($eslzPrefix)-law" `
                                -ManagementGroupId $ESLZPrefix `
                                -Verbose

# Assign Azure Policy to enforce Azure Security Center configuration enabled on all subscriptions, deployed to top level management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-mdfc-config" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-MDFCConfigPolicyAssignment.json `
                                -ManagementGroupId $eslzPrefix `
                                -topLevelManagementGroupPrefix $ESLZPrefix `
                                -logAnalyticsResourceId "/subscriptions/$($ManagementSubscriptionId)/resourceGroups/$($eslzPrefix)-mgmt/providers/Microsoft.OperationalInsights/workspaces/$($eslzPrefix)-law" `
                                -enableAscForServers "DeployIfNotExists" `
                                -enableAscForSql "DeployIfNotExists" `
                                -enableAscForAppServices "DeployIfNotExists" `
                                -enableAscForStorage "DeployIfNotExists" `
                                -enableAscForContainers "DeployIfNotExists" `
                                -enableAscForKeyVault "DeployIfNotExists" `
                                -enableAscForSqlOnVm "DeployIfNotExists" `
                                -enableAscForArm "DeployIfNotExists" `
                                -enableAscForDns "DeployIfNotExists" `
                                -enableAscForOssDb "DeployIfNotExists" `
                                -emailContactAsc $SecurityContactEmailAddress `
                                -Verbose

# Assign Azure Policy to enable Azure Security Benchmark, deployed to top level management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-asb" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-ASBPolicyAssignment.json `
                                -ManagementGroupId $ESLZPrefix `
                                -Verbose

# Create connectivity hub, using traditional hub & spoke in this example

Select-AzSubscription -SubscriptionId $ConnectivitySubscriptionId

New-AzSubscriptionDeployment -Name "$($DeploymentName)-hubspoke" `
                             -Location $Location `
                             -TemplateFile .\eslzArm\subscriptionTemplates\hubspoke-connectivity.json `
                             -topLevelManagementGroupPrefix $ESLZPrefix `
                             -connectivitySubscriptionId $ConnectivitySubscriptionId `
                             -addressPrefix $ConnectivityAddressPrefix `
                             -enableHub "vhub" `
                             -enableAzFw "No" `
                             -enableAzFwDnsProxy "No" `
                             -enableVpnGw "No" `
                             -enableErGw "No" `
                             -enableDdoS "No" `
                             -Verbose

# Create Private DNS Zones for Azure PaaS services. Note, you must repeat this deployment for all Azure PaaS services as requested, and an updated table can be found at https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
# The following example will first create a resource group, and the subsequent deployment will create Private DNS Zone for Storage Account into that resource group

Select-AzSubscription -SubscriptionId $ConnectivitySubscriptionId

New-AzSubscriptionDeployment -Name "$($DeploymentName)-private-dns-rg" `
                             -Location $Location `
                             -TemplateFile .\eslzArm\subscriptionTemplates\resourceGroup.json `
                             -rgName "$($ESLZPrefix)-privatedns" `
                             -locationFromTemplate $Location `
                             -Verbose

New-AzResourceGroupDeployment -Name "$($DeploymentName)-private-dns-storage" `
                              -ResourceGroupName "$($ESLZPrefix)-privatedns" `
                              -TemplateFile .\eslzArm\resourceGroupTemplates\privateDnsZones.json `
                              -connectivityHubResourceId "/subscriptions/$($ConnectivitySubscriptionId)/resourceGroups/$($ESLZPrefix)-vnethub-$($Location)/providers/Microsoft.Network/virtualNetworks/$($ESLZPrefix)-hub-$($Location)" `
                              -privateDnsZoneName "privatelink.blob.core.windows.net" `
                              -Verbose

# Assign Azure Policy to prevent public IP usage in the identity subscription

New-AzManagementGroupDeployment -Name "$($DeploymentName)-public-ip" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-identity" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-PublicIpAddressPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $ESLZPrefix `
                                -Verbose

# Assign Azure Policy to enforce VM Backup on VMs in the identity subscription

New-AzManagementGroupDeployment -Name "$($DeploymentName)-vm-backup" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-identity" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-VMBackupPolicyAssignment.json `
                                -topLevelManagementGroupPrefix "idVmBackup" `
                                -Verbose

# Assign Azure Policy to deny RDP access from internet into VMs (domain controllers) in the identity subscription

New-AzManagementGroupDeployment -Name "$($DeploymentName)-vm-rdp" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-identity" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-RDPFromInternetPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $eslzPrefix `
                                -Verbose

# Assign Azure Policy to deny subnets without NSG in the identity subscription

New-AzManagementGroupDeployment -Name "$($DeploymentName)-subnet-nsg" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-identity" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-SubnetWithoutNsgPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $eslzPrefix `
                                -Verbose

# Assign Azure Policy to deny IP forwarding on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-ip-fwd" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-IPForwardingPolicyAssignment.json `
                                -Verbose

# Assign Azure Policy to deny IP deny subnets without NSG on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-lz-subnet-nsg" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-SubnetWithoutNsgPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $ESLZPrefix `
                                -Verbose

# Assign Azure Policy to deny RDP access from internet into VMs on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-lz-vm-rdp" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-RDPFromInternetPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $eslzPrefix `
                                -Verbose
                                
# Assign Azure Policy to deny usage of storage accounts over http on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-storage-https" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-StorageWithoutHttpsPolicyAssignment.json `
                                -Verbose

# Assign Azure Policy to enforce AKS policy add-on on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-aks-policy" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-AksPolicyPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $ESLZPrefix `
                                -Verbose
                                
# Assign Azure Policy to enforce SQL auditing on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-sql-auditing" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-SQLAuditingPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $ESLZPrefix `
                                -Verbose
                                
# Assign Azure Policy to enforce VM Backup on VMs on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-vm-lz-backup" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-VMBackupPolicyAssignment.json `
                                -topLevelManagementGroupPrefix "lzVmBackup" `
                                -Verbose

# Assign Azure Policy to enforce TLS/SSL on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-tls-ssl" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-DINE-APPEND-TLS-SSL-PolicyAssignment.json `
                                -topLevelManagementGroupPrefix $eslzPrefix `
                                -Verbose
                                
# Assign Azure Policy to enforce AKS clusters to not allow container priv escalation on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-aks-priv-esc" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-AksPrivEscalationPolicyAssignment.json `
                                -Verbose

# Assign Azure Policy to enforce AKS clusters to not allow privileged containers on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-aks-priv-con" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-AksPrivilegedPolicyAssignment.json `
                                -Verbose
                                
# Assign Azure Policy to enforce AKS clusters to not allow traffic over http on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-aks-priv-https" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-AksWithoutHttpsPolicyAssignment.json `
                                -Verbose
                                
# Assign Azure Policy to prevent usage of public endpoint for Azure PaaS services on the corp landing zone management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-paas-endpoint" `
                                -Location $Location `
                                -ManagementGroupId "$($ESLZPrefix)-corp" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-PublicEndpointPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $ESLZPrefix `
                                -Verbose

# Add the first corp connected landing zone subscription to Corp management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-corp1" `
                                -ManagementGroupId "$($ESLZPrefix)-corp" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\subscriptionOrganization\subscriptionOrganization.json `
                                -targetManagementGroupId "$($ESLZPrefix)-corp" `
                                -subscriptionId $CorpConnectedLandingZoneSubscriptionId `
                                -Verbose

# Add the first online connected landing zone subscription to Online management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-online1" `
                                -ManagementGroupId "$($ESLZPrefix)-online" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\subscriptionOrganization\subscriptionOrganization.json `
                                -targetManagementGroupId "$($ESLZPrefix)-online" `
                                -subscriptionId $OnlineLandingZoneSubscriptionId `
                                -Verbose
````
