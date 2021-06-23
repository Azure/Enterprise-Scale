# Azure Key Vault

## Overview

The ARM template and Bicep file for Azure Key Vault is developed for organizations to accelerate their deployment while ensuring the Azure Service is compliant and meets your organization's requirements for hardening PaaS services.

## Compliant Azure Key Vault

It is assumed that the deployment will go into a landing zone where the platform provides the guardrails (Azure Policy), such as:

- Diagnostics and metrics are enabled to route security relevant information to a platform Log Analytics workspace (this does not prevent application teams to also use their app centric Log Analytics workspace, which also will have a diagnostic setting configured to send logs/metrics.)
- Usage of public endpoint is not allowed for PaaS services
- Private endpoints DNS records are automatically created in the privatelink.vaultcore.azure.net Azure Private DNS zone in the connectivity subscription
- Azure Defender (Azure Security Center) is enabled for Azure Key Vault in the landing zones
- Soft-delete is enabled by default
- Purge protection is enabled by default

The following table shows the policies related to Key Vault to address the above

|**ESLZ Policy**<br /><sub>(Azure portal)</sub> | <div style="width:1000px">**Description**</div> | **Effect(s)** | **Assignment scope** |
|---|:---:|:---:|:---:|
| KeyVault SoftDelete should be enabled | Ensures that Key Vaults are created with soft-delete enabled | append | Intermediate Root Management Group 
| Deploy Diagnostics settings for Key Vault to Log Analytics workspace | Deploys the diagnostics settings for Key Vaults, and connects to a Log Analytics workspace | deployIfNotExists, disabled | Intermediate root Management Group |
| Deploy DNS Zone Group for Key Vault Private Endpoint | Deploys the configurations of a Private DNS Zone Group by a parameter for Key Vault Private Endpoint. Used enforce the configuration to a single Private DNS Zone | deployIfNotExists, disabled | Landing Zone Management Group |
| Deploy Azure Defender for AKV | Deploys and enable Azure Defender for Azure Key Vault on the subscription to be either set to on (Standard) or free | deployIfNotExists, disabled | Intermediate root Management Group |
| Deny or Deploy and Append TLS requirements and SSL enforcement on resources without encryption in transit | Choose either Deploy if not exist and append in combination with audit or Select Deny in the Policy effect. Deny polices shift left. Deploy if not exist and append enforce but can be changed | append, audit, auditIfNotExists, deployIfNotExists, deny | Landing Zones management group |
Configure Azure Key Vaults with private endpoints | Private endpoints connect your virtual networks to Azure services without a public IP address at the source or destination. By mapping private endpoints to key vault, you can reduce data leakage risks. Learn more about private links at: https://aka.ms/akvprivatelink. | deployIfNotExists, disabled | Landing Zones management group |
Azure Key Vaults should use private link | Azure Private Link lets you connect your virtual networks to Azure services without a public IP address at the source or destination. The Private Link platform handles the connectivity between the consumer and services over the Azure backbone network. By mapping private endpoints to key vault, you can reduce data leakage risks. Learn more about private links at: https://aka.ms/akvprivatelink. | audit, deny, disabled | Landing Zones management group

## How to deploy
The ARM template and bicep file can be deployed directly, or be staged as a templateSpec in your tenant, and shared with application teams via RBAC.

You can consume the template and bicep file in the following ways:

### Deploy using Azure PowerShell

````powershell
New-AzResourceGroupDeployment -Name <name> -ResourceGroupName <rgName> -TemplateUri "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/workloads/keyvault/azkeyvault.json"
````

### Deploy using Azure CLI

````cli
az deployment group create --resource-group <rgName> --name <name> --template-uri "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/workloads/keyvault/azkeyvault.json"
````

### Deploy as TemplateSpec using Azure PowerShell

````powershell
New-AzTemplateSpec -Name AzKeyVault -Version 1.0.0 -ResourceGroupName <rgName> -Location <location> -TemplateFile .\azkeyvault.json
````

### Deploy as TemplateSpec using Azure CLI

````cli
az ts create --name AzKeyVault --version 1.0.0 --resource-group <rgName> --location <location> --template-file ./azkeyvault.json
````

### Deploy as Bicep

>Note: Currently, Azure CLI doesn't support deploying remote Bicep files. Use [Bicep CLI](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install#development-environment) to compile the Bicep file to a JSON template, and then load the JSON file to the remote location