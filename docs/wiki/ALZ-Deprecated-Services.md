# Azure Landing Zones Deprecated Notices

## In this section

- [Azure Landing Zones Deprecated Notices](#azure-landing-zones-deprecated-notices)
  - [In this section](#in-this-section)
  - [Overview](#overview)
  - [Deprecated policies](#deprecated-policies)
    - [More Information](#more-information)
  - [Deprecated services](#deprecated-services)

## Overview

As policies and services are further developed by Microsoft, one or more Azure Landing Zone (ALZ) components may be superseded and need to be deprecated. This article provides details as to those items and supporting documentation to help you remain up to date.

## Deprecated policies

New Azure Policies are being developed and created by product groups that support their services and are typically of the `built-in` type. These new policies often replace legacy policies which get deprecated and usually provide guidance on which policy to use instead. Azure Landing Zones (ALZ) policies are not exempt from this, and over time some policies will be updated to leverage new `built-in` policies instead of ALZ `custom` policies. Through this process, `custom` ALZ policies will be deprecated when new `built-in` policies are available that provide the same capability, which ultimately reduces maintenance overhead for `custom` policies.  

Policies being deprecated:

| Deprecated ALZ Policy                | Superseded by policy<br>(includes link to AzAdvertizer)                                                                                               | Justification                                                            |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| Deploys NSG flow logs and traffic analytics<br>ID: `Deploy-Nsg-FlowLogs`                  | [`e920df7f-9a64-4066-9b58-52684c02a091`](https://www.azadvertizer.net/azpolicyadvertizer/e920df7f-9a64-4066-9b58-52684c02a091.html) | Custom policy replaced by built-in requires less administration overhead |
| Deploys NSG flow logs and traffic analytics to Log Analytics<br>ID: `Deploy-Nsg-FlowLogs-to-LA`            | [`e920df7f-9a64-4066-9b58-52684c02a091`](https://www.azadvertizer.net/azpolicyadvertizer/e920df7f-9a64-4066-9b58-52684c02a091.html) | Custom policy replaced by built-in requires less administration overhead |
| Deny the creation of public IP<br>ID: `Deny-PublicIP`                      | [`6c112d4e-5bc7-47ae-a041-ea2d9dccd749`](https://www.azadvertizer.net/azpolicyadvertizer/6c112d4e-5bc7-47ae-a041-ea2d9dccd749.html) | Custom policy replaced by built-in requires less administration overhead |
| Latest TLS version should be used in your API App<br>ID: `8cb6aa8b-9e41-4f4e-aa25-089a7ac2581e` | [`f0e6e85b-9b9f-4a4b-b67b-f730d42f1b0b`](https://www.azadvertizer.net/azpolicyadvertizer/f0e6e85b-9b9f-4a4b-b67b-f730d42f1b0b.html)  | Deprecated policy in initiative removed as existing policy supersedes it |
| SQL servers should use customer-managed keys to encrypt data at rest<br>ID: `0d134df8-db83-46fb-ad72-fe0c9428c8dd` | [`0a370ff3-6cab-4e85-8995-295fd854c5b8`](https://www.azadvertizer.net/azpolicyadvertizer/0a370ff3-6cab-4e85-8995-295fd854c5b8.html)  | Deprecated policy in initiative replaced with new policy                  |
| RDP access from the Internet should be blocked<br>ID: `Deny-RDP-From-Internet` | [`Deny-MgmtPorts-From-Internet`](https://www.azadvertizer.net/azpolicyadvertizer/Deny-MgmtPorts-From-Internet.html)  | Deprecated policy as it is superseded by a more flexible policy                  |
| Deploy SQL Database Transparent Data Encryption<br>ID: [`Deploy SQL Database Transparent Data Encryption`](https://www.azadvertizer.net/azpolicyadvertizer/Deploy-Sql-Tde.html) |	`86a912f6-9a06-4e26-b447-11b16ba8659f` | Custom policy replaced by built-in requires less administration overhead |
| Azure Machine Learning should have disabled public network access<br>ID: [`Deny-MachineLearning-PublicNetworkAccess`](https://www.azadvertizer.net/azpolicyadvertizer/Deny-MachineLearning-PublicNetworkAccess.html) | [`438c38d2-3772-465a-a9cc-7a6666a275ce`](https://www.azadvertizer.net/azpolicyadvertizer/438c38d2-3772-465a-a9cc-7a6666a275ce.html) | Custom policy replaced by built-in requires less administration overhead |
| Public network access should be disabled for MariaDB<br>ID: [`Deny-PublicEndpoint-MariaDB`](https://www.azadvertizer.net/azpolicyadvertizer/Deny-PublicEndpoint-MariaDB.html) | [`fdccbe47-f3e3-4213-ad5d-ea459b2fa077`](https://www.azadvertizer.net/azpolicyadvertizer/fdccbe47-f3e3-4213-ad5d-ea459b2fa077.html) | Deprecating policies for MariaDB see [`ALZ Policy FAQ & Tips`](https://github.com/Azure/Enterprise-Scale/blob/main/docs/wiki/ALZ-Policies-FAQ.md). |
| Diagnostic Settings for MariaDB to Log Analytics Workspace <br>ID: [`Deploy-Diagnostics-MariaDB`](https://www.azadvertizer.net/azpolicyadvertizer/Deploy-Diagnostics-MariaDB.html) | Deprecating due to service retirement | Deprecating policies for MariaDB, see [`ALZ Policy FAQ & Tips`](./ALZ-Policies-FAQ) |
| Deploy SQL Database Vulnerability Assessments<br>ID: [`Deploy-Sql-vulnerabilityAssessments`](https://www.azadvertizer.net/azpolicyadvertizer/Deploy-Sql-vulnerabilityAssessments.html) | [`Deploy-Sql-vulnerabilityAssessments_20230706`](https://www.azadvertizer.net/azpolicyadvertizer/Deploy-Sql-vulnerabilityAssessments_20230706.html) | Custom policy replaced by updated custom policy providing bug fix |
| Deploy Microsoft Defender for Cloud configuration<br>ID: [`Deploy-MDFC-Config`](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Deploy-MDFC-Config.html) | [`Deploy-MDFC-Config_20240319`](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Deploy-MDFC-Config_20240319.html) | Custom initiative replaced by updated custom initiative due to breaking changes |
| Deny or Deploy and append TLS requirements and SSL enforcement on resources without Encryption in transit<br>ID: [`Enforce-EncryptTransit`](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-EncryptTransit.html) | [`Enforce-EncryptTransit_20240509`](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-EncryptTransit_20240509.html) | Custom initiative replaced by updated custom initiative due to breaking changes |
| Deploy SQL Database built-in SQL security configuration<br>ID: [`Deploy-SQL-Security`](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Deploy-SQL-Security.html) | [`Deploy-SQL-Security_20240529`](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Deploy-SQL-Security_20240529.html) | Custom initiative replaced by updated custom initiative due to breaking changes |
| Configure SQL VM and Arc-enabled SQL Servers to install Microsoft Defender for SQL and AMA with a user-defined LAW<br>ID: `Deploy-MDFC-DefenderSQL-AMA` | [`de01d381-bae9-4670-8870-786f89f49e26`](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/de01d381-bae9-4670-8870-786f89f49e26.html) | Custom policy replaced by built-in requires less administration overhead |
| Configure SQL Virtual Machines to automatically install Microsoft Defender for SQL<br>ID: `Deploy-MDFC-SQL-DefenderSQL` | [`ddca0ddc-4e9d-4bbb-92a1-f7c4dd7ef7ce`](https://www.azadvertizer.net/azpolicyadvertizer/ddca0ddc-4e9d-4bbb-92a1-f7c4dd7ef7ce.html) | Custom policy replaced by built-in requires less administration overhead |
| Configure SQL Virtual Machines to auto install Microsoft Defender for SQL and DCR with a user-defined LAW<br>ID: `Deploy-MDFC-SQL-DefenderSQL-DCR` | [`04754ef9-9ae3-4477-bf17-86ef50026304`](https://www.azadvertizer.net/azpolicyadvertizer/04754ef9-9ae3-4477-bf17-86ef50026304.html) | Custom policy replaced by built-in requires less administration overhead |
| Configure SQL Virtual Machines to automatically install Azure Monitor Agent<br>ID: `Deploy-MDFC-SQL-AMA` | [`f91991d1-5383-4c95-8ee5-5ac423dd8bb1`](https://www.azadvertizer.net/azpolicyadvertizer/f91991d1-5383-4c95-8ee5-5ac423dd8bb1.html) | Custom policy replaced by built-in requires less administration overhead |
| Configure Arc-enabled SQL Servers to auto install Microsoft Defender for SQL and DCR with a user-defined LAW<br>ID: `Deploy-MDFC-Arc-Sql-DefenderSQL-DCR` | [`63d03cbd-47fd-4ee1-8a1c-9ddf07303de0`](https://www.azadvertizer.net/azpolicyadvertizer/63d03cbd-47fd-4ee1-8a1c-9ddf07303de0.html) | Custom policy replaced by built-in requires less administration overhead |
| Configure Arc-enabled SQL Servers with DCR Association to Microsoft Defender for SQL user-defined DCR<br>ID: `Deploy-MDFC-Arc-SQL-DCR-Association` | [`2227e1f1-23dd-4c3a-85a9-7024a401d8b2`](https://www.azadvertizer.net/azpolicyadvertizer/2227e1f1-23dd-4c3a-85a9-7024a401d8b2.html) | Custom policy replaced by built-in requires less administration overhead |
| Deploy User Assigned Managed Identity for VM Insights<br>ID: `Deploy-UserAssignedManagedIdentity-VMInsights` | Deprecating as it's no longer required | User-Assigned Management Identity is now centralized and deployed by Azure Landing Zones to the Management Subscription. |

>IMPORTANT: note that we have deprecated ALL ALZ custom Diagnostic Setting features as part of Azure Landing Zones, which includes the initiatives and all 53 policies. These are being deprecated in favor of using (and assigning) the built-in initiative [Enable allLogs category group resource logging for supported resources to Log Analytics](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/0884adba-2312-4468-abeb-5422caed1038.html)

### More Information

- [Azure Policy - Preview and deprecated policies](https://github.com/Azure/azure-policy/blob/master/built-in-policies/README.md#preview-and-deprecated-policies) - to learn more about the deprecation process.
- [Migrate ALZ Policies to Built‐in](https://github.com/Azure/Enterprise-Scale/wiki/Migrate-ALZ-Policies-to-Built%E2%80%90in) - for guidance on how to migrate deprecated ALZ custom policies to Azure built-in policies.

## Deprecated services

- Removed `ActivityLog` Solution as an option to be deployed into the Log Analytics Workspace, as this has been superseded by the Activity Log Insights Workbook, as documented [here.](https://learn.microsoft.com/azure/azure-monitor/essentials/activity-log-insights)
- Removed `Service Map` solution as an option to be deployed, as this has been superseded by VM Insights, as documented [here.](https://learn.microsoft.com/azure/azure-monitor/essentials/activity-log-insights) Guidance on migrating and removing the Service Map solution can be found [here.](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-migrate-from-service-map)

- Due to Microsoft Monitor Agent (MMA) planned for deprecation (August 2024) we have started to remove MMA from our reference implementations starting with the ALZ Portal (https://aka.ms/alz/portal) and following this will start to remove MMA from Bicep and Terraform before the planned deprecation date. Please see [MMA Deprecation Guidance](/docs/wiki/ALZ-AMA-Update.md) for more details.