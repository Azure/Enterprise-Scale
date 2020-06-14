# Discovery and initialize environment

This article explains how to perform a discovery of your existing Azure environment. Then, as part of the discovery process, your GitHub environment will be initialized to reflect your current Azure environment.

## Discover existing envrionment
In a terminal type the following commands by replacing the placeholders (<...>) with your actual values:

**PowerShell:**
```powershell
$username = "codertocat"
$password = "<PAT_TOKEN>"
$uri = "https://api.github.com/repos/<Your GitHub ID>/<Your Repo Name>/dispatches"
$params = @{
    Uri = $uri
    Headers = @{
        "Accept" = "application/vnd.github.everest-preview+json"
        "Content-Type" = "application/json"
        "Authorization" = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password))))"    
        }
    Body = @{
        "event_type" = "activity-logs"    
        } | ConvertTo-json
    }
Invoke-RestMethod -Method "POST" @params
```

**Bash:**
```bash
curl -u "Codertocat:<PAT Token>" -H "Accept: application/vnd.github.everest-preview+json"  -H "Content-Type: application/json" https://api.github.com/repos/<Your GitHub ID>/<Your Repo Name>/dispatches --data '{"event_type": "activity-logs"}'
```

This triggers a GitHub Action which runs a discovery of the Azure environment. Please check progress in the GitHub repo in the Actions tab. The following steps will be executed automatically to ensure that the current Azure environment is represented in your GitHub repository:

* Create a `system` branch
* Create a Pull Request (PR) with the name `Azure Change Notification` (`system`  -> `master`)

## Verfiy PR and merge with `master` branch

1. The `system` branch contains the discovered Azure environment (`azops` folder). Verfiy the Files changed tab in the PR.  
2. Merge PR to `master`.
3. Delete `system` branch.

The current Azure environment is now represented in the `azops` folder of the master branch. With this step discovery of the configured environment is completed. The next section will explain how to deploy policy assignements.
