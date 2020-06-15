# Initialize Git With Current Azure configuration

This article explains how to perform a discovery of your existing Azure environment. Then, as part of the discovery process, your GitHub will reflect your current Azure environment consisting of Management Group, Subscriptions, Policy Definitions and Policy Assignments.


## Initialize existing environment

Your repo should contain GitHub Action [/workflows/azops.yml](../../.github/workflows/azops.yml) that can pull latest configuration from Azure. Before invoking action, please ensure Actions are enabled for your repo. AzOps GitHub Action is maintained at [https://github.com/Azure/azops](https://github.com/Azure/azops).

In a terminal, type the following commands by replacing the placeholders (<...>) with your actual values:

**PowerShell:**
```powershell
$GitHubUserName = "<GH UserName>"
$GitHubPAT = "<PAT TOKEN>"
$GitHubRepoName = "<Repo Name>"
$uri = "https://api.github.com/repos/$GitHubUserName/$GitHubRepoName/dispatches"
$params = @{
    Uri = $uri
    Headers = @{
        "Accept" = "application/vnd.github.everest-preview+json"
        "Content-Type" = "application/json"
        "Authorization" = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $GitHubUserName,$GitHubPAT))))"
        }
    Body = @{
        "event_type" = "activity-logs"
        } | ConvertTo-json
    }
Invoke-RestMethod -Method "POST" @params
```

**Bash:**
```bash
curl -u "<GH UserName>:<PAT Token>" -H "Accept: application/vnd.github.everest-preview+json"  -H "Content-Type: application/json" https://api.github.com/repos/<Your GitHub ID>/<Your Repo Name>/dispatches --data '{"event_type": "activity-logs"}'
```

Please check progress in the GitHub repo in the Actions tab and wait for it complete. At present, if your environment contains management group or subscription with duplicate display name, initialization of discovery will fail. This is precautionary check to avoid accidental misconfiguration and we highly recommend unique names for management groups and subscriptions. There is work planned to override Display Name with Name ETA 7/31.

The following steps will be executed automatically to ensure that the current Azure environment is represented in your GitHub repository:

* Current Management Group, Subscriptions, Policy Definitions and Policy Assignments are discovered and RESTful representation of the resources are  saved as ARM Template parameters file.
* If changes are detected that is not represented in your `master` branch, it will create `system` branch representing your current configuration as ARM templates parameter file.
* Create a Pull Request (PR) with the name `Azure Change Notification` (`system`  -> `master`)

## Verify PR and merge with `master` branch

Verify the Files changed tab in the PR.

1. Merge PR to `master`.
2. Delete `system` branch.

The current Azure environment is now represented in the `azops` folder of the master branch. You can invoke this action at any time, when you want to retrieve current Azure configuration when you suspect configuration drift due to OOB changes in Azure.