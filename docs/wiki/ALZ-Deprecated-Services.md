# Azure Landing Zones Deprecated Services

## In this section

- [Azure Landing Zones Deprecated Services](#azure-landing-zones-deprecated-services)

## Overview

As built-in services are further developed by Microsoft, one or more Azure Landing Zone (ALZ) components may be superseded.

## Deprecated policies

New Azure Policies are being developed and created constantly as a `built-in` type. Azure Landing Zones (ALZ) policies are not exempt from this, so over time some policies will be included as `built-in` from `ALZ` or `custom` types. This will lead to duplicate policies being created and additional admin overhead of maintenance.

Over time, a deprecation process of there `ALZ / custom` policies will have to take place. To learn more about the deprecation process, see the following documentation:

[Azure Policy - Preview and deprecated policies](https://github.com/Azure/azure-policy/blob/master/built-in-policies/README.md#preview-and-deprecated-policies)

| Deprecated ALZ Policy IDs            | Superseded by built-in policy IDs                                                                                               | Justification                                                            |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| Deploy-Nsg-FlowLogs                  | [e920df7f-9a64-4066-9b58-52684c02a091](https://www.azadvertizer.net/azpolicyadvertizer/e920df7f-9a64-4066-9b58-52684c02a091.html?) | Custom policy replaced by built-in requires less administration overhead |
| Deploy-Nsg-FlowLogs-to-LA            | [e920df7f-9a64-4066-9b58-52684c02a091](https://www.azadvertizer.net/azpolicyadvertizer/e920df7f-9a64-4066-9b58-52684c02a091.html?) | Custom policy replaced by built-in requires less administration overhead |
| Deny-PublicIP                        | [6c112d4e-5bc7-47ae-a041-ea2d9dccd749](https://www.azadvertizer.net/azpolicyadvertizer/6c112d4e-5bc7-47ae-a041-ea2d9dccd749.html?) | Custom policy replaced by built-in requires less administration overhead |
| 8cb6aa8b-9e41-4f4e-aa25-089a7ac2581e | [f0e6e85b-9b9f-4a4b-b67b-f730d42f1b0b](https://www.azadvertizer.net/azpolicyadvertizer/f0e6e85b-9b9f-4a4b-b67b-f730d42f1b0b.html)  | Deprecated policy in intiative removed as existing policy supercedes it |
| 0d134df8-db83-46fb-ad72-fe0c9428c8dd | [0a370ff3-6cab-4e85-8995-295fd854c5b8](https://www.azadvertizer.net/azpolicyadvertizer/0a370ff3-6cab-4e85-8995-295fd854c5b8.html)  | Deprecated policy in intiative replaced with new policy                  |

Guidance on how to migrate deprecated ALZ custom policies to Azure built-in policies can be found [here](https://github.com/Azure/Enterprise-Scale/wiki/Migrate-ALZ-Policies-to-Built%E2%80%90in)
## Deprecated services

- Removed `ActivityLog` Solution as an option to be deployed into the Log Analytics Workspace. As this has been superseded by the Activity Log Insights Workbook, as documented [here.](https://learn.microsoft.com/azure/azure-monitor/essentials/activity-log-insights)
