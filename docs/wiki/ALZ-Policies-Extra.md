# ALZ Policies - Extra

This section describes additional policies that are not assigned by default or covered in the core ALZ Policies documentation, and provides guidance on how to handle certain situations.

## 1. ALZ Core

The Azure Landing Zone provides several additional policies and initiatives that are not assigned by default. These policies and initiatives are not necessary for all organizations and need additional considerations before being implemented.

### ALZ Provided Policies but not assigned by default

ALZ provides additional policies that are not assigned by default but that can be used for specific scenarios should they be required.

| Policy | Description | Notes |
|------------|-------------|-------------|
| Append-KV-SoftDelete | KeyVault SoftDelete should be enabled | |
| Audit-MachineLearning-PrivateEndpointId | Control private endpoint connections to Azure Machine Learning | |
| Deny-Aa-Child-Resources | No child resources in Automation Account | |
| Deny-Appgw-without-Waf | Application Gateway should be deployed with WAF enabled | |
| Deny-Databricks-NoPublicIp | Deny public IPs for Databricks cluster | |
| Deny-Databricks-Sku | Deny non-premium Databricks sku | |
| Deny-Databricks-VirtualNetwork | Deny Databricks workspaces without Vnet injection | |
| deny-fileservices-insecureauth | File Services with insecure authentication methods should be denied | |
| deny-fileservices-insecurekerberos | File Services with insecure Kerberos ticket encryption should be denied | |
| deny-fileservices-insecuresmbchannel | File Services with insecure SMB channel encryption should be denied | |
| deny-fileservices-insecuresmbversions | File Services with insecure SMB versions should be denied | |
| deny-machinelearning-aks | Deny AKS cluster creation in Azure Machine Learning | |
| deny-machinelearning-compute-subnetid | Enforce subnet connectivity for Azure Machine Learning compute clusters and compute instances | |
| deny-machinelearning-compute-vmsize | Limit allowed vm sizes for Azure Machine Learning compute clusters and compute instances | |
| deny-machinelearning-computecluster-remoteloginportpublicaccess | Deny public access of Azure Machine Learning clusters via SSH | |
| deny-machinelearning-computecluster-scale | Enforce scale settings for Azure Machine Learning compute clusters | |
| deny-machinelearning-hbiworkspace | Enforces high business impact Azure Machine Learning Workspaces | |
| deny-machinelearning-publicaccesswhenbehindvnet | Deny public access behind vnet to Azure Machine Learning workspace | |
| deny-machinelearning-publicnetworkaccess | [Deprecated] Azure Machine Learning should have disabled public network access | Deprecated |
| deny-private-dns-zones | Deny the creation of private DNS | |
| deny-publicendpoint-mariadb | [Deprecated] Public network access should be disabled for MariaDB | Deprecated |
| deny-publicip | [Deprecated] Deny the creation of public IP | Deprecated |
| deny-rdp-from-internet | [Deprecated] RDP access from the Internet should be blocked | Deprecated, replaced by Deny-MgmtPorts-From-Internet |
| deny-storage-sftp | Storage Accounts with SFTP enabled should be denied | |
| deny-storageaccount-customdomain | Storage Accounts with custom domains assigned should be denied | |
| deny-subnet-without-penp | Subnets without Private Endpoint Network Policies enabled should be denied | |
| deny-subnet-without-udr | Subnets should have a User Defined Route | |
| deny-udr-with-specific-nexthop | User Defined Routes with 'Next Hop Type' set to 'Internet' or 'VirtualNetworkGateway' should be denied | |
| deny-vnet-peering | Deny vNet peering | |
| deny-vnet-peering-to-non-approved-vnets | Deny vNet peering to non-approved vNets | |
| deploy_vm_availablememory_alert | Deploy VM Available Memory Alert | |
| deploy_vm_heartbeat_alert_rg | Deploy VM HeartBeat Alert | |
| deploy-budget | Deploy a default budget on all subscriptions under the assigned scope | |
| deploy-custom-route-table | Deploy a route table with specific user defined routes | |
| deploy-ddosprotection | Deploy an Azure DDoS Network Protection | |
| deploy-firewallpolicy | Deploy Azure Firewall Manager policy in the subscription | |
| deploy-nsg-flowlogs | [Deprecated] Deploys NSG flow logs and traffic analytics | Deprecated |
| deploy-nsg-flowlogs-to-la | [Deprecated] Deploys NSG flow logs and traffic analytics to Log Analytics | Deprecated |
| deploy-sql-tde | [Deprecated] Deploy SQL Database Transparent Data Encryption | Deprecated |
| deploy-sql-vulnerabilityassessments_20230706 | Deploy SQL Database Vulnerability Assessments | |
| deploy-vnet-hubspoke | Deploy Virtual Network with peering to the hub | |
| deploy-windows-domainjoin | Deploy Windows Domain Join Extension with keyvault configuration | |

## 2. ALZ and Regulated Industries

The Azure Landing Zone is designed to be a flexible and scalable solution that can be used by organizations in a variety of industries. However, organizations in regulated industries may need to take additional steps to ensure compliance with industry-specific regulations. To support the additional requirements of these industries, we're providing the following additional initiatives that enhance the security and compliance posture of the Azure Landing Zone:

| Initiative ID | Name | Description | # of Policies |
|------------|-------------|-------------|-------------|
| Enforce-Guardrails-APIM | Enforce secure-by-default API Management for regulated industries | This policy initiative is a group of policies that ensures API Management is compliant per regulated Landing Zones. | 11 |
| Enforce-Guardrails-AppServices | Enforce secure-by-default App Service for regulated industries | This policy initiative is a group of policies that ensures App Service is compliant per regulated Landing Zones. | 19 |
| Enforce-Guardrails-Automation | Enforce secure-by-default Automation Account for regulated industries | This policy initiative is a group of policies that ensures Automation Account is compliant per regulated Landing Zones. | 6 |
| Enforce-Guardrails-CognitiveServices | Enforce secure-by-default Cognitive Services for regulated industries | This policy initiative is a group of policies that ensures Cognitive Services is compliant per regulated Landing Zones. | 5 |
| Enforce-Guardrails-Compute | Enforce secure-by-default Compute for regulated industries | This policy initiative is a group of policies that ensures Compute is compliant per regulated Landing Zones. | 2 |
| Enforce-Guardrails-ContainerApps | Enforce secure-by-default Container Apps for regulated industries | This policy initiative is a group of policies that ensures Container Apps is compliant per regulated Landing Zones. | 2 |
| Enforce-Guardrails-ContainerInstance | Enforce secure-by-default Container Instance for regulated industries | This policy initiative is a group of policies that ensures Container Instance is compliant per regulated Landing Zones. | 1 |
| Enforce-Guardrails-ContainerRegistry | Enforce secure-by-default Container Registry for regulated industries | This policy initiative is a group of policies that ensures Container Registry is compliant per regulated Landing Zones. | 12 |
| Enforce-Guardrails-CosmosDb | Enforce secure-by-default Cosmos DB for regulated industries | This policy initiative is a group of policies that ensures Cosmos DB is compliant per regulated Landing Zones. | 6 |
| Enforce-Guardrails-DataExplorer | Enforce secure-by-default Data Explorer for regulated industries | This policy initiative is a group of policies that ensures Data Explorer is compliant per regulated Landing Zones. | 4 |
| Enforce-Guardrails-DataFactory | Enforce secure-by-default Data Factory for regulated industries | This policy initiative is a group of policies that ensures Data Factory is compliant per regulated Landing Zones. | 5 |
| Enforce-Guardrails-EventGrid | Enforce secure-by-default Event Grid for regulated industries | This policy initiative is a group of policies that ensures Event Grid is compliant per regulated Landing Zones. | 8 |
| Enforce-Guardrails-EventHub | Enforce secure-by-default Event Hub for regulated industries | This policy initiative is a group of policies that ensures Event Hub is compliant per regulated Landing Zones. | 4 |
| Enforce-Guardrails-KeyVault-Sup | Enforce secure-by-default Key Vault for regulated industries | This policy initiative is a group of policies that ensures Key Vault is compliant per regulated Landing Zones. This includes additional policies to supplement Enforce-Guardrails-KeyVault, which is assigned by default in ALZ. | 2 |
| Enforce-Guardrails-Kubernetes | Enforce secure-by-default Kubernetes for regulated industries | This policy initiative is a group of policies that ensures Kubernetes is compliant per regulated Landing Zones. | 16 |
| Enforce-Guardrails-MachineLearning | Enforce secure-by-default Machine Learning for regulated industries | This policy initiative is a group of policies that ensures Machine Learning is compliant per regulated Landing Zones. | 5 |
| Enforce-Guardrails-MySQL | Enforce secure-by-default Kubernetes for regulated industries | This policy initiative is a group of policies that ensures Kubernetes is compliant per regulated Landing Zones. | 2 |
| Enforce-Guardrails-Network | Enforce secure-by-default Network and Networking services for regulated industries | This policy initiative is a group of policies that ensures Network and Networking services is compliant per regulated Landing Zones. | 22 |
| Enforce-Guardrails-OpenAI | Enforce secure-by-default Open AI (Cognitive Services) for regulated industries | This policy initiative is a group of policies that ensures Open AI (Cognitive Services) is compliant per regulated Landing Zones. | 6 |
| Enforce-Guardrails-PostgreSQL | Enforce secure-by-default PostgreSQL for regulated industries | This policy initiative is a group of policies that ensures PostgreSQL is compliant per regulated Landing Zones. | 1 |
| Enforce-Guardrails-ServiceBus | Enforce secure-by-default Service Bus for regulated industries | This policy initiative is a group of policies that ensures Service Bus is compliant per regulated Landing Zones. | 4 |
| Enforce-Guardrails-SQL | Enforce secure-by-default SQL and SQL Managed Instance for regulated industries | This policy initiative is a group of policies that ensures SQL and SQL Managed Instance is compliant per regulated Landing Zones. | 5 |
| Enforce-Guardrails-Storage | Enforce secure-by-default Storage for regulated industries | This policy initiative is a group of policies that ensures Storage is compliant per regulated Landing Zones. | 22 |
| Enforce-Guardrails-Synapse | Enforce secure-by-default Synapse for regulated industries | This policy initiative is a group of policies that ensures Synapse is compliant per regulated Landing Zones. | 9 |
| Enforce-Guardrails-VirtualDesktop | Enforce secure-by-default Virtual Desktop for regulated industries | This policy initiative is a group of policies that ensures Virtual Desktop is compliant per regulated Landing Zones. | 2 |
