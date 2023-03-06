# Policies included in Azure landing zones reference implementations

Azure Policy and deployIfNotExist enables autonomy in the platform, and reduces operational burden as you scale your deployments and subscriptions in the Azure landing zone architecture. The primary purpose is to ensure that subscriptions and resources are compliant, while empowering application teams to use their own preferred tools/clients to deploy.

> Please refer to [Policy Driven Governance](https://learn.microsoft.com/en-gb/azure/cloud-adoption-framework/ready/landing-zone/design-principles#policy-driven-governance) for further information.

## Why are there custom policy definitions as part of Azure landing zones?

We work with - and learn from our customers and partners to ensure that we evolve and enhance the reference implementations to meet customer requirements. The primary approach of the policies as part of Azure landing zones is to be proactive (deployIfNotExist, and modify), and preventive (deny). We are continuously moving these policies to built-ins.

## What Azure Policies does Azure landing zone provide additionally to those already built-in?

There are around 106 custom Azure Policy Definitions included and around 7 Custom Azure Policy Initiatives included as part of the Azure Landing Zones implementation that add on to those already built-in within each Azure customers tenant.

All custom Azure Policy Definitions and Initiatives are the same across all 3 implementation options for Azure landing zones; [Terraform Module](https://aka.ms/alz/tf), [Bicep Modules](https://aka.ms/alz/bicep), [Azure landing zone portal accelerator](https://aka.ms/alz#azure-landing-zone-accelerator).

This is because the single source of truth is the [`Enterprise-Scale` repo](https://github.com/Azure/Enterprise-Scale) that both the Terraform and Bicep implementation options pull from to build their `lib` folders respectively.

For a complete list of all custom and built-in policies deployed within an Azure landing zone deployment, please refer to the following [section](https://github.com/Azure/Enterprise-Scale/wiki/ALZ-Policies#what-policy-definitions-are-assigned-within-the-azure-landing-zones-custom--built-in).

> Our goal is always to try and use built-in policies where available and also work with product teams to adopt our custom policies and make them built-in, which takes time. This means there will always be a requirement for custom policies.

## AzAdvertizer Integration

We have worked with the creator of [AzAdvertizer](https://www.azadvertizer.net) to integrate all of the custom Azure Policy Definitions and Initiatives as part of Azure landing zones into it to help customers use the tool to look at the policies further in an easy to use tool that is popular in the community.

On either the [Policy](https://www.azadvertizer.net/azpolicyadvertizer_all.html#%7B%22col_10%22%3A%7B%22flt%22%3A%22ESLZ%22%7D%7D) or [Initiative](https://www.azadvertizer.net/azpolicyinitiativesadvertizer_all.html) section of the site, set the 'Type' column drop down (last one on the right hand side) to 'ALZ' and you will see all the policies as mentioned above in the tool for you to investigate further.

AzAdvertizer also updates once per day!

![AzAdvertizer ALZ Integration Slide](./media/alzPolicyAzAdvertizer.png)

## What policy definitions are assigned within the Azure landing zones (Custom & Built-in)?

As part of a default deployment configuration, policy and policy set definitions are deployed at multiple levels within the Azure landing zone Management Group hierarchy as depicted within the below diagram.

![image](./media/MgmtGroups_Policies_v0.1.jpg)

The subsequent sections will provide a summary of policy sets and policy set definitions applied at each level of the Management Group hierarchy.

> **NOTE**: Although the below sections will define which policy definitions/sets are applied at specific scopes, please remember that policy will inherit within your management group hierarchy.

### Intermediate Root

This management group is a parent to all the other management groups created within the default Azure landing zone configuration. Policy assignment is predominantly focused on assignment of security and monitoring best practices to ensure compliance and reduced operational overhead.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>
  
![image](./media/IntRoot_v0.1.jpg)
  
</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **6**     |
| `Policy Definitions`      | **2**     |
</td></tr> </table>

The table below provides the specific **Custom** and **Built-in** **policy definitions** and **policy definitions sets** assigned at the **Intermediate Root Management Group**.

| Assignment Name                                                            | Definition Name                                                                  | Policy Type                           | Description                                                                                                                                                                                                                                                                                                                                                                          | Effect(s)                           | Version |
| -------------------------------------------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------- | ------- |
| **Deploy Microsoft Defender for Cloud configuration**                      | **Deploy Microsoft Defender for Cloud configuration**                            | `Policy Definition Set`, **Custom**   | Configures all the MDFC settings, such as Microsoft Defender for Cloud per individual service, security contacts, and export from MDFC to Log Analytics workspace                                                                                                                                                                                                                    | DeployIfNotExists                   | 3.0.0   |
| **Deploy-Resource-Diag**                                                   | **Deploy Diagnostic Settings to Azure Services**                                 | `Policy Definition Set`, **Custom**   | This policy set deploys the configurations of application Azure resources to forward diagnostic logs and metrics to an Azure Log Analytics workspace.                                                                                                                                                                                                                                | DeployIfNotExists                   | 2.0.0   |
| **Enable Monitoring in Azure Security Center**                             | **Azure Security Benchmark**                                                     | `Policy Definition Set`, **Built-in** | The Microsoft Cloud Security Benchmark initiative represents the policies and controls implementing security recommendations defined in Microsoft Cloud Security Benchmark v1, see https://aka.ms/azsecbm. This also serves as the Azure Security Center default policy initiative. You can directly assign this initiative, or manage its policies and compliance results within Azure Security Center. | Audit, AuditIfNotExists, Disabled   | 49.0.0  |
| **Enable Azure Monitor for VMs**                                           | **Enable Azure Monitor for VMs**                                                 | `Policy Definition Set`, **Built-in** | Enable Azure Monitor for the virtual machines (VMs) in the specified scope (management group, subscription or resource group). Takes Log Analytics workspace as parameter                                                                                                                                                                                                            | DeployIfNotExists, AuditIfNotExists | 2.0.0   |
| **Enable Azure Monitor for Virtual Machine Scale Sets**                    | **Enable Azure Monitor for Virtual Machine Scale Sets**                          | `Policy Definition Set`, **Built-in** | Enable Azure Monitor for the Virtual Machine Scale Sets in the specified scope (Management group, Subscription or resource group). Takes Log Analytics workspace as parameter. Note: if your scale set upgradePolicy is set to Manual, you need to apply the extension to the all VMs in the set by calling upgrade on them. In CLI this would be az vmss update-instances.          | DeployIfNotExists, AuditIfNotExists | 1.0.1   |
| **Deploy Diagnostic Settings for Activity Log to Log Analytics workspace** | **Configure Azure Activity logs to stream to specified Log Analytics workspace** | `Policy Definition`, **Built-in**     | Deploys the diagnostic settings for Azure Activity to stream subscriptions audit logs to a Log Analytics workspace to monitor subscription-level events                                                                                                                                                                                                                              | DeployIfNotExists                   | 1.0.0   |
| **Deny the Deployment of Classic Resources** | **Not allowed resource types** | `Policy Definition`, **Built-in**     | Denies deployment of classic resource types under the assigned scope                                                                                                                                                                                                                              | Deny                   | 2.0.0   |
| **Audit-UnusedResourcesCostOptimization** | **Audit-UnusedResourcesCostOptimization** | `Policy Definition Set`, **Custom**     | Optimize cost by detecting unused but chargeable resources. Leverage this Azure Policy Initiative as a cost control tool to reveal orphaned resources that are contributing cost.                                                                                                                                                                                                                              | Audit                   | 1.0.0   |
| **Deny Virtual Machines and Virtual Machine Scale Sets from not using OS Managed Disks** | **Deny Virtual Machines and Virtual Machine Scale Sets from not using OS Managed Disks** | `Policy Definition`, **Custom**     | Deny virtual machines not using managed disk. It checks the managedDisk property on virtual machine OS Disk fields.                                                                                                                                                                                                                         | Deny                   | 1.0.0   |

### Platform

This management group contains all the platform child management groups, like management, connectivity, and identity. There are currently no policies assigned at this management group

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>
  
![image](./media/Platform_v0.1.jpg)
  
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
  
![image](./media/Connectivity_v0.1.jpg)
  
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
  
![image](./media/Management_v0.1.jpg)
  
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
  
![image](./media/Identity_v0.1.jpg)
  
</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **0**     |
| `Policy Definitions`      | **4**     |
</td></tr> </table>

The table below provides the specific **Custom** and **Built-in** **policy definitions** and **policy definitions sets** assigned at the **Identity Management Group**.

| Assignment Name                                                                                                     | Definition Name                                                                                                     | Policy Type                       | Description                                                                                                                                    | Effect(s)         | Version |
| ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ----------------- | ------- |
| **Deny the creation of public IP**                                                                                  | **Not allowed resource types**                                                                                  | `Policy Definition`, **Built-in**   | This policy denies creation of Public IPs under the assigned scope. Single parameter value for `listOfResourceTypesNotAllowed` which is `Microsoft.Network/publicIPAddresses`                                                                         | Deny              | 1.0.0   |
| **RDP access from the Internet should be blocked**                                                                  | **RDP access from the Internet should be blocked**                                                                  | `Policy Definition`, **Custom**   | This policy denies any network security rule that allows RDP access from Internet.                                                             | Deny              | 1.0.0   |
| **Subnets should have a Network Security Group**                                                                    | **Subnets should have a Network Security Group**                                                                    | `Policy Definition`, **Custom**   | This policy denies the creation of a subnet without a Network Security Group. NSG help to protect traffic across subnet-level.                 | Deny              | 2.0.0   |
| **Configure backup on virtual machines without a given tag to a new recovery services vault with a default policy** | **Configure backup on virtual machines without a given tag to a new recovery services vault with a default policy** | `Policy Definition`, **Built-in** | Enforce backup for all virtual machines by deploying a recovery services vault in the same location and resource group as the virtual machine. | DeployIfNotExists | 8.0.0   |

### Landing Zones

This is the parent management group for all the landing zone child management groups. Policy assignment is predominantly focused on ensuring workloads residing under this hierarchy are secure and compliant.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>

![image](./media/LandingZone_v0.1.jpg)

</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **3**     |
| `Policy Definitions`      | **13**    |
</td></tr> </table>

The table below provides the specific **Custom** and **Built-in** **policy definitions** and **policy definitions sets** assigned at the **Landing Zones Management Group**.

| Assignment Name                                                                                                     | Definition Name                                                                                                     | Policy Type                         | Description                                                                                                                                                                                                                                                                                                                                                                         | Effect(s)                                        | Version |
| ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ | ------- |
| **Deny or Deploy and append TLS requirements and SSL enforcement on resources without Encryption in transit**       | **Deny or Deploy and append TLS requirements and SSL enforcement on resources without Encryption in transit**       | `Policy Definition Set`, **Custom** | Description TBC                                                                                                                                                                                                                                                                                                                                                                     | Audit, AuditIfNotExists, DeployIfNotExists, Deny | 1.0.1   |
| **Enforce recommended guardrails for Azure Key Vault**       | **Enforce recommended guardrails for Azure Key Vault**       | `Policy Definition Set`, **Custom** | This policy initiative enforces minimum guardrails for Azure Key Vault: <ul><li>Key vaults should have soft delete enabled (Deny)<li>Key vaults should have purge protection enabled (Deny)<li>Key Vault secrets should have an expiration date (Audit)<li>Key Vault keys should have an expiration date (Audit)<li>Azure Key Vault should have firewall enabled (Audit)<li>Certificates should have the specified lifetime action triggers (Audit)<li>Keys should have more than the specified number of days before expiration (Audit < 90 days)<li>Secrets should have more than the specified number of days before expiration (Audit < 90 days)</ul>| Audit, Deny | 1.0.0   |
| **Enforce Azure Compute Security Benchmark compliance auditing**       | **Enforce Azure Compute Security Benchmark compliance auditing**       | `Policy Definition Set`, **Custom** | This policy initiative enables Azure Compute Security Basline compliance auditing for Windows and Linux virtual machines. | AuditIfNotExists | 2.0.0   |
| **RDP access from the Internet should be blocked**                                                                  | **RDP access from the Internet should be blocked**                                                                  | `Policy Definition`, **Custom**     | This policy denies any network security rule that allows RDP access from Internet                                                                                                                                                                                                                                                                                                   | Deny                                             | 1.0.0   |
| **Subnets should have a Network Security Group**                                                                    | **Subnets should have a Network Security Group**                                                                    | `Policy Definition`, **Custom**     | This policy denies the creation of a subnet without a Network Security Group. NSG help to protect traffic across subnet-level.                                                                                                                                                                                                                                                      | Deny                                             | 2.0.0   |
| **Network interfaces should disable IP forwarding**                                                                 | **Network interfaces should disable IP forwarding**                                                                 | `Policy Definition`, **Built-in**   | This policy denies the network interfaces which enabled IP forwarding. The setting of IP forwarding disables Azure's check of the source and destination for a network interface.                                                                                                                                                                                                   | Deny                                             | 1.0.0   |
| **Secure transfer to storage accounts should be enabled**                                                           | **Secure transfer to storage accounts should be enabled**                                                           | `Policy Definition`, **Built-in**   | Audit requirement of Secure transfer in your storage account. Secure transfer is an option that forces your storage account to accept requests only from secure connections (HTTPS). Use of HTTPS ensures authentication between the server and the service and protects data in transit from network layer attacks such as man-in-the-middle, eavesdropping, and session-hijacking | Audit                                            | 2.0.0   |
| **Deploy Azure Policy Add-on to Azure Kubernetes Service clusters**                                                 | **Deploy Azure Policy Add-on to Azure Kubernetes Service clusters**                                                 | `Policy Definition`, **Built-in**   | Use Azure Policy Add-on to manage and report on the compliance state of your Azure Kubernetes Service (AKS) clusters.                                                                                                                                                                                                                                                               | DeployIfNotExists                                | 4.0.0   |
| **Configure SQL servers to have auditing enabled to Log Analytics workspace**                                                                        | **Configure SQL servers to have auditing enabled to Log Analytics workspace**                                                                        | `Policy Definition`, **Built-in**   | To ensure the operations performed against your SQL assets are captured, SQL servers should have auditing enabled. If auditing is not enabled, this policy will configure auditing events to flow to the specified Log Analytics workspace.                                                                                                                                                                                                                                        | DeployIfNotExists                                 |1.0.0   |
| **Deploy Threat Detection on SQL servers**                                                                          | **Configure Azure Defender to be enabled on SQL servers**                                                           | `Policy Definition`, **Built-in**   | Enable Azure Defender on your Azure SQL Servers to detect anomalous activities indicating unusual and potentially harmful attempts to access or exploit databases.                                                                                                                                                                                                                  | DeployIfNotExists                                | 2.1.0   |
| **Configure backup on virtual machines without a given tag to a new recovery services vault with a default policy** | **Configure backup on virtual machines without a given tag to a new recovery services vault with a default policy** | `Policy Definition`, **Built-in**   | Enforce backup for all virtual machines by deploying a recovery services vault in the same location and resource group as the virtual machine. Doing this is useful when different application teams in your organization are allocated separate resource groups and need to manage their own backups and restores.                                                                 | DeployIfNotExists                                | 8.0.0   |
| **Virtual networks should be protected by Azure DDoS Network Protection**                                          | **Virtual networks should be protected by Azure DDoS Network Protection**                                          | `Policy Definition`, **Built-in**   | Protect your virtual networks against volumetric and protocol attacks with Azure DDoS Network Protection .                                                                                                                                                                                                                                                                          | Modify                                           | 1.0.0   |
| **Kubernetes cluster should not allow privileged containers**                                                       | **Kubernetes cluster should not allow privileged containers**                                                       | `Policy Definition`, **Built-in**   | Do not allow privileged containers creation in a Kubernetes cluster. This recommendation is part of CIS 5.2.1 which is intended to improve the security of your Kubernetes environments. This policy is generally available for Kubernetes Service (AKS), and preview for AKS Engine and Azure Arc enabled Kubernetes.                                                              | Deny                                             | 7.2.0   |
| **Kubernetes clusters should not allow container privilege escalation**                                             | **Kubernetes clusters should not allow container privilege escalation**                                             | `Policy Definition`, **Built-in**   | Do not allow containers to run with privilege escalation to root in a Kubernetes cluster. This recommendation is part of CIS 5.2.5 which is intended to improve the security of your Kubernetes environments. This policy is generally available for Kubernetes Service (AKS), and preview for AKS Engine and Azure Arc enabled Kubernetes.                                         | Audit                                            | 4.2.0   |
| **Kubernetes clusters should be accessible only over HTTPS**                                                        | **Kubernetes clusters should be accessible only over HTTPS**                                                        | `Policy Definition`, **Built-in**   | Use of HTTPS ensures authentication and protects data in transit from network layer eavesdropping attacks. This capability is currently generally available for Kubernetes Service (AKS), and in preview for AKS Engine and Azure Arc enabled Kubernetes.                                                                                                                           | Deny                                             | 6.1.0   |
| **Web Application Firewall (WAF) should be enabled for Application Gateway**                                                        | **Web Application Firewall (WAF) should be enabled for Application Gateway**                                                        | `Policy Definition`, **Built-in**   | Deploy Azure Web Application Firewall (WAF) in front of public facing web applications for additional inspection of incoming traffic. Web Application Firewall (WAF) provides centralized protection of your web applications from common exploits and vulnerabilities such as SQL injections, Cross-Site Scripting, local and remote file executions. You can also restrict access to your web applications by countries, IP address ranges, and other http(s) parameters via custom rules.                                                                                                                           | Audit                                             | 2.0.0   |

### Corp

This management group is for corporate landing zones. This group is for workloads that require connectivity or hybrid connectivity with the corporate network via the hub in the connectivity subscription. Policy assignment is predominantly focused on ensuring workloads residing under this hierarchy are secure and compliant.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>

![image](./media/Corp_v0.1.jpg)

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
| **Deny network interfaces having a public IP associated**          | **Network interfaces should not have public IPs**          | `Policy Definition`, **Built-in**     | This policy denies network interfaces from having a public IP associated to it under the assigned scope.                                                                                                                                          | Deny              | 1.0.0   |
| **Deny the deployment of vWAN/ER/VPN gateway resources**          | **Not allowed resource types**          | `Policy Definition`, **Built-in**     | Denies deployment of vWAN/ER/VPN gateway resources in the Corp landing zone.                                                                                                                                          | Deny              | 1.0.0   |
| **Audit Private Link Private DNS Zone resources**          | **Audit the creation of Private Link Private DNS Zones**          | `Policy Definition`, **Custom**     | Audits the deployment of Private Link Private DNS Zone resources in the Corp landing zone.                                                                                                                                         | Audit              | 1.0.0   |

### Online

This management group is for online landing zones. This group is for workloads that might require direct internet inbound/outbound connectivity or for workloads that might not require a virtual network. There are currently no policies assigned at this management group.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>

![image](./media/Online_v0.1.jpg)

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

![image](./media/Decom_v0.1.jpg)

</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **1**     |
| `Policy Definitions`      | **0**     |
</td></tr> </table>

| Assignment Name                                                | Definition Name                                                | Policy Type                         | Description                                                                                                                                                                                            | Effect(s)         | Version |
| -------------------------------------------------------------- | -------------------------------------------------------------- | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------- | ------- |
| **Enforce ALZ Decommissioned Guardrails** | **Enforce ALZ Decommissioned Guardrails** | `Policy Definition Set`, **Custom** | This initiative will help enforce and govern subscriptions that are placed within the decommissioned Management Group as part of your Subscription decommissioning process.  Policies included: <ul><li>Deny the deployment of new resources<li>Deploy an auto VM shutdown policy at UTC 00:00</ul>                                                                           | Enforce              | 1.0.0   |

### Sandbox

This management group is for subscriptions that will only be used for testing and exploration by an organization. These subscriptions will be securely disconnected from the corporate and online landing zones. Sandboxes also have a less restrictive set of policies assigned to enable testing, exploration, and configuration of Azure services. There are currently no policies assigned at this management group.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>

![image](./media/Sandbox_v0.1.jpg)

</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **1**     |
| `Policy Definitions`      | **0**     |
</td></tr> </table>

| Assignment Name                                                | Definition Name                                                | Policy Type                         | Description                                                                                                                                                                                            | Effect(s)         | Version |
| -------------------------------------------------------------- | -------------------------------------------------------------- | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------- | ------- |
| **Enforce ALZ Sandbox Guardrails** | **Enforce ALZ Sandbox Guardrails** | `Policy Definition Set`, **Custom** | This initiative will help enforce and govern subscriptions that are placed within the Sandobx Management Group. Policies included: <ul><li>Deny vNET peering across subscriptions<li>Deny the deployment of vWAN/ER/VPN gateways.</ul>                                                                              | Enforce              | 1.0.0   |

### Versioning

Each policy definition and initiative contains a version in its metadata section:
```json
"metadata": {
   "version": "1.0.0",
   "category": "{categoryName}",
   "source": "https://github.com/Azure/Enterprise-Scale/",
   "alzCloudEnvironments": [
      "AzureCloud",
      "AzureChinaCloud",
      "AzureUSGovernment"
   ]
}
```

This version is incremented according to the following rules (subject to change):
   - **Major Version** (**1**.0.0)
      - Policy Definitions
         - Rule logic changes
         - ifNotExists existence condition changes
         - Major changes to the effect of the policy (i.e. adding a new resource to a deployment)
      - Policy Set Definitions
         - Addition or removal of a policy definition from the policy set
   - **Minor Version** (1.**0**.0)
      - Policy Definitions
         - Changes to effect details that don't meet the major version criteria
         - Adding new parameter allowed values
         - Adding new parameters (with default values)
         - Other minor changes to existing parameters
      - Policy Set Definitions
         - Adding new parameter allowed values
         - Adding new parameters (with default values)
         - Other minor changes to existing parameters
   - **Patch Version** (1.0.**0**)
      - Policy Definitions
         - String changes (displayName, description, etc…)
         - Other metadata changes
      - Policy Set Definitions
         - String changes (displayName, description, etc…)
         - Other metadata changes
   - **Suffix**
      - Append "-preview" to the version if the policy is in a preview state  
         - Example:  1.3.2-preview
      - Append "-deprecated" to the version if the policy is in a deprecated state
         - Example:  1.3.2-deprecated
 
## Preview and deprecated policies

This section aims to explain what it means when a built-in policy has a state of ‘preview’ or ‘deprecated’.  

Policies can be in preview because a property (alias) referenced in the policy definition is in preview, or the policy is newly introduced and would like additional customer feedback. A policy may get deprecated when the property (alias) becomes deprecated & not supported in the resource type's latest API version, or when there is manual migration needed by customers due to a breaking change in a resource type's latest API version. 

When a policy gets deprecated or gets out of preview, there is no impact on existing assignments. Existing assignments continue to work as-is. The policy is still evaluated & enforced like normal and continues to produce compliance results.  

Here are the changes that occur when a policy gets deprecated: 
- Display name is appended with ‘[Deprecated]:’ prefix, so that customers have awareness to migrate or delete the policy.
- Description gets updated to provide additional information regarding the deprecation. 
- The version number is updated with ‘-deprecated’ suffix. (see [Policy Versioning](#versioning) above) 

> **NOTE:** The `name` value must not change in the file through deprecation or preview.
