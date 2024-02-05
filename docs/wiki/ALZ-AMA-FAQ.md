## In this Section

- [What to do if you have a need for a feature that is not in AMA, not GA, and not available in an alternative solution?](#What-to-do-if-you-have-a-need-for-a-feature-that-is-not-in-AMA,-not-GA,-and-not-available-in-an-alternative-solution?)
- [Migration guidance for existing customers?](#Migration-guidance-for-existing-customers?)

- [Why do I need an User-Assigned Managed Identity?](#Why-do-I-need-a-User-Assigned-Managed-Identity?)
- [Why do I need Data Collection Rules?](#Why-do-I-need-Data-Collection-Rules?)
- [Custom Policies and Assignments](#Custom-Policies-and-Assignments)
- [MMA deprecation vs Legacy Solutions in Log Analytics Workspace](#MMA-deprecation-and-Legacy-Solutions-in-Log-Analytics-Workspace)

---

## What to do if you have a need for a feature that is not in AMA, not GA, and not available in an alternative solution?

The ALZ team will assess solutions for parity ongoing. Please review the AMA parity Gaps table [here](./ALZ-AMA-Update#table-ama-parity-status) for the latest updates and guidance.

If you have any additional questions or concerns, please do not hesitate to raise a support ticket for further assistance.

## Migration guidance for existing customers?

Currently the ALZ Portal Accelerator Deployment has been updated. Brownfield migration guidance and Bicep and Terraform updates are to follow in short-term.

## Why do I need a User-Assigned Managed Identity?

Managed identity must be enabled on Azure virtual machines, as this is required for authentication.

A user-assigned Managed identity is recommended for large-scale deployments, as you can create a user-assigned managed identity once and share it across multiple VMs, which means it's more scalable than a system-assigned managed identity. If you use a user-assigned managed identity, you must pass the managed identity details to Azure Monitor Agent via extension settings, which we do automatically through ARM/ Policy. Running the ALZ Portal Accelerator will create a User Assigned Managed Identity for each subscription that was selected.

## Why do I need Data Collection Rules?

A data collection rule (DCR) is a configuration that defines the data collection process in Azure Monitor. A DCR specifies what data should be collected and where to send that data. As part of the current deployment 3 DCRs are created to collect data for VM Insights, Change Tracking and Defender for SQL.

## Custom Policies and Assignments

Our intention is to use Built-in Policies, however there are scenarios where custom policies are deployed to provide additional flexibility. For example, Built-In policies may contain certain hardcoded default values, or assign highly privileged roles, that conflict with ALZ principles.

## MMA deprecation and Legacy Solutions in Log Analytics Workspace

It's important to highlight that while MMA deprecation is in August 2024, this doesn't necessarily impact the Legacy Solutions in Log Analytics. The following Solutions are still deployed as part of the current version:

- Sentinel: Is only deployed through ALZ, which is still achieved by deploying the Solution. We don't deploy additional configurations. Consult [AMA migration for Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/ama-migrate) for more information.
- Change Tracking: Aside from the solution being deployed in Log Analytics, we deploy the new components like DCRs and policies to enable Change Tracking through AMA.

## Why is a Policy disbled in the "Configure SQL VMs and Arc-enabled SQL Servers to install Microsoft Defender for SQL and AMA with a user-defined LA workspace" initiative?

The Microsoft Defender for SQL are custom policies based on the built-in policies. These are made custom to add additional flexibility for resource naming and placement, as well as excluding certain resources from being deployed through Policy. The disabled policy didn’t add any additional value at this moment as the configurations it deploys are handled in the ARM template. 

