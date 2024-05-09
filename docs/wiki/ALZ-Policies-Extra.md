# ALZ Policies - Extra

This document describes additional ALZ custom policy definitions and initiatives that are not assigned by default in ALZ, but are provided as they may assist some consumers of ALZ in specific scenarios where they can assign these additional policies to help them meet their objectives. We also provide guidance on how to handle certain situations as some of the policies require additional considerations prior to assigning.


## Additional ALZ Custom Policies that are provided but not assigned by default

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
| Deny-FileServices-InsecureAuth | File Services with insecure authentication methods should be denied | |
| Deny-FileServices-InsecureKerberos | File Services with insecure Kerberos ticket encryption should be denied | |
| Deny-FileServices-InsecureSmbChannel | File Services with insecure SMB channel encryption should be denied | |
| Deny-FileServices-InsecureSmbVersions | File Services with insecure SMB versions should be denied | |
| Deny-MachineLearning-Aks | Deny AKS cluster creation in Azure Machine Learning | |
| Deny-Machinelearning-Compute-Subnetid | Enforce subnet connectivity for Azure Machine Learning compute clusters and compute instances | |
| Deny-MachineLearning-Compute-Vmsize | Limit allowed vm sizes for Azure Machine Learning compute clusters and compute instances | |
| Deny-MachineLearning-ComputeCluster-RemoteLoginPortPublicAccess | Deny public access of Azure Machine Learning clusters via SSH | |
| Deny-MachineLearning-ComputeCluster-Scale | Enforce scale settings for Azure Machine Learning compute clusters | |
| Deny-MachineLearning-HbiWorkspace | Enforces high business impact Azure Machine Learning Workspaces | |
| Deny-MachineLearning-PublicAccessWhenBehindVnet | Deny public access behind Vnet to Azure Machine Learning workspace | |
| Deny-MachineLearning-PublicNetworkAccess | [Deprecated] Azure Machine Learning should have disabled public network access | Deprecated |
| Deny-Private-Dns-Zones | Deny the creation of private DNS | |
| Deny-PublicEndpoint-Mariadb | [Deprecated] Public network access should be disabled for MariaDB | Deprecated |
| Deny-PublicIp | [Deprecated] Deny the creation of public IP | Deprecated |
| Deny-Rdp-From-Internet | [Deprecated] RDP access from the Internet should be blocked | Deprecated, replaced by Deny-MgmtPorts-From-Internet |
| Deny-Storage-Sftp | Storage Accounts with SFTP enabled should be denied | |
| Deny-StorageAccount-CustomDomain | Storage Accounts with custom domains assigned should be denied | |
| Deny-Subnet-Without-Penp | Subnets without Private Endpoint Network Policies enabled should be denied | |
| Deny-Subnet-Without-Udr | Subnets should have a User Defined Route | |
| Deny-Udr-With-Specific-Nexthop | User Defined Routes with 'Next Hop Type' set to 'Internet' or 'VirtualNetworkGateway' should be denied | |
| Deny-Vnet-Peering | Deny vNet peering | |
| Deny-Vnet-Peering-To-Non-Approved-Vnets | Deny vNet peering to non-approved vNets | |
| Deploy-Budget | Deploy a default budget on all subscriptions under the assigned scope | |
| Deploy-Custom-Route-Table | Deploy a route table with specific user defined routes | |
| Deploy-DdosProtection | Deploy an Azure DDoS Network Protection | |
| Deploy-FirewallPolicy | Deploy Azure Firewall Manager policy in the subscription | |
| Deploy-Nsg-Flowlogs | [Deprecated] Deploys NSG flow logs and traffic analytics | Deprecated |
| Deploy-Nsg-Flowlogs-To-La | [Deprecated] Deploys NSG flow logs and traffic analytics to Log Analytics | Deprecated |
| Deploy-Sql-Tde | [Deprecated] Deploy SQL Database Transparent Data Encryption | Deprecated |
| Deploy-Sql-VulnerabilityAssessments_20230706 | Deploy SQL Database Vulnerability Assessments | |
| Deploy-Vnet-Hubspoke | Deploy Virtual Network with peering to the hub | |
| Deploy-Windows-DomainJoin | Deploy Windows Domain Join Extension with Key Vault configuration | |

## 2. ALZ, Workload Specific Compliance and Regulated Industries

The Azure Landing Zone is designed to be a flexible and scalable solution that can be used by organizations in a variety of industries. However, organizations in regulated industries (FSI, Healthcare, etc.) may need to take additional steps to ensure compliance with industry-specific regulations. These regulations often commonly have a consistent set of controls to cover, like CMK, locking down public endpoints, TLS version enforcement, logging etc.

To support the additional control requirements of these industries, we're providing the following additional initiatives that enhance the security and compliance posture of the Azure Landing Zone:

> **Please Note:** These are meant to help customers across all regulated industries (FSI, Healthcare, etc.) and not be aligned to specific regulatory controls, as there are already policy initiatives available for these via [Azure Policy](https://learn.microsoft.com/azure/azure-resource-manager/management/security-controls-policy) & [Microsoft Defender for Cloud](https://learn.microsoft.com/azure/defender-for-cloud/regulatory-compliance-dashboard)

| Initiative ID | Name | Description | # of Policies |
|------------|-------------|-------------|-------------|
| [Enforce-Guardrails-APIM](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-APIM.html) | Enforce secure-by-default API Management for regulated industries | This policy initiative is a group of policies that ensures API Management is compliant per regulated Landing Zones. | 11 |
| [Enforce-Guardrails-AppServices](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-AppServices.html) | Enforce secure-by-default App Service for regulated industries | This policy initiative is a group of policies that ensures App Service is compliant per regulated Landing Zones. | 19 |
| [Enforce-Guardrails-Automation](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-Automation.html) | Enforce secure-by-default Automation Account for regulated industries | This policy initiative is a group of policies that ensures Automation Account is compliant per regulated Landing Zones. | 6 |
| [Enforce-Guardrails-CognitiveServices](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-CognitiveServices.html) | Enforce secure-by-default Cognitive Services for regulated industries | This policy initiative is a group of policies that ensures Cognitive Services is compliant per regulated Landing Zones. | 5 |
| [Enforce-Guardrails-Compute](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-Compute.html) | Enforce secure-by-default Compute for regulated industries | This policy initiative is a group of policies that ensures Compute is compliant per regulated Landing Zones. | 2 |
| [Enforce-Guardrails-ContainerApps](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-ContainerApps.html) | Enforce secure-by-default Container Apps for regulated industries | This policy initiative is a group of policies that ensures Container Apps is compliant per regulated Landing Zones. | 2 |
| [Enforce-Guardrails-ContainerInstance](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-ContainerInstance.html) | Enforce secure-by-default Container Instance for regulated industries | This policy initiative is a group of policies that ensures Container Instance is compliant per regulated Landing Zones. | 1 |
| [Enforce-Guardrails-ContainerRegistry](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-ContainerRegistry.html) | Enforce secure-by-default Container Registry for regulated industries | This policy initiative is a group of policies that ensures Container Registry is compliant per regulated Landing Zones. | 12 |
| [Enforce-Guardrails-CosmosDb](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-CosmosDb.html) | Enforce secure-by-default Cosmos DB for regulated industries | This policy initiative is a group of policies that ensures Cosmos DB is compliant per regulated Landing Zones. | 6 |
| [Enforce-Guardrails-DataExplorer](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-DataExplorer.html) | Enforce secure-by-default Data Explorer for regulated industries | This policy initiative is a group of policies that ensures Data Explorer is compliant per regulated Landing Zones. | 4 |
| [Enforce-Guardrails-DataFactory](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-DataFactory.html) | Enforce secure-by-default Data Factory for regulated industries | This policy initiative is a group of policies that ensures Data Factory is compliant per regulated Landing Zones. | 5 |
| [Enforce-Guardrails-EventGrid](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-EventGrid.html) | Enforce secure-by-default Event Grid for regulated industries | This policy initiative is a group of policies that ensures Event Grid is compliant per regulated Landing Zones. | 8 |
| [Enforce-Guardrails-EventHub](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-EventHub.html) | Enforce secure-by-default Event Hub for regulated industries | This policy initiative is a group of policies that ensures Event Hub is compliant per regulated Landing Zones. | 4 |
| [Enforce-Guardrails-KeyVault-Sup](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-KeyVault-Sup.html) | Enforce secure-by-default Key Vault for regulated industries | This policy initiative is a group of policies that ensures Key Vault is compliant per regulated Landing Zones. This includes additional policies to supplement Enforce-Guardrails-KeyVault, which is assigned by default in ALZ. | 2 |
| [Enforce-Guardrails-Kubernetes](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-Kubernetes.html) | Enforce secure-by-default Kubernetes for regulated industries | This policy initiative is a group of policies that ensures Kubernetes is compliant per regulated Landing Zones. | 16 |
| [Enforce-Guardrails-MachineLearning](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-MachineLearning.html) | Enforce secure-by-default Machine Learning for regulated industries | This policy initiative is a group of policies that ensures Machine Learning is compliant per regulated Landing Zones. | 5 |
| [Enforce-Guardrails-MySQL](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-MySQL.html) | Enforce secure-by-default Kubernetes for regulated industries | This policy initiative is a group of policies that ensures Kubernetes is compliant per regulated Landing Zones. | 2 |
| [Enforce-Guardrails-Network](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-Network.html) | Enforce secure-by-default Network and Networking services for regulated industries | This policy initiative is a group of policies that ensures Network and Networking services is compliant per regulated Landing Zones. | 22 |
| [Enforce-Guardrails-OpenAI](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-OpenAI.html) | Enforce secure-by-default Open AI (Cognitive Services) for regulated industries | This policy initiative is a group of policies that ensures Open AI (Cognitive Services) is compliant per regulated Landing Zones. | 6 |
| [Enforce-Guardrails-PostgreSQL](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-PostgreSQL.html) | Enforce secure-by-default PostgreSQL for regulated industries | This policy initiative is a group of policies that ensures PostgreSQL is compliant per regulated Landing Zones. | 1 |
| [Enforce-Guardrails-ServiceBus](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-ServiceBus.html) | Enforce secure-by-default Service Bus for regulated industries | This policy initiative is a group of policies that ensures Service Bus is compliant per regulated Landing Zones. | 4 |
| [Enforce-Guardrails-SQL](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-SQL.html) | Enforce secure-by-default SQL and SQL Managed Instance for regulated industries | This policy initiative is a group of policies that ensures SQL and SQL Managed Instance is compliant per regulated Landing Zones. | 5 |
| [Enforce-Guardrails-Storage](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-Storage.html) | Enforce secure-by-default Storage for regulated industries | This policy initiative is a group of policies that ensures Storage is compliant per regulated Landing Zones. | 22 |
| [Enforce-Guardrails-Synapse](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-Synapse.html) | Enforce secure-by-default Synapse for regulated industries | This policy initiative is a group of policies that ensures Synapse is compliant per regulated Landing Zones. | 9 |
| [Enforce-Guardrails-VirtualDesktop](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-VirtualDesktop.html) | Enforce secure-by-default Virtual Desktop for regulated industries | This policy initiative is a group of policies that ensures Virtual Desktop is compliant per regulated Landing Zones. | 2 |

To support these initiatives we've added the following custom policies:

| Policy ID | Name | Description |
|------------|-------------|-------------|
| [Deny-APIM-TLS](https://www.azadvertizer.net/azpolicyadvertizer/Deny-APIM-TLS.html) | API Management services should use TLS version 1.2 | API Management services should use TLS version 1.2 |
| [Deny-AppGw-Without-Tls](https://www.azadvertizer.net/azpolicyadvertizer/Deny-AppGw-Without-Tls.html) | Application Gateway should be deployed with predefined Microsoft policy that is using TLS version 1.2 | This policy enables you to restrict that Application Gateways is always deployed with predefined Microsoft policy that is using TLS version 1.2 |
| [Deny-AppService-without-BYOC](https://www.azadvertizer.net/azpolicyadvertizer/Deny-AppService-without-BYOC.html) | App Service certificates must be stored in Key Vault | App Service (including Logic apps and Function apps) must use certificates stored in Key Vault |
| [Deny-AzFw-Without-Policy](https://www.azadvertizer.net/azpolicyadvertizer/Deny-AzFw-Without-Policy.html) | Azure Firewall should have a default Firewall Policy | This policy denies the creation of Azure Firewall without a default Firewall Policy. |
| [Deny-CognitiveServices-NetworkAcls](https://www.azadvertizer.net/azpolicyadvertizer/Deny-CognitiveServices-NetworkAcls.html) | Network ACLs should be restricted for Cognitive Services | Azure Cognitive Services should not allow adding individual IPs or virtual network rules to the service-level firewall. Enable this to restrict inbound network access and enforce the usage of private endpoints. |
| [Deny-CognitiveServices-Resource-Kinds](https://www.azadvertizer.net/azpolicyadvertizer/Deny-CognitiveServices-Resource-Kinds.html) | Only explicit kinds for Cognitive Services should be allowed | Azure Cognitive Services should only create explicit allowed kinds. |
| [Deny-CognitiveServices-RestrictOutboundNetworkAccess](https://www.azadvertizer.net/azpolicyadvertizer/Deny-CognitiveServices-RestrictOutboundNetworkAccess.html) | Outbound network access should be restricted for Cognitive Services | Azure Cognitive Services allow restricting outbound network access. Enable this to limit outbound connectivity for the service. |
| [Deny-EH-MINTLS](https://www.azadvertizer.net/azpolicyadvertizer/Deny-EH-MINTLS.html) | Event Hub namespaces should use a valid TLS version | Event Hub namespaces should use a valid TLS version. |
| [Deny-EH-Premium-CMK](https://www.azadvertizer.net/azpolicyadvertizer/Deny-EH-Premium-CMK.html) | Event Hub namespaces (Premium) should use a customer-managed key for encryption | Event Hub namespaces (Premium) should use a customer-managed key for encryption. |
| [Deny-LogicApp-Public-Network](https://www.azadvertizer.net/azpolicyadvertizer/Deny-LogicApp-Public-Network.html) | Logic apps should disable public network access | Disabling public network access improves security by ensuring that the Logic App is not exposed on the public internet. Creating private endpoints can limit exposure of a Logic App. Learn more at: https://aka.ms/app-service-private-endpoint. |
| [Deny-LogicApps-Without-Https](https://www.azadvertizer.net/azpolicyadvertizer/Deny-LogicApps-Without-Https.html) | Logic app should only be accessible over HTTPS | Use of HTTPS ensures server/service authentication and protects data in transit from network layer eavesdropping attacks. |
| [Deny-Service-Endpoints](https://www.azadvertizer.net/azpolicyadvertizer/Deny-Service-Endpoints.html) | Deny or Audit service endpoints on subnets | This Policy will deny/audit Service Endpoints on subnets. Service Endpoints allows the network traffic to bypass Network appliances, such as the Azure Firewall. |
| [Deny-Storage-ContainerDeleteRetentionPolicy](https://www.azadvertizer.net/azpolicyadvertizer/Deny-Storage-ContainerDeleteRetentionPolicy.html) | Storage Accounts should use a container delete retention policy | Enforce container delete retention policies larger than seven days for storage account. Enable this for increased data loss protection. |
| [Deny-Storage-CopyScope](https://www.azadvertizer.net/azpolicyadvertizer/Deny-Storage-CopyScope.html) | Allowed Copy scope should be restricted for Storage Accounts | Azure Storage accounts should restrict the allowed copy scope. Enforce this for increased data exfiltration protection. |
| [Deny-Storage-CorsRules](https://www.azadvertizer.net/azpolicyadvertizer/Deny-Storage-CorsRules.html) | Storage Accounts should restrict CORS rules | Deny CORS rules for storage account for increased data exfiltration protection and endpoint protection. |
| [Deny-Storage-LocalUser](https://www.azadvertizer.net/azpolicyadvertizer/Deny-Storage-LocalUser.html) | Local users should be restricted for Storage Accounts | Azure Storage accounts should disable local users for features like SFTP. Enforce this for increased data exfiltration protection. |
| [Deny-Storage-NetworkAclsBypass](https://www.azadvertizer.net/azpolicyadvertizer/Deny-Storage-NetworkAclsBypass.html) | Network ACL bypass option should be restricted for Storage Accounts | Azure Storage accounts should restrict the bypass option for service-level network ACLs. Enforce this for increased data exfiltration protection. |
| [Deny-Storage-NetworkAclsVirtualNetworkRules](https://www.azadvertizer.net/azpolicyadvertizer/Deny-Storage-NetworkAclsVirtualNetworkRules.html) | Virtual network rules should be restricted for Storage Accounts | Azure Storage accounts should restrict the virtual network service-level network ACLs. Enforce this for increased data exfiltration protection. |
| [Deny-Storage-ResourceAccessRulesResourceId](https://www.azadvertizer.net/azpolicyadvertizer/Deny-Storage-ResourceAccessRulesResourceId.html) | Resource Access Rules resource IDs should be restricted for Storage Accounts | Azure Storage accounts should restrict the resource access rule for service-level network ACLs to services from a specific Azure subscription. Enforce this for increased data exfiltration protection. |
| [Deny-Storage-ResourceAccessRulesTenantId](https://www.azadvertizer.net/azpolicyadvertizer/Deny-Storage-ResourceAccessRulesTenantId.html) | Resource Access Rules Tenants should be restricted for Storage Accounts | Azure Storage accounts should restrict the resource access rule for service-level network ACLs to service from the same AAD tenant. Enforce this for increased data exfiltration protection. |
| [Deny-Storage-ServicesEncryption](https://www.azadvertizer.net/azpolicyadvertizer/Deny-Storage-ServicesEncryption.html) | Encryption for storage services should be enforced for Storage Accounts | Azure Storage accounts should enforce encryption for all storage services. Enforce this for increased encryption scope. |
| [Deploy-LogicApp-TLS](https://www.azadvertizer.net/azpolicyadvertizer/Deploy-LogicApp-TLS.html) | Configure Logic apps to use the latest TLS version | Periodically, newer versions are released for TLS either due to security flaws, include additional functionality, and enhance speed. Upgrade to the latest TLS version for Function apps to take advantage of security fixes, if any, and/or new functionalities of the latest version. |
| [Modify-NSG](https://www.azadvertizer.net/azpolicyadvertizer/Modify-NSG.html) | Enforce specific configuration of Network Security Groups (NSG) | This policy enforces the configuration of Network Security Groups (NSG). |
| [Modify-UDR](https://www.azadvertizer.net/azpolicyadvertizer/Modify-UDR.html) | Enforce specific configuration of User-Defined Routes (UDR) | This policy enforces the configuration of User-Defined Routes (UDR) within a subnet. |
