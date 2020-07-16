# Initialize Git With Current Azure configuration

This article explains how to perform a discovery of your existing Azure environment. Then, as part of the discovery process, your GitHub will reflect your current Azure environment consisting of Management Group, Subscriptions, Policy Definitions and Policy Assignments.


## Initialize existing environment

Your repo should contain GitHub Action [/workflows/azops.yml](../../.github/workflows/azops.yml) that can pull latest configuration from Azure. Before invoking action, please ensure Actions are enabled for your repo. AzOps GitHub Action is maintained at [https://github.com/Azure/azops](https://github.com/Azure/azops).

In a terminal, type the following commands by replacing the placeholders (<...>) with your actual values:

### Github Cli (Does not Require PAT token)

```bash
gh api -X POST repos/<Your GitHub ID>/<Your Repo Name>/dispatches --field event_type="GitHub CLI"
````

### PowerShell

```powershell
$GitHubUserName = "<GH UserName or Github Enterprise Organisation Name>"
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
        "event_type" = "PowerShell"
        } | ConvertTo-Json
    }
Invoke-RestMethod -Method "POST" @params
```

### Bash

```bash
curl -u "<GH UserName>:<PAT Token>" -H "Accept: application/vnd.github.everest-preview+json"  -H "Content-Type: application/json" https://api.github.com/repos/<Your GitHub ID>/<Your Repo Name>/dispatches --data '{"event_type": "Bash"}'
```

Please check progress in the GitHub repo in the Actions tab and wait for it complete. At present, if your environment contains Management Group or Subscription with duplicate Display Name, initialization of discovery will fail. This is a precautionary check to avoid accidental misconfiguration and we highly recommend unique names for Management Groups and Subscriptions. There is work planned to override Display Name with ResourceName.

The following steps will be executed automatically to ensure that the current Azure environment is represented in your GitHub repository:

* Current Management Group, Subscriptions, Policy Definitions and Policy Assignments are discovered and RESTful representation of the Resources are  saved as ARM Template parameters file.
* If changes are detected that is not represented in your `main` branch, it will create `system` branch representing your current configuration as ARM templates parameter file.
* Create a Pull Request (PR) with the name `Azure Change Notification` (`system`  -> `main`)

## Verify PR and merge with `main` branch

Once the discovery process has completed, select the PR that was automatically created (it will be called Azure Change Notification). You can verify the changes discovered by clicking in the Files tab within the PR. In order to accept these changes into your `main` branch:

1. Merge PR to `main`.
2. Delete `system` branch.

The current Azure environment is now represented in the `azops` folder of the main branch. You can invoke this action at any time, when you want to retrieve current Azure configuration when you suspect configuration drift due to OOB changes in Azure.

## Next steps

Once GitHub will reflect your existing Azure environment, you can [deploy new Policy assignment](./deploy-new-policy-assignment.md).