#### Deploying in Azure China regions

In Azure China Cloud, tenant-level permissions are restricted preventing the ability to perform tenant scoped deployments. You may also have restricted permissions at the `Root Management Group` level.

As such, we recommend you confirm that you have the ability to create Management Groups in your tenant and have `Owner` permissions to all required Subscriptions before proceeding with the following steps.

```powershell
# Do-It-Yourself instructions for deploying Azure landing zones in Azure China

# Connect to the AzureChinaCloud tenant.

Connect-AzAccount -Environment AzureChinaCloud

# Change the variables below to contain the right values for your tenant, subscription, address space etc.
# $Location determines the region where the metadata regarding the ARM deployment is stored, not where management groups, Azure Policies and Azure RBAC are stored because these resource are not deployed to a particular region. See https://docs.microsoft.com/azure/cloud-adoption-framework/ready/enterprise-scale/faq#why-are-we-asked-to-specify-azure-regions-during-the-azure-landing-zone-accelerator-deployment-and-what-are-they-used-for

$AlzPrefix = "alz"
$Location = "chinaeast2"
$DeploymentName = "alz"
$TenantRootGroupId = (Get-AzTenant).Id
$ManagementSubscriptionId = "<replace me>"
$ConnectivitySubscriptionId = "<replace me>"
$ConnectivityAddressPrefix = "<replace me>"
$IdentitySubscriptionId = "<replace me>"
$SecurityContactEmailAddress = "<replace@this.address>"
$CorpConnectedLandingZoneSubscriptionId = "<replace me>" 
$OnlineLandingZoneSubscriptionId = "<replace me>"

# Pre-stage your intermediate root management group
# Note: You may receive an error `New-AzManagementGroup: Long running operation failed with status 'Forbidden'.`. This can be safely ignored.

New-AzManagementGroup -GroupName $AlzPrefix -ParentId "/providers/Microsoft.Management/managementGroups/$TenantRootGroupId"

# Deploying management group structure for Azure landing zones
# Note: You may need to refresh your credentials using `Connect-AzAccount -Environment AzureChinaCloud` before proceeding with the next step

New-AzManagementGroupDeployment -Name $DeploymentName `
                                -ManagementGroupId $AlzPrefix `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\mgmtGroupStructure\mgmtGroups.json `
                                -topLevelManagementGroupPrefix $AlzPrefix `
                                -Verbose

# Deploy core policy definitions to ALZ intermediate root management group
# Note: If your ProvisioningState is "Failed", please go to your top level management group prefix under Management Groups in the Azure Portal, under Governance click "Deployments", click on the deployment with the post-fix "-policy1". If the Operation Details show that the policy set definition request is invalid because some policy definition could not be found, this is often due to a known replication delay. Please re-run the deployment step below, and the deployment should succeed.

New-AzManagementGroupDeployment -Name "$($DeploymentName)-policy1" `
                                -ManagementGroupId $AlzPrefix `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyDefinitions\policies.json `
                                -topLevelManagementGroupPrefix $AlzPrefix `
                                -Verbose

# Add dedicated subscription for platform management

New-AzManagementGroupDeployment -Name "$($DeploymentName)-mgsub" `
                                -ManagementGroupId "$($AlzPrefix)-management" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\subscriptionOrganization\subscriptionOrganization.json `
                                -targetManagementGroupId "$($AlzPrefix)-management" `
                                -subscriptionId $ManagementSubscriptionId `
                                -Verbose

# Add dedicated subscription for platform connectivity

New-AzManagementGroupDeployment -Name "$($DeploymentName)-connsub" `
                                -ManagementGroupId "$($AlzPrefix)-connectivity" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\subscriptionOrganization\subscriptionOrganization.json `
                                -targetManagementGroupId "$($AlzPrefix)-connectivity" `
                                -subscriptionId $ConnectivitySubscriptionId `
                                -Verbose

# Add dedicated subscription for platform identity

New-AzManagementGroupDeployment -Name "$($DeploymentName)-idsub" `
                                -ManagementGroupId "$($AlzPrefix)-identity" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\subscriptionOrganization\subscriptionOrganization.json `
                                -targetManagementGroupId "$($AlzPrefix)-identity" `
                                -subscriptionId $IdentitySubscriptionId `
                                -Verbose

# Deploy Log Analytics Workspace to the platform management subscription

Select-AzSubscription -SubscriptionId $ManagementSubscriptionId

New-AzSubscriptionDeployment -Name "$($DeploymentName)-la" `
                             -Location $Location `
                             -TemplateFile .\eslzArm\subscriptionTemplates\logAnalyticsWorkspace.json `
                             -rgName "$($AlzPrefix)-mgmt" `
                             -workspaceName "$($AlzPrefix)-law" `
                             -workspaceRegion $Location `
                             -retentionInDays "30" `
                             -automationAccountName "$($AlzPrefix)-aauto" `
                             -automationRegion $Location `
                             -Verbose

# Deploy Log Analytics Solutions to the Log Analytics workspace in the platform management subscription

Select-AzSubscription -SubscriptionId $ManagementSubscriptionId

New-AzSubscriptionDeployment -Name "$($DeploymentName)-la-solution" `
                             -Location $Location `
                             -TemplateFile .\eslzArm\subscriptionTemplates\logAnalyticsSolutions.json `
                             -rgName "$($AlzPrefix)-mgmt" `
                             -workspaceName "$($AlzPrefix)-law" `
                             -workspaceRegion $Location `
                             -Verbose
                             
# Assign Azure Policy to enforce Log Analytics workspace on the management, management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-la-policy" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-LogAnalyticsPolicyAssignment.json `
                                -retentionInDays "30" `
                                -rgName "$($AlzPrefix)-mgmt" `
                                -ManagementGroupId "$($AlzPrefix)-management" `
                                -topLevelManagementGroupPrefix $AlzPrefix `
                                -logAnalyticsWorkspaceName "$($AlzPrefix)-law" `
                                -workspaceRegion $Location `
                                -automationAccountName "$($AlzPrefix)-aauto" `
                                -automationRegion $Location `
                                -Verbose

# Assign Azure Policy to enforce diagnostic settings for subscriptions on top level management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-resource-diag" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-ResourceDiagnosticsPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $AlzPrefix `
                                -logAnalyticsResourceId "/subscriptions/$($ManagementSubscriptionId)/resourceGroups/$($AlzPrefix)-mgmt/providers/Microsoft.OperationalInsights/workspaces/$($AlzPrefix)-law" `
                                -ManagementGroupId $AlzPrefix `
                                -Verbose

# Assign Azure Policy to enforce Microsoft Defender for Cloud configuration enabled on all subscriptions, deployed to top level management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-mdfc-config" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\china\mcDINE-MDFCConfigPolicyAssignment.json `
                                -ManagementGroupId $AlzPrefix `
                                -topLevelManagementGroupPrefix $AlzPrefix `
                                -logAnalyticsResourceId "/subscriptions/$($ManagementSubscriptionId)/resourceGroups/$($AlzPrefix)-mgmt/providers/Microsoft.OperationalInsights/workspaces/$($AlzPrefix)-law" `
                                -enableAscForServers "DeployIfNotExists" `
                                -enableAscForSql "DeployIfNotExists" `
                                -enableAscForContainers "DeployIfNotExists" `
                                -emailContactAsc $SecurityContactEmailAddress `
                                -Verbose

# Assign Azure Policy to enable Microsoft Cloud Security Benchmark, deployed to top level management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-asb" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-ASBPolicyAssignment.json `
                                -ManagementGroupId $AlzPrefix `
                                -Verbose

# Create connectivity hub, using traditional hub & spoke in this example
# Note: After you have executed the deployment step below, please check that these deployment names, $AlzPrefix-hubspoke and alz-****-****-connectivityHubSub in your $ConnectivitySubscriptionId have succeeded. If you get this error "New-AzDeployment: An error occurred while sending the request." on the command line, just ignore it.
Select-AzSubscription -SubscriptionId $ConnectivitySubscriptionId

New-AzSubscriptionDeployment -Name "$($DeploymentName)-hubspoke" `
                             -Location $Location `
                             -TemplateFile .\eslzArm\subscriptionTemplates\hubspoke-connectivity.json `
                             -topLevelManagementGroupPrefix $AlzPrefix `
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
                             -rgName "$($AlzPrefix)-privatedns" `
                             -locationFromTemplate $Location `
                             -Verbose

New-AzResourceGroupDeployment -Name "$($DeploymentName)-private-dns-storage" `
                              -ResourceGroupName "$($AlzPrefix)-privatedns" `
                              -TemplateFile .\eslzArm\resourceGroupTemplates\privateDnsZones.json `
                              -connectivityHubResourceId "/subscriptions/$($ConnectivitySubscriptionId)/resourceGroups/$($AlzPrefix)-vnethub-$($Location)/providers/Microsoft.Network/virtualNetworks/$($AlzPrefix)-hub-$($Location)" `
                              -privateDnsZoneName "privatelink.blob.core.chinacloudapi.cn" `
                              -Verbose

# Assign Azure Policy to prevent public IP usage in the identity subscription

New-AzManagementGroupDeployment -Name "$($DeploymentName)-public-ip" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-identity" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-PublicIpAddressPolicyAssignment.json `
                                -Verbose

# Assign Azure Policy to enforce VM Backup on VMs in the identity subscription

New-AzManagementGroupDeployment -Name "$($DeploymentName)-vm-backup" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-identity" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-VMBackupPolicyAssignment.json `
                                -topLevelManagementGroupPrefix "idVmBackup" `
                                -Verbose

# Assign Azure Policy to deny RDP access from internet into VMs (domain controllers) in the identity subscription

New-AzManagementGroupDeployment -Name "$($DeploymentName)-vm-rdp" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-identity" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-RDPFromInternetPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $AlzPrefix `
                                -Verbose

# Assign Azure Policy to deny subnets without NSG in the identity subscription

New-AzManagementGroupDeployment -Name "$($DeploymentName)-subnet-nsg" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-identity" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-SubnetWithoutNsgPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $AlzPrefix `
                                -Verbose

# Assign Azure Policy to deny IP forwarding on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-ip-fwd" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-IPForwardingPolicyAssignment.json `
                                -Verbose

# Assign Azure Policy to deny IP deny subnets without NSG on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-lz-subnet-nsg" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-SubnetWithoutNsgPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $AlzPrefix `
                                -Verbose

# Assign Azure Policy to deny RDP access from internet into VMs on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-lz-vm-rdp" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-RDPFromInternetPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $AlzPrefix `
                                -Verbose
                                
# Assign Azure Policy to deny usage of storage accounts over http on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-storage-https" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-StorageWithoutHttpsPolicyAssignment.json `
                                -Verbose

# Assign Azure Policy to enforce AKS policy add-on on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-aks-policy" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-AksPolicyPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $AlzPrefix `
                                -Verbose
                                
# Assign Azure Policy to enforce SQL auditing on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-sql-auditing" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-SQLAuditingPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $AlzPrefix `
                                -Verbose

# Assign Azure Policy to enforce VM Backup on VMs on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-vm-lz-backup" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-VMBackupPolicyAssignment.json `
                                -topLevelManagementGroupPrefix "lzVmBackup" `
                                -Verbose

# Assign Azure Policy to enforce TLS/SSL on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-tls-ssl" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-DINE-APPEND-TLS-SSL-PolicyAssignment.json `
                                -topLevelManagementGroupPrefix $AlzPrefix `
                                -Verbose
                                
# Assign Azure Policy to enforce AKS clusters to not allow container priv escalation on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-aks-priv-esc" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-AksPrivEscalationPolicyAssignment.json `
                                -Verbose

# Assign Azure Policy to enforce AKS clusters to not allow privileged containers on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-aks-priv-con" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-AksPrivilegedPolicyAssignment.json `
                                -Verbose
                                
# Assign Azure Policy to enforce AKS clusters to not allow traffic over http on the landing zones management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-aks-priv-https" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-landingzones" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-AksWithoutHttpsPolicyAssignment.json `
                                -Verbose
                                
# Assign Azure Policy to prevent usage of public endpoint for Azure PaaS services on the corp landing zone management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-paas-endpoint" `
                                -Location $Location `
                                -ManagementGroupId "$($AlzPrefix)-corp" `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DENY-PublicEndpointPolicyAssignment.json `
                                -topLevelManagementGroupPrefix $AlzPrefix `
                                -Verbose

# Add the first corp connected landing zone subscription to Corp management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-corp1" `
                                -ManagementGroupId "$($AlzPrefix)-corp" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\subscriptionOrganization\subscriptionOrganization.json `
                                -targetManagementGroupId "$($AlzPrefix)-corp" `
                                -subscriptionId $CorpConnectedLandingZoneSubscriptionId `
                                -Verbose

# Add the first online connected landing zone subscription to Online management group

New-AzManagementGroupDeployment -Name "$($DeploymentName)-online1" `
                                -ManagementGroupId "$($AlzPrefix)-online" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\subscriptionOrganization\subscriptionOrganization.json `
                                -targetManagementGroupId "$($AlzPrefix)-online" `
                                -subscriptionId $OnlineLandingZoneSubscriptionId `
                                -Verbose
```
