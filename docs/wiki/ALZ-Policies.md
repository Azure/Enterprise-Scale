# Policies included in Azure landing zones reference implementations

Azure Policy and deployIfNotExist enables autonomy in the platform, and reduces operational burden as you scale your deployments and subscriptions in the Azure landing zone architecture. The primary purpose is to ensure that subscriptions and resources are compliant, while empowering application teams to use their own preferred tools/clients to deploy.

> Please refer to [Policy Driven Governance](https://docs.microsoft.com/en-gb/azure/cloud-adoption-framework/ready/landing-zone/design-principles#policy-driven-governance) for further information.

## Why are there custom policy definitions as part of Azure landing zones?

We work with - and learn from our customers and partners to ensure that we evolve and enhance the reference implementations to meet customer requirements. The primary approach of the policies as part of Azure landing zones is to be proactive (deployIfNotExist, and modify), and preventive (deny). We are continuously moving these policies to built-ins.

## What Azure Policies does Azure landing zone provide additionally to those already built-in?

There are around 106 custom Azure Policy Definitions included and around 7 Custom Azure Policy Initiatives included as part of the Azure Landing Zones implementation that add on to those already built-in within each Azure customers tenant.

All custom Azure Policy Definitions and Initiatives are the same across all 3 implementation options for Azure landing zones; [Terraform Module](https://aka.ms/alz/tf), [Bicep Modules](https://aka.ms/alz/bicep), [Azure landing zone portal accelerator](https://aka.ms/alz#azure-landing-zone-accelerator).

This is because the single source of truth is the [`Enterprise-Scale` repo](https://github.com/Azure/Enterprise-Scale) that both the Terraform and Bicep implementation options pull from to build their `lib` folders respectively.

For a complete list of all custom and built-in policies deployed within an Azure landing zone deployment, please refer to the following [section](https://github.com/Azure/Enterprise-Scale/blob/main/docs/ESLZ-Policies.md#what-policy-definitions-are-assigned-within-the-azure-landing-zones-custom--built-in).

> Our goal is always to try and use built-in policies where available and also work with product teams to adopt our custom policies and make them built-in, which takes time. This means there will always be a requirement for custom policies.

## AzAdvertizer Integration

We have worked with the creator of [AzAdvertizer](https://www.azadvertizer.net) to integrate all of the custom Azure Policy Definitions and Initiatives as part of Azure landing zones into it to help customers use the tool to look at the policies further in an easy to use tool that is popular in the community.

On either the [Policy](https://www.azadvertizer.net/azpolicyadvertizer_all.html#%7B%22col_10%22%3A%7B%22flt%22%3A%22ESLZ%22%7D%7D) or [Initiative](https://www.azadvertizer.net/azpolicyinitiativesadvertizer_all.html) section of the site, set the 'Type' column drop down (last one on the right hand side) to 'ALZ' and you will see all the policies as mentioned above in the tool for you to investigate further.

AzAdvertizer also updates once per day!

![AzAdvertizer ALZ Integration Slide](../media/alzPolicyAzAdvertizer.png)

## What policy definitions are assigned within the Azure landing zones (Custom & Built-in)?

As part of a default deployment configuration, policy and policy set definitions are deployed at multiple levels within the Azure landing zone Management Group hierarchy as depicted within the below diagram.

![image](../media/MgmtGroups_Policies_v0.1.jpg)

The subsequent sections will provide a summary of policy sets and policy set definitions applied at each level of the Management Group hierarchy.

> **NOTE**: Although the below sections will define which policy definitions/sets are applied at specific scopes, please remember that policy will inherit within your management group hierarchy.

### Intermediate Root

This management group is a parent to all the other management groups created within the default Azure landing zone configuration. Policy assignment is predominantly focused on assignment of security and monitoring best practices to ensure compliance and reduced operational overhead.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>
  
![image](../media/IntRoot_v0.1.jpg)
  
</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **5**     |
| `Policy Definitions`      | **1**     |
</td></tr> </table>

The table below provides the specific **Custom** and **Built-in** **policy definitions** and **policy definitions sets** assigned at the **Intermediate Root Management Group**.

| Assignment Name                                                            | Definition Name                                                                  | Policy Type                           | Description                                                                                                                                                                                                                                                                                                                                                                          | Effect(s)                           | Version |
| -------------------------------------------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------- | ------- |
| **Deploy Microsoft Defender for Cloud configuration**                      | **Deploy Microsoft Defender for Cloud configuration**                            | `Policy Definition Set`, **Custom**   | Configures all the MDFC settings, such as Microsoft Defender for Cloud per individual service, security contacts, and export from MDFC to Log Analytics workspace                                                                                                                                                                                                                    | DeployIfNotExists                   | 3.0.0   |
| **Deploy-Resource-Diag**                                                   | **Deploy Diagnostic Settings to Azure Services**                                 | `Policy Definition Set`, **Custom**   | This policy set deploys the configurations of application Azure resources to forward diagnostic logs and metrics to an Azure Log Analytics workspace.                                                                                                                                                                                                                                | DeployIfNotExists                   | 1.0.0   |
| **Enable Monitoring in Azure Security Center**                             | **Azure Security Benchmark**                                                     | `Policy Definition Set`, **Built-in** | The Azure Security Benchmark initiative represents the policies and controls implementing security recommendations defined in Azure Security Benchmark v2, see https://aka.ms/azsecbm. This also serves as the Azure Security Center default policy initiative. You can directly assign this initiative, or manage its policies and compliance results within Azure Security Center. | Audit, AuditIfNotExists, Disabled   | 49.0.0  |
| **Enable Azure Monitor for VMs**                                           | **Enable Azure Monitor for VMs**                                                 | `Policy Definition Set`, **Built-in** | Enable Azure Monitor for the virtual machines (VMs) in the specified scope (management group, subscription or resource group). Takes Log Analytics workspace as parameter                                                                                                                                                                                                            | DeployIfNotExists, AuditIfNotExists | 2.0.0   |
| **Enable Azure Monitor for Virtual Machine Scale Sets**                    | **Enable Azure Monitor for Virtual Machine Scale Sets**                          | `Policy Definition Set`, **Built-in** | Enable Azure Monitor for the Virtual Machine Scale Sets in the specified scope (Management group, Subscription or resource group). Takes Log Analytics workspace as parameter. Note: if your scale set upgradePolicy is set to Manual, you need to apply the extension to the all VMs in the set by calling upgrade on them. In CLI this would be az vmss update-instances.          | DeployIfNotExists, AuditIfNotExists | 1.0.1   |
| **Deploy Diagnostic Settings for Activity Log to Log Analytics workspace** | **Configure Azure Activity logs to stream to specified Log Analytics workspace** | `Policy Definition`, **Built-in**     | Deploys the diagnostic settings for Azure Activity to stream subscriptions audit logs to a Log Analytics workspace to monitor subscription-level events                                                                                                                                                                                                                              | DeployIfNotExists                   | 1.0.0   |

### Platform

This management group contains all the platform child management groups, like management, connectivity, and identity. There are currently no policies assigned at this management group

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>
  
![image](../media/Platform_v0.1.jpg)
  
</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **0**     |
| `Policy Definitions`      | **0**     |
</td></tr> </table>

### Connectivity

This management group contains a dedicated subscription for connectivity. This subscription will host the Azure networking resources required for the platform, like Azure Virtual WAN, Azure Firewall, and Azure DNS private zones. Policy assignment is predominantly focused on Azure DDoS Protection.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>
  
![image](../media/Connectivity_v0.1.jpg)
  
</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **0**     |
| `Policy Definitions`      | **1**     |
</td></tr> </table>

The table below provides the specific **Custom** and **Built-in** **policy definitions** and **policy definitions sets** assigned at the **Connectivity Management Group**.

| Assignment Name                                                            | Definition Name                                                            | Policy Type                       | Description                                                                                                                                                               | Effect(s) | Version |
| -------------------------------------------------------------------------- | -------------------------------------------------------------------------- | --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ------- |
| **Virtual networks should be protected by Azure DDoS Network Protection** | **Virtual networks should be protected by Azure DDoS Network Protection** | `Policy Definition`, **Built-in** | Protect your virtual networks against volumetric and protocol attacks with Azure DDoS Network Protection. For more information, visit https://aka.ms/ddosprotectiondocs. | Modify    | 1.0.0   |

### Management

This management group contains a dedicated subscription for management, monitoring, and security. This subscription will host an Azure Log Analytics workspace, including associated solutions, and an Azure Automation account. Policy assignment is predominantly focused on the deployment and configuration of the Log Analytics Workspace.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>
  
![image](../media/Management_v0.1.jpg)
  
</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **0**     |
| `Policy Definitions`      | **1**     |
</td></tr> </table>

The table below provides the specific **Custom** and **Built-in** **policy definitions** and **policy definitions sets** assigned at the **Management Management Group**.

| Assignment Name          | Definition Name                                                                                | Policy Type                       | Description                                                                                                               | Effect(s)         | Version |
| ------------------------ | ---------------------------------------------------------------------------------------------- | --------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | ----------------- | ------- |
| **Deploy-Log-Analytics** | **Configure Log Analytics workspace and automation account to centralize logs and monitoring** | `Policy Definition`, **Built-in** | Deploy resource group containing Log Analytics workspace and linked automation account to centralize logs and monitoring. | DeployIfNotExists | 2.0.0   |

### Identity

This management group contains a dedicated subscription for identity. This subscription is a placeholder for Windows Server Active Directory Domain Services (AD DS) virtual machines (VMs) or Azure Active Directory Domain Services. Policy assignment is predominantly focused on hardening and management of resources in the identity subscription.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>
  
![image](../media/Identity_v0.1.jpg)
  
</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **0**     |
| `Policy Definitions`      | **4**     |
</td></tr> </table>

The table below provides the specific **Custom** and **Built-in** **policy definitions** and **policy definitions sets** assigned at the **Identity Management Group**.

| Assignment Name                                                                                                     | Definition Name                                                                                                     | Policy Type                       | Description                                                                                                                                    | Effect(s)         | Version |
| ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ----------------- | ------- |
| **Deny the creation of public IP**                                                                                  | **Deny the creation of public IP**                                                                                  | `Policy Definition`, **Custom**   | This policy denies creation of Public IPs under the assigned scope.                                                                            | Deny              | 1.0.0   |
| **RDP access from the Internet should be blocked**                                                                  | **RDP access from the Internet should be blocked**                                                                  | `Policy Definition`, **Custom**   | This policy denies any network security rule that allows RDP access from Internet.                                                             | Deny              | 1.0.0   |
| **Subnets should have a Network Security Group**                                                                    | **Subnets should have a Network Security Group**                                                                    | `Policy Definition`, **Custom**   | This policy denies the creation of a subnet without a Network Security Group. NSG help to protect traffic across subnet-level.                 | Deny              | 2.0.0   |
| **Configure backup on virtual machines without a given tag to a new recovery services vault with a default policy** | **Configure backup on virtual machines without a given tag to a new recovery services vault with a default policy** | `Policy Definition`, **Built-in** | Enforce backup for all virtual machines by deploying a recovery services vault in the same location and resource group as the virtual machine. | DeployIfNotExists | 8.0.0   |

### Landing Zones

This is the parent management group for all the landing zone child management groups. Policy assignment is predominantly focused on ensuring workloads residing under this hierarchy are secure and compliant.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>

![image](../media/LandingZone_v0.1.jpg)

</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **1**     |
| `Policy Definitions`      | **12**    |
</td></tr> </table>

The table below provides the specific **Custom** and **Built-in** **policy definitions** and **policy definitions sets** assigned at the **Landing Zones Management Group**.

| Assignment Name                                                                                                     | Definition Name                                                                                                     | Policy Type                         | Description                                                                                                                                                                                                                                                                                                                                                                         | Effect(s)                                        | Version |
| ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ | ------- |
| **Deny or Deploy and append TLS requirements and SSL enforcement on resources without Encryption in transit**       | **Deny or Deploy and append TLS requirements and SSL enforcement on resources without Encryption in transit**       | `Policy Definition Set`, **Custom** | Description TBC                                                                                                                                                                                                                                                                                                                                                                     | Audit, AuditIfNotExists, DeployIfNotExists, Deny | 1.0.0   |
| **RDP access from the Internet should be blocked**                                                                  | **RDP access from the Internet should be blocked**                                                                  | `Policy Definition`, **Custom**     | This policy denies any network security rule that allows RDP access from Internet                                                                                                                                                                                                                                                                                                   | Deny                                             | 1.0.0   |
| **Subnets should have a Network Security Group**                                                                    | **Subnets should have a Network Security Group**                                                                    | `Policy Definition`, **Custom**     | This policy denies the creation of a subnet without a Network Security Group. NSG help to protect traffic across subnet-level.                                                                                                                                                                                                                                                      | Deny                                             | 2.0.0   |
| **Network interfaces should disable IP forwarding**                                                                 | **Network interfaces should disable IP forwarding**                                                                 | `Policy Definition`, **Built-in**   | This policy denies the network interfaces which enabled IP forwarding. The setting of IP forwarding disables Azure's check of the source and destination for a network interface.                                                                                                                                                                                                   | Deny                                             | 1.0.0   |
| **Secure transfer to storage accounts should be enabled**                                                           | **Secure transfer to storage accounts should be enabled**                                                           | `Policy Definition`, **Built-in**   | Audit requirement of Secure transfer in your storage account. Secure transfer is an option that forces your storage account to accept requests only from secure connections (HTTPS). Use of HTTPS ensures authentication between the server and the service and protects data in transit from network layer attacks such as man-in-the-middle, eavesdropping, and session-hijacking | Audit                                            | 2.0.0   |
| **Deploy Azure Policy Add-on to Azure Kubernetes Service clusters**                                                 | **Deploy Azure Policy Add-on to Azure Kubernetes Service clusters**                                                 | `Policy Definition`, **Built-in**   | Use Azure Policy Add-on to manage and report on the compliance state of your Azure Kubernetes Service (AKS) clusters.                                                                                                                                                                                                                                                               | DeployIfNotExists                                | 4.0.0   |
| **Auditing on SQL server should be enabled**                                                                        | **Auditing on SQL server should be enabled**                                                                        | `Policy Definition`, **Built-in**   | Auditing on your SQL Server should be enabled to track database activities across all databases on the server and save them in an audit log.                                                                                                                                                                                                                                        | AuditIfNotExists                                 | 2.0.0   |
| **Deploy Threat Detection on SQL servers**                                                                          | **Configure Azure Defender to be enabled on SQL servers**                                                           | `Policy Definition`, **Built-in**   | Enable Azure Defender on your Azure SQL Servers to detect anomalous activities indicating unusual and potentially harmful attempts to access or exploit databases.                                                                                                                                                                                                                  | DeployIfNotExists                                | 2.1.0   |
| **Configure backup on virtual machines without a given tag to a new recovery services vault with a default policy** | **Configure backup on virtual machines without a given tag to a new recovery services vault with a default policy** | `Policy Definition`, **Built-in**   | Enforce backup for all virtual machines by deploying a recovery services vault in the same location and resource group as the virtual machine. Doing this is useful when different application teams in your organization are allocated separate resource groups and need to manage their own backups and restores.                                                                 | DeployIfNotExists                                | 8.0.0   |
| **Virtual networks should be protected by Azure DDoS Network Protection**                                          | **Virtual networks should be protected by Azure DDoS Network Protection**                                          | `Policy Definition`, **Built-in**   | Protect your virtual networks against volumetric and protocol attacks with Azure DDoS Network Protection .                                                                                                                                                                                                                                                                          | Modify                                           | 1.0.0   |
| **Kubernetes cluster should not allow privileged containers**                                                       | **Kubernetes cluster should not allow privileged containers**                                                       | `Policy Definition`, **Built-in**   | Do not allow privileged containers creation in a Kubernetes cluster. This recommendation is part of CIS 5.2.1 which is intended to improve the security of your Kubernetes environments. This policy is generally available for Kubernetes Service (AKS), and preview for AKS Engine and Azure Arc enabled Kubernetes.                                                              | Deny                                             | 7.2.0   |
| **Kubernetes clusters should not allow container privilege escalation**                                             | **Kubernetes clusters should not allow container privilege escalation**                                             | `Policy Definition`, **Built-in**   | Do not allow containers to run with privilege escalation to root in a Kubernetes cluster. This recommendation is part of CIS 5.2.5 which is intended to improve the security of your Kubernetes environments. This policy is generally available for Kubernetes Service (AKS), and preview for AKS Engine and Azure Arc enabled Kubernetes.                                         | Audit                                            | 4.2.0   |
| **Kubernetes clusters should be accessible only over HTTPS**                                                        | **Kubernetes clusters should be accessible only over HTTPS**                                                        | `Policy Definition`, **Built-in**   | Use of HTTPS ensures authentication and protects data in transit from network layer eavesdropping attacks. This capability is currently generally available for Kubernetes Service (AKS), and in preview for AKS Engine and Azure Arc enabled Kubernetes.                                                                                                                           | Deny                                             | 6.1.0   |

### Corp

This management group is for corporate landing zones. This group is for workloads that require connectivity or hybrid connectivity with the corporate network via the hub in the connectivity subscription. Policy assignment is predominantly focused on ensuring workloads residing under this hierarchy are secure and compliant.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>

![image](../media/Corp_v0.1.jpg)

</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **2**     |
| `Policy Definitions`      | **3**     |
</td></tr> </table>

The table below provides the specific **Custom** and **Built-in** **policy definitions** and **policy definitions sets** assigned at the **Corp Management Group**.

| Assignment Name                                                | Definition Name                                                | Policy Type                         | Description                                                                                                                                                                                            | Effect(s)         | Version |
| -------------------------------------------------------------- | -------------------------------------------------------------- | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------- | ------- |
| **Public network access should be disabled for PaaS services** | **Public network access should be disabled for PaaS services** | `Policy Definition Set`, **Custom** | This policy initiative is a group of policies that prevents creation of Azure PaaS services with exposed public endpoints                                                                              | Deny              | 1.0.0   |
| **Configure Azure PaaS services to use private DNS zones**     | **Configure Azure PaaS services to use private DNS zones**     | `Policy Definition Set`, **Custom** | This policy initiative is a group of policies that ensures private endpoints to Azure PaaS services are integrated with Azure Private DNS zones                                                        | DeployIfNotExists | 1.0.0   |
| **Prevent usage of Databricks with public IP**                 | **Deny public IPs for Databricks cluster**                     | `Policy Definition`, **Custom**     | Denies the deployment of workspaces that do not use the noPublicIp feature to host Databricks clusters without public IPs.                                                                             | Deny              | 1.0.0   |
| **Enforces the use of Premium Databricks workspaces**          | **Deny non-premium Databricks sku**                            | `Policy Definition`, **Custom**     | Enforces the use of Premium Databricks workspaces to make sure appropriate security features are available including Databricks Access Controls, Credential Passthrough and SCIM provisioning for AAD. | Deny              | 1.0.0   |
| **Enforces the use of vnet injection for Databricks**          | **Deny Databricks workspaces without Vnet injection**          | `Policy Definition`, **Custom**     | Enforces the use of vnet injection for Databricks workspaces.                                                                                                                                          | Deny              | 1.0.0   |

### Online

This management group is for online landing zones. This group is for workloads that might require direct internet inbound/outbound connectivity or for workloads that might not require a virtual network. There are currently no policies assigned at this management group.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>

![image](../media/Online_v0.1.jpg)

</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **0**     |
| `Policy Definitions`      | **0**     |
</td></tr> </table>

### Decommissioned

This management group is for landing zones that are being cancelled. Cancelled landing zones will be moved to this management group before deletion by Azure after 30-60 days. There are currently no policies assigned at this management group.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>

![image](../media/Decom_v0.1.jpg)

</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **0**     |
| `Policy Definitions`      | **0**     |
</td></tr> </table>

### Sandbox

This management group is for subscriptions that will only be used for testing and exploration by an organization. These subscriptions will be securely disconnected from the corporate and online landing zones. Sandboxes also have a less restrictive set of policies assigned to enable testing, exploration, and configuration of Azure services. There are currently no policies assigned at this management group.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>

![image](../media/Sandbox_v0.1.jpg)

</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **0**     |
| `Policy Definitions`      | **0**     |
</td></tr> </table>