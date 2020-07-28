# Initialize Git with current Azure configuration

This article explains how to perform a discovery of your existing Azure environment. Then, as part of the discovery process, your GitHub will reflect your current Azure environment consisting of Management Group, Subscriptions, Policy Definitions and Policy Assignments.

## Initialize existing environment

Your repo should contain a GitHub Action [.github/workflows/azops-pull.yml](../../.github/workflows/azops-pull.yml) that can pull the current platform configuration state from Azure.

Before invoking this action, [please ensure Actions are enabled for your repo](https://docs.github.com/en/github/administering-a-repository/disabling-or-limiting-github-actions-for-a-repository).

AzOps is maintained at [https://github.com/Azure/azops](https://github.com/Azure/azops).

### How to trigger the Action

Depending on your preferred approach, there are a number of methods you can use to trigger the AzOps action in GitHub, including:

1. Github Actions web page
2. Github Cli
3. PowerShell
4. Bash

These are documented in the following section:

#### Github Actions web page (Manual)

1. Browse to the Actions tab of your repository at:<br> `github.com/<github_username>/<repository_name>/actions` use [this link](../../../../actions?query=workflow%3AAzOps-Pull) to navigate to the workflow in this repository.
2. From the list of Workflow, select `AzOps-Pull`
3. Select `Run workflow`
4. Check the branch and trigger entries<br><br>![Github Actions, Run workflow](./media/github-workflow-trigger-manual.png)<br>
5. Click the `Run workflow` button

#### Github Cli

```bash
gh api -X POST repos/<github_username>/<repository_name>/dispatches --field event_type="GitHub CLI"
```

#### PowerShell (Does require PAT token)

```powershell
$GitHubUserName = "<github_username>"
$GitHubPAT = "<pat_token>"
$GitHubRepoName = "<repository_name>"
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

#### Bash (Does require PAT token)

```bash
curl -u "<github_username>:<pat_token>" -H "Accept: application/vnd.github.everest-preview+json"  -H "Content-Type: application/json" https://api.github.com/repos/<github_username>/<repository_name>/dispatches --data '{"event_type": "Bash"}'
```

### What to do next

Please check progress in the GitHub repo in the Actions tab and wait for it complete.

The following steps will be executed automatically to ensure that the current Azure environment is represented in your GitHub repository:

* Current Management Group, Subscriptions, definitions and assignments are discovered and RESTful representation of the resources are  saved as ARM template parameters file.
* If changes are detected which are not represented in your `main` branch, it will create `system` branch representing your current configuration as ARM templates parameter file.
* Create a Pull Request (PR) with the name `Azure Change Notification` (`system` -> `main`)

## Verify PR and merge

Once the discovery process has completed, select the PR that was automatically created (`Azure Change Notification`). Verify the changes discovered by clicking in the Files tab within the PR. In order to accept these changes into your `main` branch:

1. Squash & merge PR into `main` branch.
2. Delete `system` branch.

The current Azure environment is now represented in the `azops` folder of the main branch. You can invoke this action at any time, when you want to retrieve current Azure configuration when you suspect configuration drift due to OOB changes in Azure.

## Next steps

Once GitHub will reflect your existing Azure environment, you can [deploy a new Policy Assignment](./deploy-new-policy-assignment.md).
