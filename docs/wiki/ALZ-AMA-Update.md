## Introduction

### Deprecation

The Log Analytics agent, also known as the Microsoft Monitoring Agent (MMA), is on a deprecation path and won't be supported after August 31, 2024. Any new data centers brought online after January 1 2024 will not support the Log Analytics agent. If you use the Log Analytics agent to ingest data to Azure Monitor, migrate to the new Azure Monitor agent prior to that date.

New ALZ deployments will use AMA exclusively. Brownfield guidance for adopting AMA is available [AMA Migration Guidance](./ALZ-AMA-Migration-Guidance)

### Timing

The migration from MMA to AMA has been a mayor project across multiple teams within Microsoft. ALZ held off on implementing AMA up to this point to ensure that a good feature set was available across all the different solutions. While there still are a few gaps, which are detailed below, we feel that the current AMA configuration is ready to be implemented in ALZ.

## Strategy

1. Include AMA for Greenfield customers using the portal deployment. (Completed)
2. Brownfield adoption guidance is available. This includes:
   - Implementation guidance
   - Breaking changes
   - Cleanup guidance
   - Quick reference to public documentations for migration guidance for individual solutions
3. Include AMA for Greenfield and Brownfield customers using either a Bicep or Terraform deployment. (June 2024)

## AMA parity

Please check the most recent information on parity gaps:

- [Known parity gaps for solutions that may impact your migration](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-migration#known-parity-gaps-for-solutions-that-may-impact-your-migration)
- [Microsoft Sentinel Gap analysis between agents](https://learn.microsoft.com/en-us/azure/sentinel/ama-migrate#gap-analysis-between-agents)
- [Change Tracking and Inventory using Azure Monitoring Agent doesn't support or has the following limitations](https://learn.microsoft.com/en-us/azure/automation/change-tracking/overview-monitoring-agent?tabs=win-az-vm#current-limitations)
- [Microsoft Defender for Cloud - strategy and plan towards Log Analytics Agent (MMA) deprecation - Microsoft Community Hub](https://techcommunity.microsoft.com/t5/microsoft-defender-for-cloud/microsoft-defender-for-cloud-strategy-and-plan-towards-log/ba-p/3883341)

### Table: Summary AMA parity status

| Service                                 | What it does                                                                                                                                                                                                                     | Status                                                                             | Parity                                                                                                                                                                             |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Agent health                            | Monitors agent heartbeat                                                                                                                                                                                                         | Deprecating. You can query the heartbeat. AMBA already has an Alert Rule for this. | N/A                                                                                                                                                                                |
| Sentinel                                | Security information and event management                                                                                                                                                                                        | Public Preview - Migrated to AMA                                                   | Windows Firewall Logs (Private preview), Application and service logs                                                                                                              |
| Change Tracking                         | This feature tracks changes in virtual machines hosted in Azure, on-premises, other clouds                                                                                                                                       | GA - Migrated to AMA                                                               | Parity                                                                                                                                                                             |
| Azure Monitor --> VM Insights           | Monitoring VMs                                                                                                                                                                                                                   | GA - Migrated to AMA                                                               | Parity                                                                                                                                                                             |
| Update Management                       | Manages VM patches and updates                                                                                                                                                                                                   | GA - Migrated to Azure Update Management (AUM) that does not require an agent      |                                                                                                                                                                                    |
| SQL Vulnerability Assessment Solution   | Helps discover, track, and remediate potential database vulnerabilities                                                                                                                                                          | GA - Migrated to AMA and is now part of Microsoft Defender for SQL                 | Parity                                                                                                                                                                             |
| SQL Advanced Thread Protection Solution | Detects anomalous activities indicating unusual and potentially harmful attempts to access or exploit databases                                                                                                                  | GA - Migrated to AMA and is now part of Microsoft Defender for SQL                 | Parity                                                                                                                                                                             |
| SQL Assessment Solution                 | Identifies possible performance issues and evaluates that your SQL Server is configured to follow best practices.                                                                                                                | GA - Now part of SQL best practices assessment.                                    | Current ALZ Status 'Removed' due to LAW deployment constraint with ALZ design principles (requires LAW per subscription), ALZ team will work with relevant product team to address |
| MDfC for Servers                        | Provide server protections through Microsoft Defender for Endpoint or extended protection with just-in-time network access, file integrity monitoring, vulnerability assessment, and more.                                       | GA (See parity column for detail) - Migrated to MDC (Agentless)                    | Features in development: FIM, Endpoint protection discovery recommendations, OS Misconfigurations (ASB recommendations). Features on backlog: Adaptive Application controls        |
| MDfC for SQL Server Virtual Machines    | Protect your entire database estate with attack detection and threat response for the most popular database types in Azure to protect the database engines and data types, according to their attack surface and security risks. | GA - Migrated to AMA                                                               |                                                                                                                                                                                    |

## Summary of changes to ALZ Code and Policies

### Removed ARM resources.

- Agent Health: Deprecated.
- Change Tracking (Automation account)
- Update Management (Automation account)
- VM Insights (Legacy solution/ MMA)
- SQL Assessment (Legacy solution)
- Sql Vulnerability Assessment (Legacy solution)
- Sql Advanced Threat Protection (Legacy solution)

### Removed Azure Policy Assignments

- PolicySetDefinition: Enable Azure Monitor for Virtual Machine Scale Sets / Legacy - Enable Azure Monitor for Virtual Machine Scale Sets
- PolicySetDefinition: Enable Azure Monitor for VMs / Legacy - Enable Azure Monitor for VMs

## New ARM Resources

- User Assigned Managed Identity
  - Name: id-ama-prod-<region>-001
- Data collection rules
  - dcr-changetracking-prod-<region>-001
  - dcr-defendersql-prod-<region>-001
  - dcr-vminsights-prod-<region>-001

## New Custom Policy Definitions

| Policy Definition / Policy Initiative                                                                                                                                                                                               | Child Policy Definitions                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Policy Initiative <br> [Configure periodic checking for missing system updates on azure virtual machines and Arc-enabled virtual machines](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Deploy-AUM-CheckUpdates.html) | Windows: [59efceea-0c96-497e-a4a1-4eb2290dac15](https://www.azadvertizer.net/azpolicyadvertizer/59efceea-0c96-497e-a4a1-4eb2290dac15.html) <br> Linux: [59efceea-0c96-497e-a4a1-4eb2290dac15](https://www.azadvertizer.net/azpolicyadvertizer/59efceea-0c96-497e-a4a1-4eb2290dac15.html) <br> Windows: [bfea026e-043f-4ff4-9d1b-bf301ca7ff46](https://www.azadvertizer.net/azpolicyadvertizer/bfea026e-043f-4ff4-9d1b-bf301ca7ff46.html) <br> Linux: [bfea026e-043f-4ff4-9d1b-bf301ca7ff46](https://www.azadvertizer.net/azpolicyadvertizer/bfea026e-043f-4ff4-9d1b-bf301ca7ff46.html) |
| Policy Definition <br> [Do not allow deletion of specified resource and resource type](https://www.azadvertizer.net/azpolicyadvertizer/DenyAction-DeleteResources.html)                                                             |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |

## New Policy Assignments

| Policy Definition / Policy Initiative (Set Definition) | Name                                                                                                                                                                                                         |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Policy Initiative                                      | [Enable Azure Monitor for VMSS with Azure Monitoring Agent(AMA)](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/f5bf694c-cca7-4033-b883-3a23327d5485.html)                                       |
| Policy Initiative                                      | [Enable Azure Monitor for VMs with Azure Monitoring Agent(AMA)](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/924bfe3a-762f-40e7-86dd-5c8b95eb09e6.html)                                        |
| Policy Initiative                                      | [Enable Azure Monitor for Hybrid VMs with AMA](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/2b00397d-c309-49c4-aa5a-f0b2c5bc6321.html)                                                         |
| Policy Initiative (Custom)                             | [Configure periodic checking for missing system updates on azure virtual machines and Arc-enabled virtual machines](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Deploy-AUM-CheckUpdates.html) |
| Policy Initiative                                      | [Enable Change Tracking and Inventory for Arc-enabled virtual machines](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/53448c70-089b-4f52-8f38-89196d7f2de1.html)                                |
| Policy Initiative                                      | [Enable Change Tracking and Inventory for virtual machines](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/92a36f05-ebc9-4bba-9128-b47ad2ea3354.html)                                            |
| Policy Initiative                                      | [Enable ChangeTracking and Inventory for virtual machine scale sets](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/c4a70814-96be-461c-889f-2b27429120dc.html)                                   |
| Policy Initiative                                      | [Enable Defender for SQL on SQL VMs and Arc-enabled SQL Servers](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/de01d381-bae9-4670-8870-786f89f49e26.html)                                       |
| Policy Definition                                      | [Do not allow deletion of the User Assigned Managed Identity used by AMA](https://www.azadvertizer.net/azpolicyadvertizer/DenyAction-DeleteResources.html)                                                   |
