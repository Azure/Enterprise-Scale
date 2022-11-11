# Azure Landing Zones Deprecated Policies

## In this section

- [Azure Landing Zones Deprecated Policies](#azure-landing-zones-deprecated-policies)
  - [In this section](#in-this-section)
  - [Overview](#overview)
  - [Deprecated policies](#deprecated-policies)

## Overview

As built-in services are further developed by Microsoft, one or more Azure Landing Zone (ALZ) components may be superseded.

## Deprecated policies

New Azure Policies are being developed and created constantly as a `built-in` type. Azure Landing Zones (ALZ) policies are not exempt from this, so over time some policies will be included as `built-in` from `ALZ` or `custom` types. This will lead to duplicate policies being created and additional admin overhead of maintenance.

Over time, a deprecation process of there `ALZ / custom` policies will have to take place. To learn more about the deprecation process, see the following documentation:

[Azure Policy - Preview and deprecated policies](https://github.com/Azure/azure-policy/blob/master/built-in-policies/README.md#preview-and-deprecated-policies)

| Deprecated ALZ Policy IDs                     | Superseded by built-in policy IDs    | Justification                                                            |   |   |
|-----------------------------------------------|--------------------------------------|--------------------------------------------------------------------------|---|---|
| Deploy-Nsg-FlowLogs | e920df7f-9a64-4066-9b58-52684c02a091 | Custom policy replaced by built-in requires less administration overhead |   |   |
| Deploy-Nsg-FlowLogs-to-LA | e920df7f-9a64-4066-9b58-52684c02a091 | Custom policy replaced by built-in requires less administration overhead |   |   |
| Deny-PublicIP | 6c112d4e-5bc7-47ae-a041-ea2d9dccd749 | Custom policy replaced by built-in requires less administration overhead |   |   |
