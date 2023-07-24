In some scenarios, it may be necessary to remove everything deployed by the AMBA solution. The instructions below detail execution of a PowerShell script to delete all resources deployed, including:

- Metric Alerts
- Activity Log Alerts
- Resource Groups (created for to contain alert resources)
- Policy Assignments
- Policy Definitions
- Policy Set Definitions
- Policy Assignment remediation identity role assignments

All resources deployed as part of the initial AMBA deployment and the resources created by dynamically by 'deploy if not exist' policies are either tagged, marked in metadata, or in description (depending on what the resource supports) with the value `_deployed_by_alz_monitor` or `_deployed_by_alz_monitor=True`. This metadata is used to execute the cleanup of deployed resources; _if it has been removed or modified the cleanup script will not include those resources_. 

## Cleanup Script Execution

### Download the script file

Follow the instructions below to download the cleanup script file. Alternatively, clone the repo from GitHub and ensure you are working from the latest version of the file by fetching the latest `main` branch.

 1. Navigate AMBA [project in GitHub](https://github.com/Azure/Enterprise-Scale)
 1. In the folder structure, browse to the `src/scripts` directory
 1. Open the **Start-AMBACleanup.ps1** script file
 1. Click the **Raw** button
 1. Save the open file as **Start-AMBACleanup.ps1**

### Executing the Script

1. Open PowerShell
1. Install the **Az.ResourceGraph** module: `Install-Module Az.ResourceGraph`
1. Change directories to the location of the **Start-AMBACleanup.ps1** script
1. Sign in to the Azure with the `Connect-AzAccount` command. The account you sign in as needs to have permissions to remove Policy Assignments, Policy Definitions, and resources at the desired Management Group scope.
1. Execute the script using the option below

**Generate a list of the resource IDs which would be deleted by this script:**

  ```powershell
  ./Start-AMBACleanup.ps1 -ReportOnly
  ```

**Show output of what would happen if deletes executed:**

  ```powershell
  ./Start-AMBACleanup.ps1 -WhatIf
  ```

**Delete all resources deployed by the ALZ-Monitor IaC without prompting for confirmation:**

  ```powershell
  ./Start-AMBACleanup.ps1 -Force
  ```
