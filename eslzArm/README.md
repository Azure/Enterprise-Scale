# Enterprise-Scale Landing Zones ARM templates

This folder contains the first-party ARM templates for Enterprise-Scale which and are being used when deploying and bootstrapping in the Azure Portal.

For customers who cannot deploy via portal, but rather want to clone the repository and sequence the deployments on their own, they can follow the instructions below.

> **Note:** There's a strict sequencing required in order to achieve the same outcome as when deploying via the Azure portal, and any modification and changes to the templates are not supported.

## Do-It-The-Hard-Way deployment instructions for Enterprise-Scale using Azure PowerShell

````powershell

# Do-It-Yourself instructions for doing Enterprise-Scale the _hard way_

$ESLZPrefix = "ESLZfoo"
$Location = "westeurope"
$DeploymentName = "eslzasd"
$TenantRootGroupId = (Get-AzTenant).Id
$ManagementSubscriptionId = "feab2d15-66b4-438b-accf-51f889b30ec3"
$ConnectivitySubscriptionId = "99c2838f-a548-4884-a6e2-38c1f8fb4c0b"
$ConnectivityAddressPrefix = "192.168.0.0/24"
$IdentitySubscriptionId = "9e32661b-498f-4fd8-bffc-c9ecb4830430"
$SecurityContactEmailAddress = "krnese@foo.bar"

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

New-AzManagementGroupDeployment -Name "$($DeploymentName)-asc-config" `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyAssignments\DINE-ASCConfigPolicyAssignment.json `
                                -ManagementGroupId $eslzPrefix `
                                -topLevelManagementGroupPrefix $ESLZPrefix `
                                -logAnalyticsResourceId "/subscriptions/$($ManagementSubscriptionId)/resourceGroups/$($eslzPrefix)-mgmt/providers/Microsoft.OperationalInsights/workspaces/$($eslzPrefix)-law" `
                                -enableAscForServers "Standard" `
                                -enableAscForSql "Standard" `
                                -enableAscForAppServices "Standard" `
                                -enableAscForStorage "Standard" `
                                -enableAscForRegistries "Standard" `
                                -enableAscForKeyVault "Standard" `
                                -enableAscForSqlOnVm "Standard" `
                                -enableAscForKubernetes "Standard" `
                                -enableAscForArm "Standard" `
                                -enableAscForDns "Standard" `
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
                             
````
