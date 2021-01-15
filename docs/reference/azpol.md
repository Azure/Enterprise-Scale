# How does Azure Policies in Enterprise-scale Landing Zone help?

Azure Policy makes it possible to *codify* enterprise governance requirements. Enterprise Scale Landing zone implementation extensively uses Azure Policies to make it easy to put into practice various guard rail measures necessary to meet operational and management requirements.  Azure Policies in Enterprise Scale landing zone are discussed in details below.

## Prevent Public IP based services

Most of the Azure Platform-as-a-service (PaaS) services are created with a public IP address assigned to them. This is a good option for developers who want to quickly get started with these services. Public endpoint accelerates learning curve and is ideal when developing pilots and small-scales Proof Of Concept (PoC) implementations.

However, when these pilots/PoCs make transition to production-ready enterprise applications, their use of public IP addresses is sometimes overlooked.

Production workloads using public IPs without proper security measures in place can increase security risks. Malicious actors can potentially use public IP as a gateway to launch an attack. Many enterprise compliance policies do not allow use of public IP just to avoid exposure to such security risks.

**Deny-PublicIP** policy prevents pubic IP getting created in a scope targeted by policy. Enterprises can easily prevent Virtual Machines (VMs) getting created with public IP using this policy.

**Deny-Public-Endpoints-for-PaaS-Services** Policy Initiative (also referred as PolicySet) helps enterprises prevent prevents Azure services getting created with a public IP address in the first place. *Deny-Public-Endpoints-for-PaaS-Services* Policy Initiative consists of following policies.

    Deny-PublicEndpoint-CosmosDB
    Deny-PublicEndpoint-MariaDB
    Deny-PublicEndpoint-MySQL
    Deny-PublicEndpoint-PostgreSql
    Deny-PublicEndpoint-KeyVault
    Deny-PublicEndpoint-Sql
    Deny-PublicEndpoint-Storage
    Deny-PublicEndpoint-Aks

*Deny-Public-Endpoints-for-PaaS-Services* and *Deny-PublicIP* policies prevent major Azure services such as VMs, CosmosDB, SQL, AKS, etc. being exposed over a public IP.

## Enforce audit and log information collection

Lack of auditing and diagnostics information at granular level can impact operational practices. Incomplete audit information makes it difficult to correlate logs from multiple Azure services and form a coherent debugging experience.

It is desirable that once Azure services are provisioned, they provide detailed information about Azure platform they interact with.
Such information can be broadly divided into logs and metrics. Each Azure service can be further categorized into its sub-components (e.g. An Azure Public IP resource has `DDoSProtectionNotifications`, `DDoSMitigationReports` and `DDoSMitigationFlowLogs` as its sub-components. Collecting diagnostic information at these sub-categories can greatly enhance auditing and debugging experience.

 **Deploy-Diag-LogAnalytics** Policy Initiative provides an easy option to enforce logs and metrics collection at a deeper level.Azure Policies which are part *Deploy-Diag-LogAnalytics Policy Initiative* can help enterprises gather logs and metrics as shown below.

| Policy Name  | Log Categories           |Metrics        |
|:-------------|:------------------------|:----------------|
Deploy-Diagnostics-AA|JobLogs JobStreams DscNodeStatus|AllMetrics
Deploy-Diagnostics-ACI||AllMetrics
Deploy-Diagnostics-ACR||AllMetrics
Deploy-Diagnostics-ActivityLog|Administrative Security ServiceHealth Alert Recommendation Policy Autoscale ResourceHealth|
Deploy-Diagnostics-AKS|kube-audit kube-apiserver kube-controller-manager kube-scheduler cluster-autoscaler|AllMetrics
Deploy-Diagnostics-AnalysisService|Engine Service|AllMetrics
Deploy-Diagnostics-APIMgmt|GatewayLogs|Gateway Requests Capacity EventHub Events
Deploy-Diagnostics-ApplicationGateway|ApplicationGatewayAccessLog ApplicationGatewayPerformanceLog ApplicationGatewayFirewallLog|AllMetrics
Deploy-Diagnostics-Batch|ServiceLog|AllMetrics
Deploy-Diagnostics-CDNEndpoints|CoreAnalytics|
Deploy-Diagnostics-CognitiveServices|Audit RequestResponse|AllMetrics
Deploy-Diagnostics-CosmosDB|DataPlaneRequests MongoRequests QueryRuntimeStatistics|Requests
Deploy-Diagnostics-DataFactory|ActivityRuns PipelineRuns TriggerRuns|AllMetrics
Deploy-Diagnostics-DataLakeStore|Audit Requests|AllMetrics
Deploy-Diagnostics-DLAnalytics|Audit Requests|AllMetrics
Deploy-Diagnostics-EventGridSub||AllMetrics
Deploy-Diagnostics-EventGridTopic||AllMetrics
Deploy-Diagnostics-EventHub|ArchiveLogs OperationalLogs AutoScaleLogs|AllMetrics
Deploy-Diagnostics-ExpressRoute|PeeringRouteLog|AllMetrics
Deploy-Diagnostics-Firewall|AzureFirewallApplicationRule AzureFirewallNetworkRule AzureFirewallDnsProxy|AllMetrics
Deploy-Diagnostics-HDInsight||AllMetrics
Deploy-Diagnostics-iotHub|Connections DeviceTelemetry C2DCommands DeviceIdentityOperations FileUploadOperations Routes D2CTwinOperations C2DTwinOperations TwinQueries JobsOperations DirectMethods E2EDiagnostics Configurations|AllMetrics
Deploy-Diagnostics-KeyVault|AuditEvent|AllMetrics
Deploy-Diagnostics-LoadBalancer|LoadBalancerAlertEvent LoadBalancerProbeHealthStatus|AllMetrics
Deploy-Diagnostics-LogicAppsISE|IntegrationAccountTrackingEvents|
Deploy-Diagnostics-LogicAppsWF|WorkflowRuntime|AllMetrics
Deploy-Diagnostics-MlWorkspace|AmlComputeClusterEvent AmlComputeClusterNodeEvent AmlComputeJobEvent AmlComputeCpuGpuUtilization AmlRunStatusChangedEvent|Run Model Quota Resource
Deploy-Diagnostics-MySQL|MySqlSlowLogs|AllMetrics
Deploy-Diagnostics-NetworkSecurityGroups|NetworkSecurityGroupEvent NetworkSecurityGroupRuleCounter|
Deploy-Diagnostics-NIC||AllMetrics
Deploy-Diagnostics-PostgreSQL|PostgreSQLLogs|AllMetrics
Deploy-Diagnostics-PowerBIEmbedded|Engine|AllMetrics
Deploy-Diagnostics-PublicIP|DDoSProtectionNotifications DDoSMitigationFlowLogs DDoSMitigationReports|AllMetrics
Deploy-Diagnostics-RecoveryVault|CoreAzureBackup AddonAzureBackupAlerts AddonAzureBackupJobs AddonAzureBackupPolicy AddonAzureBackupProtectedInstance AddonAzureBackupStorage|
Deploy-Diagnostics-RedisCache||AllMetrics
Deploy-Diagnostics-Relay||AllMetrics
Deploy-Diagnostics-SearchServices|OperationLogs|AllMetrics
Deploy-Diagnostics-ServiceBus|OperationalLogs|AllMetrics
Deploy-Diagnostics-SignalR||AllMetrics
Deploy-Diagnostics-SQLDBs|SQLInsights AutomaticTuning QueryStoreRuntimeStatistics QueryStoreWaitStatistics Errors DatabaseWaitStatistics Timeouts Blocks Deadlocks SQLSecurityAuditEvents|AllMetrics
Deploy-Diagnostics-SQLElasticPools||AllMetrics
Deploy-Diagnostics-SQLMI|ResourceUsageStats SQLSecurityAuditEvents|
Deploy-Diagnostics-StreamAnalytics|Execution Authoring|AllMetrics
Deploy-Diagnostics-TimeSeriesInsights||AllMetrics
Deploy-Diagnostics-TrafficManager|ProbeHealthStatusEvents|AllMetrics
Deploy-Diagnostics-VirtualNetwork|VMProtectionAlerts|AllMetrics
Deploy-Diagnostics-VM||AllMetrics
Deploy-Diagnostics-VMSS||AllMetrics
Deploy-Diagnostics-VNetGW|GatewayDiagnosticLog IKEDiagnosticLog P2SDiagnosticLog RouteDiagnosticLog RouteDiagnosticLog TunnelDiagnosticLog|AllMetrics
Deploy-Diagnostics-WebServerFarm||AllMetrics
Deploy-Diagnostics-Website||AllMetrics
|<img width=250/>|<img width=50/>|<img width=40/>|

## Provide comprehensive security for SQL Databases

SQL databases are prevalent Azure service in most Azure deployments. Unfortunately, they are also prime target for malicious activities from within and outside of an enterprise.

**Deploy-Sql-Security** Policy Initiative helps protect Azure SQL databases using a set of following policies.

### Encrypt SQL data at rest

SQL database and its backups are prone to risks of getting into hands of malicious actors. It's very easy to restore SQL database from either database files or backup. Without proper defence system in place, malicious actors can have access to all the data.

Ensuring that SQL database is encrypted at rest is one of the first steps towards building SQL database defence strategy. Azure SQL database Transparent Data Encryption (TDE) ensures that data is encrypted at rest without needing any application code level change.

A SQL database with TDE enabled makes it hard for malicious actors to get access to data it holds even if its compromised.

As Azure SQL database deployments within an enterprise increases, it is very important that governance around ensuring Azure SQL databases are created with TDE enabled is in place.

**Deploy-Sql-Tde** policy ensures that Azure SQL databases have TDE enabled.

### Enforce alerts for suspicious activity

Bad actors are on the constant lookout to access and exploit business-critical Azure SQL databases. Risk of such attempts going unnoticed can reduce an enterprise's ability to detect and respond to them. In worst case scenario, an enterprise may never know if its SQL database has been compromised.

Azure SQL database provides way to set up security alerts that can report suspicious activities on SQL server. Such alert sends email a to pre-configured email addresses and optionally to Azure subscription admins and owners.

**Deploy-Sql-SecurityAlertPolicies** helps to enforce enabling of security alerts on Azure SQL databases. Enterprise can benefit from identifying malicious activities such as SQL injection attack, brute force attack, etc. though these alert. Security alerts provide detailed information about every incident. This detailed information is surfaced in Azure portal as well as email message triggered.

### Enforce audit trail of operations

A business-critical Azure SQL database can be subject to a large number of DML (Data Manipulation Language), DCL (Data Control Language) and DDL (Data Definition Language) commands as part of day to day operations. Without a clear control and insight into these operational activities, its challenging to distinguish between legitimate and suspicious operations.

Enabling SQL Auditing can help in gathering important information about all database activities. Its also a requirement for many industry/regional regulatory compliance requirements. SQL Auditing helps generating and reporting audit trail of database events.

**Deploy-Sql-AuditingSettings** helps in enforcing Azure SQL Database Auditing. This policy audits and reports key database events such as ownership changes, successful/failed logins, role membership changes, schema changes, etc. Enterprises can use this policy and audit trail it generates to gain rich insights into database operations and comply with industry/regional regulatory requirements.

### Enforce evaluation against proven best practices

Throughout it's lifecycle, Azure SQL database undergoes very large number of schema, permission and configuration changes. There is always a risk of such changes resulting in deviation from best practices. Excessive permissions, orphaned roles and many such configurational drifts can be exploited by malicious actors.

Azure SQL database has built-in vulnerability assessment service.  State of Azure SQL database through the lense of Microsoft's best practices for SQL database can be evaluated using vulnerability assessment. A vulnerability assessment scan identifies database and server level security risks. A remediation task in applicable scenario may be also generated to fix the vulnerability.

**Deploy-Sql-vulnerabilityAssessments** policy ensures that Azure SQL databases are configured with vulnerability assessment. The assessment scans are performed periodically and reports are stored in Azure storage account. Pre-defined email address is used to share the results of periodic scan results for reporting purposes.

## Protect against intentional/unintentional secret deletion

Azure Key Vault is a service to store confidential information such as keys, certificates, passwords, etc. A malicious user can potentially abuse Azure Key Vault service by deleting secrets stored inside it. It is also quite likely that a user may accidentally delete sensitive information stored in Azure Key Vault. Without proper provisions in place, either malicious or accidental deletion in Azure Key Vault can cause significant business harm.

Azure Key Vault provides protection against intentional or unintentional deletion of contents stored inside it through soft-delete feature. When soft-delete is enabled, deleted keys will be retained for a pre-configured time period. If the delete operation was unintentional then deleted key can be restored within pre-configured time window. If the delete operation was intentional then key content can be deleted until an additional *purge* operation is performed - typically by someone with higher privileges.

**Append-KV-SoftDelete** policy ensures that Azure Key vault is enabled with soft-delete feature by default. Enterprises get better control on deletion of Azure Key Vault content for unintentional operations. *Append-KV-SoftDelete* policy provides an additional security layer for malicious deletion of Azure Key Vault content.

## Enforce Web Application Firewall (WAF)

Web applications running on Azure are potential targets of number of malicious attacks. [Top 10 common attacks](https://owasp.org/www-project-top-ten/) - such as - injection, cross-site scripting, etc. try to exploit known vulnerabilities typically associated with web applications. Consequences of a successful attack can be very costly and may impact brand value negatively.

Azure Application Gateway Web Application Firewall (WAF) provides protection against common attacks on web applications. It implements Core Rule Set (CRS) 3.1, 3.0 or 2.2.9 as recommended by the Open Web Application Security Project (OWASP). WAF policies can be associated with Azure Application Gateway either in *Prevention* or *Detection* mode.

**Deny-AppGW-Without-WAF** policy helps in preventing potential misconfiguration on Azure Application Gateway. It enforces Azure Application Gateway can't be created without a Web Application Firewall (WAF). Web Applications running on Azure and using Azure Application Gateway are guaranteed to be protected by Web Application Firewall (WAF) on Azure Application Gateway.

## Prevent IP forwarding on VMs

IP forwarding enables Azure VM to route traffic it receives to other destinations. Unless explicitly required, such routing may potentially expose a VM with public IP address as a router. Other unintended networks can be reached via VM-turned-router with IP forwarding.

Azure provides an option to configure IP forwarding on Virtual Machines (VMs). This enables specialized softwares such as firewalls, load balancers, etc. to be deployed via Azure Marketplace. Any application that may need to use these services, can use them via Azure Marketplace transaction.

However, outside of specific needs, IP forwarding on VMs may become a security liability. **Deny-IP-forwarding** policy helps in preventing VMs acting as IP forwarding routers. This policy is explicitly applied at landing zone scope. VMs in landing zone should be final destinations for user requests. Any routing should be implemented in the connectivity subscriptions.

## Enforce centralized DNS record management

Azure Private DNS Zones help create and manage DNS records for Azure resources. Uncontrolled proliferation of Azure Private Zones can result in management & network connectivity debugging issues. In hybrid environments where connectivity from on-premise sites to Azure resources is desired, fragmented DNS zones can result in duplication of DNS records and associated maintenance challenges.

Azure Private DNS Zone can be deployed centrally for easier management of DNS records. Azure Virtual Network linked with Azure Private Zone can potentially run domain controllers which facilitates streamlined connectivity from on-premise sites. Azure services which support Private Link/Endpoint can leverage centrally managed Azure Private Zone and prevent having to create them per application deployment.

**Deny-Private-DNS-Zones** policy helps in preventing creation of Azure Private DNS Zone in the scope over which it is applied. Enterprises can view compliance status against this policy even when the policy enforcement is disabled. *Deny-Private-DNS-Zones* policy helps in streamlining connectivity from on-premise sites as well as access to Azure PaaS services using Private Link/Endpoint.

## Enforce network traffic control

An Azure Virtual Network (VNet) can be segmented into multiple Subnets. By default, there is no network access control between these subnets. Lack of network access control can result in unsolicited network traffic arriving inside a subnet.

Azure Network Security Group (NSG) helps is filtering incoming traffic to and from a subnet. NSGs can allow or deny network traffic based on stateful packet inspection. Any resources inside subnet can receive traffic from only allowed IP address range(s).

**Deny-Subnet-Without-Nsg** policy ensures that every subnet has a NSG associated with it. A combination of subnet and NSG ensures that a default set of rules controls traffic to and from a subnet. Enterprises can add/modify rules to control traffic further based on the needs.

## Detect and protect against security threats by using Azure Security Center

An Azure subscription can hold multiple types of resource (e.g. VMs, Container Images, etc.) These resources are exposed to risks such as malware/unwanted software installation, uncontrolled access to management ports on a VM, etc. With security attacks getting ever sophisticated and a limited-supply of experienced security professionals, detecting security vulnerabilities and protecting workloads is extremely challenging.

Azure Security Center is Azure's native security management system which assesses Azure resources for their security posture against security best practices.  Azure security center helps to detect and prevent threats against data and application services. With multiple integration points, Azure Security center can be deployed very quickly.

**Deploy-ASC-Standard** policy helps in enrolling Azure subscription(s) with Azure Security Center Standard mode which enables those subscription(s) to start getting security threat detection and protection capabilities offered by Azure Security Center. *Deploy-ASC-Standard* policy also ensures that key Azure services such as VMs, Storage Accounts and seven other services are automatically covered by Azure Security Center. Enterprises benefits from continuous security assessment and actionable recommendations should there be any deviation from security best practice.

## Protect against ransomware attacks and other data-loss related issues

Increasing frequency of ransomware & intrusion attacks pose yet another concern for enterprises. A successful ransomware attack can disrupt business-critical processes and applications. Attackers are known to hold enterprises as hostage for huge amounts of money.

Azure Backup provides protection for Azure VMs against accidental or intentional data destruction. Azure Backups are easy to configure and scale. Data is backed up in Azure Recovery Vault for easy management and protection.

**Deploy-AzureBackup-on-VM** policy protects Azure VMs by configuring Azure Backup for them. *Deploy-AzureBackup-on-VM* policy automatically provisions Azure Recovery Services Vault and creates backup container for every Azure VM that gets created.

## Protect against DDoS attacks

Any publically reachable Azure resource is exposed to threat of Distributed Denial of Service (DDoS) attack. A successful DDoS attack can impact the application's availability to it's intended users. A prolonged DDoS attack can exhaust all available resources and result in downtime for business-critical application(s).

Azure DDoS Protection service defends Azure resources against DDoS attacks. Azure DDoS Protection continuously monitors incoming traffic to identify potential indications of a DDoS attack. Enterprises benefit from working with Microsoft's DDoS Rapid Response (DRR) team during an active attack.

**Deploy-DDoSProtection** policy automatically provisions Azure DDoS Standard plan on all Azure subscriptions under its scope. *Deploy-DDoSProtection* policy enables enterprises to select the Azure regions to be covered as part of the assignment.  

## Auto-provision Private Link/Endpoint with Private DNS Zone

Azure Private Link and Azure Private Endpoint provide access to Azure Platform-as-a-service (PaaS) services using private IP addresses. However, Azure Private DNS Zone is needed for DNS record resolution. Creation of Azure Private Zones for every application that needs to access Azure PaaS services is a management and maintenance challenge.

Azure Private DNS Zone Group helps is grouping the Private Link connections by Azure Services (blob, queue, table, sql, etc.) using an Azure Private Zone per service.

Enterprises can create central Azure Private Zones and policies discussed below will auto-provision connections between Private Link/Endpoint and Private DNS Zone.

| Policy Name  |Azure Service    |
|:-------------|:----------------|
Deploy-DNSZoneGroup-For-Blob-PrivateEndpoint|Azure Storage Blob
Deploy-DNSZoneGroup-For-File-PrivateEndpoint|Azure Storage File
Deploy-DNSZoneGroup-For-Queue-PrivateEndpoint|Azure Storage Queue
Deploy-DNSZoneGroup-For-Table-PrivateEndpoint|Azure Storage Table
Deploy-DNSZoneGroup-For-KeyVault-PrivateEndpoint|Azure KeyVault
Deploy-DNSZoneGroup-For-Sql-PrivateEndpoint|Azure SQL Database

## Centrally manage firewall rules

Fragmented firewall rules can lead to uncontrolled and ambiguous network traffic paths. Continuous changes in the firewalls rules for every instance of firewall makes it difficult to assess the network security posture. Multiple rules makes it impossible to distinguish between centrally managed basic set of rules and workload specific network path rules.

Azure Firewall Policy helps to define basic minimum set of rules applicable throughout an enterprise. Application specific policy can inherit from basic rules to allow creation of hierarchial rules to meet both enterprise as well as application specific firewall rule requirements. When rules are configured through policies then they can be centrally managed and monitored.

**Deploy-FirewallPolicy** policy enables enterprises to define Azure Firewall policies centrally. Enterprises are in control of defining priority as well as rules to meet their network traffic routing requirements. By defining firewall policies centrally, enterprises can apply them to either Azure Virtual WAN or Azure Hub and Spoke Networking topology depending upon needs.

## Provision Hub and Spoke Network topology

As more workloads starts to get deployed in Azure, they start to use a common set of services such as firewall, vpn gateways, etc. If not carefully planned, common services deployment gets replicated per application deployment resulting not only in unnecessary costs but also operational overhead. In scenarios, where on-premise connectivity is needed from Azure, network topology becomes difficult to maintain as this connectivity is established per application deployment.

Azure Hub and Spoke network topology streamlines the network connectivity needs. A Hub Virtual Network (VNet) can host the shared services while spoke VNets can host application specific Azure resources. Hub and Spoke VNets are connected with each other via VNet Peering. Hub and Spoke network topology promotes clean network design, easier management and cost optimization.

**Deploy-HUB** policy auto-provisions Hub VNet with Azure Firewall, VPN Gateway and ExpressRoute (ER) Gateway. Enterprises can configure all the options for Firewall, VPN and ER gateway as part of the policy assignment. *Deploy-HUB* policy simplifies the process to deploy Azure Hub and Spoke network topology.

**Deny-VNetPeering** policy prevents two Virtual Networks (VNets) peered with each other as they can communicate with each other via Huv VNet. By forcing VNets to communicate with each other through Hub makes it possible to control and monitor network connections. Network topology is simplified from overall maintenance perspective as well. 

## Provision default configuration for Azure Monitor

Inability to identify and visualize relationship between Azure platform, Azure service(s) and Azure application(s) may result into an outage or degraded performance going undetected. Operations or Support team may miss an opportunity to take corrective action to a specific condition. Azure application may not scale itself to respond to either surge or slump in the demand.

Azure Monitor Logs along with Azure Log Analytics Workspace help enterprises in dealing with critical conditions using Alerts. Combined together, Azure Monitor Logs and Log Analytics Workspace, empower enterprises to visualize and interact with rich set of log information through dashboards, workbooks and Power BI. Enterprises can use Azure Monitor Logs and Log Analytics Workspace together to configure auto-scaling on VMs to automatically adding or removing instances.

**Deploy-LA-Config** policy helps in configuring Log Analytics Workspace with Azure Monitor. *Deploy-LA-Config* policy deploys pre-packaged dashboard reports referred as Azure Monitor Solutions for specific Azure services such as Azure SQL Database or Azure Active Directory. *Deploy-LA-Config* policy also configures data sources such as Linux and Windows VM Performance metrics with Azure Monitor.

## Enable Log Storage and Querying

If not carefully planned, log information coming from multiple sources is Azure can easily become unwieldy. Capturing, storing and managing logs can consume plenty of resources, time and costs. Identifying trends or patterns over a long period of time and over huge amount of logs can become challenging.

Azure Log Analytics enables enterprises to store and manage logs from multiple sources efficiently. Querying the data stored in Azure Log Analytics for trend or pattern analysis is very easy with Azure Log Analytics. Alerts or interactive reports can be created using Azure Log Analytics queries.

**Deploy-Log-Analytics** policy creates Azure Log Analytics Workspace which acts as a repository to store log data. An Azure Automation Account is also created and linked with Log Analytics Workspace for automating tasks or deploying Azure Monitor Solutions which may have dependency on Log Analytics Workspace. *Deploy-Log-Analytics* policy helps in configuring properties such as log retention period, azure region, etc.

## Provision logging for Azure-Arc enabled Linux servers

With IT estates spanning multiple clouds, on-premise sites and edge locations, many enterprises may be struggling to manage and govern servers which are scattered across environments and geographic locations. Using multitude of products to monitor servers can be a jarring experience. Putting servers in multiple environments under a single unified access and identity management solution can be challenging to set up and manage.

Azure Arc simplifies governance and management of resources such as servers, kubernetes clusters and data services across heterogeneous environments. By projecting hybrid resources as native Azure resources, Azure Arc provides a single pane of control for management of native as well as hybrid resources. Azure Arc brings native as well as hybrid resources under a single unified RBAC solution.

**Deploy-LX-Arc-Monitoring** policy helps enterprises setting up Log Analytics agent on Azure Arc enabled Linux servers. A Log Analytics Workspace is also configured to store and manage logs. When assigned successfully, policy returns the the name of Linux server(s) within the scope of policy which is configured with Log Analytics agent on it.

## Enforce Network Traffic Log collection

While Azure Virtual Network (VNet) and Subnet provide a logical private network boundary, it is still essential to monitor the network traffic in Azure. Without proper network monitoring, enterprises are exposed to the risk of undesired or unknown traffic coming to Azure networks from compromised IP addresses. It becomes challenging to provision additional capacity for any increase in the network traffic without understanding the current traffic.

Azure Network Watcher provides a way to monitor and if necessary repair any network issue related to IaaS services in Azure. Network Security Group (NSG) flow logs provides a way to capture information about network traffic traversing through NSG. Enterprises can benefit from traffic analysis & patterns, forecast future capacity needs and enforce compliance against corporate governance policies.

**Deploy-Nsg-FlowLogs** policy helps in setting up Azure Network Watcher NSG flow logs. An Azure STorage Account is provisioned as repository to store NSG flow logs. *Deploy-Nsg-FlowLogs* policy also configuring the retention period to store the NSG flow logs.  

## Provision at-scale network connectivity solution

Network connectivity requirements for an enterprise can be complex. Constant requests for adding New sites, devices and users to ever-expanding network are very challenging to provision and manage. Network bandwidth and throughput demands by multiple touch-points within an enterprise can be very demanding.

Azure Virtual WAN (vWAN) is an enterprise-grade network service aimed towards addressing any-to-any connectivity challenges. Azure vWAN provides higher aggregate throughput with network connectivity. It provides optimal routing over Azure backbone as well as a unified management experience from Azure.

**Deploy-vWAN** policy enables setting up a Azure vWAN.
**Deploy-vHUB** policy helps in provisioning Azure vWAN hub inside vWAN. Enterprises can deploy a Virtual Hub which acts as a central point for connections from multiple sources and destinations. ExpressRoute, VPN gateways and Azure Firewall is also provisioned to address any-to-any network connectivity requirements.  

## Provision backup for Azure VMs

As cloud adoption increases, enterprise face challenges of ensuring that workloads running in Azure are backed up. Conventional IT support model where app development and IT operations are managed by separate Teams, sometimes leaves the door open for unclear ownership of VM backups. In either intentional or unintentional scenario which requires VM backups for workload restoration, missing backup process can result in costly consequences.

Azure Backup provides a seamless, easy and integrated option for backing up VMs running either in Azure or in on-premise sites. Azure Backup leverages cloud scale storage and frees enterprises from having to constantly procure and manage storage needed for backups. Azure Backup provides a repository to store data securely in transit as well as at-rest.

**Deploy-VM-Backup** policy automatically configures Azure backup protection for Windows as well as Linux VMs. A Recovery Service Vault is configured for storing backup which securely stores data as well as provides protection against malicious deletion of backup through soft delete. A default backup policy is created and assigned with pre-configured values for backup schedule, backup retention period, etc.

## Provision connectivity between Virtual Networks (VNets)

It is very common to have workloads scattered across multiple subscriptions or virtual networks (VNets) in an enterprise. Without a dedicated and secure network connectivity between them, critical business applications will struggle with data exchange. An internet-based network connectivity will pose inconsistent network bandwidth and performance. Potential high network latency may impact user experience adversely.

Azure Virtual Network Peering provides network connectivity between two virtual networks (VNets) over Microsoft backbone network. Azure Peering enables high-bandwidth low-latency network connectivity. Data can be exchanged securely between separate Azure subscriptions, tenants or Azure regions.

**Deploy-vNet** policy provides a template for setting up Virtual Network Peering. A network layout expressed in ARM template definition can be passed as a parameter. *Deploy-vNet* policy will spin up Virtual Networks and configure VNet Peering between them along with dependencies such as NSG, UDR, etc.

## Enforce Windows VMs to join AD Domain

Enterprises have been using domain joined VMs for a consistent management experience. When operations such as corporate password policy, central authentication, etc. are created as part of domain policies, a VM which does not join the domain, is exposed to risks such as weak password, inability to connect with corporate devices, applications, etc. Legacy applications which rely upon authentication protocols such as NTLM, Kerberos may face authentication issues when deployed on VMs which are not domain joined.

Azure provides managed as well as un-managed solutions for implementing domain services. With self-managed Active Directory Domain Services (AD DS) in Azure, enterprises get complete control on the setup, configuration and operations just same as in an on-premise environment. Azure Active Directory Domain Service (AAD DS) takes away all the management overhead away from enterprises while still providing essential domain services.

**Deploy-Windows-DomainJoin** policy ensures that any newly created Windows VM automatically joins the domain. An extension - *JsonADDomainExtension* - is deployed on the VM which uses other configuration settings such as username, domain, OUPath, etc. to ensure that VM joins the specified domain. *Deploy-Windows-DomainJoin* policy uses Azure KeyVault to manage confidential information such as domain username and password.