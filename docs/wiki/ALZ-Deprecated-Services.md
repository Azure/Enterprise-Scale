# Azure Landing Zones Deprecated Policies and Services

## In this section

- [Deprecated Policies](#deprecated-policies)
- [Deprecated Services](#deprecated-services)

## Overview

As policies and services are further developed by Microsoft, one or more Azure Landing Zone (ALZ) components may be superseded and need to be deprecated.

## Deprecated policies

New Azure Policies are being developed and created by product groups that support their services and are typically of the `built-in` type. These new policies often replace legacy policies which get deprecated and usually provide guidance on which policy to use instead. Azure Landing Zones (ALZ) policies are not exempt from this, and over time some policies will be updated to leverage new `built-in` policies instead of ALZ `custom` policies. Through this process, `custom` ALZ policies will be deprecated when new `built-in` policies are available that provide the same capability, which ultimately reduces maintenance overhead for `custom` policies.  

Policies being deprecated:

| Deprecated ALZ Policy                | Superseded by built-in policy<br>(includes link to AzAdvertizer)                                                                                               | Justification                                                            |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| Deploys NSG flow logs and traffic analytics<br>ID: `Deploy-Nsg-FlowLogs`                  | [`e920df7f-9a64-4066-9b58-52684c02a091`](https://www.azadvertizer.net/azpolicyadvertizer/e920df7f-9a64-4066-9b58-52684c02a091.html) | Custom policy replaced by built-in requires less administration overhead |
| Deploys NSG flow logs and traffic analytics to Log Analytics<br>ID: `Deploy-Nsg-FlowLogs-to-LA`            | [`e920df7f-9a64-4066-9b58-52684c02a091`](https://www.azadvertizer.net/azpolicyadvertizer/e920df7f-9a64-4066-9b58-52684c02a091.html) | Custom policy replaced by built-in requires less administration overhead |
|Deny the creation of public IP<br>ID: `Deny-PublicIP  `                      | [`6c112d4e-5bc7-47ae-a041-ea2d9dccd749`](https://www.azadvertizer.net/azpolicyadvertizer/6c112d4e-5bc7-47ae-a041-ea2d9dccd749.html) | Custom policy replaced by built-in requires less administration overhead |
| Latest TLS version should be used in your API App<br>ID: `8cb6aa8b-9e41-4f4e-aa25-089a7ac2581e` | [`f0e6e85b-9b9f-4a4b-b67b-f730d42f1b0b`](https://www.azadvertizer.net/azpolicyadvertizer/f0e6e85b-9b9f-4a4b-b67b-f730d42f1b0b.html)  | Deprecated policy in intiative removed as existing policy supercedes it |
| SQL servers should use customer-managed keys to encrypt data at rest<br>ID: `0d134df8-db83-46fb-ad72-fe0c9428c8dd` | [`0a370ff3-6cab-4e85-8995-295fd854c5b8`](https://www.azadvertizer.net/azpolicyadvertizer/0a370ff3-6cab-4e85-8995-295fd854c5b8.html)  | Deprecated policy in intiative replaced with new policy                  |
| RDP access from the Internet should be blocked<br>ID: `Deny-RDP-From-Internet` | [`Deny-MgmtPorts-From-Internet`](https://www.azadvertizer.net/azpolicyadvertizer/Deny-MgmtPorts-From-Internet.html)  | Deprecated policy as it is superceded by a more flexible policy                  |

### More Information

- [Azure Policy - Preview and deprecated policies](https://github.com/Azure/azure-policy/blob/master/built-in-policies/README.md#preview-and-deprecated-policies) - to learn more about the deprecation process.
- [Migrate ALZ Policies to Built‐in](https://github.com/Azure/Enterprise-Scale/wiki/Migrate-ALZ-Policies-to-Built%E2%80%90in) - for guidance on how to migrate deprecated ALZ custom policies to Azure built-in policies.

## Deprecated services

- Removed `ActivityLog` Solution as an option to be deployed into the Log Analytics Workspace, as this has been superseded by the Activity Log Insights Workbook, as documented [here.](https://learn.microsoft.com/azure/azure-monitor/essentials/activity-log-insights)
