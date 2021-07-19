# Enterprise-Scale Landing Zones ARM templates

This folder contains the first-party ARM templates for Enterprise-Scale, and are being used when deploying and bootstrapping in the Azure Portal.

For customers who cannot deploy via portal, but rather want to clone the repository and sequence the deployments on their own, they can follow the instructions below.

> **Note:** There's a strict sequencing required in order to achieve the same outcome as when deploying via the Azure portal, and any modification and changes to the templates are not supported.

## Do-It-Yourself deployment instructions for Enterprise-Scale using Azure PowerShell

````powershell

# Do-It-Yourself instructions for doing Enterprise-Scale the _hard way_

$ESLZPrefix = "ESLZfoo"
$Location = "westeurope"
$DeploymentName = "eslzasd"
$TenantRootGroupId = (Get-AzTenant).Id
$ManagementSubscriptionId = "feab2d15-66b4-438b-accf-51f889b30ec3"
$ConnectivitySubscriptionId = "99c2838f-a548-4884-a6e2-38c1f8fb4c0b"
$IdentitySubscriptionId = "9e32661b-498f-4fd8-bffc-c9ecb4830430"

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
                                -topLevelManagementGroupPrefix $ESLZPrefix `
                                -Verbose

# Deploying policy initiative for associating private DNS zones with private endpoints for Azure PaaS services

New-AzManagementGroupDeployment -Name "$($DeploymentName)-policy3" `
                                -ManagementGroupId $ESLZPrefix `
                                -Location $Location `
                                -TemplateFile .\eslzArm\managementGroupTemplates\policyDefinitions\DINE-PrivateDNSZonesPolicySetDefinition.json `
                                -topLevelManagementGroupPrefix $ESLZPrefix `
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
                             
````
