# Discovery and initialize environment

This article will explain how to perform a discovery of your existing Azure environment. Then, as part of the discovery process, your GitHub environment will be initialized to reflect your current Azure environment.

1. In a bash terminal type the following command, by replacing the placeholders (<...>) with your actual values:

  ```bash
    curl -u "Codertocat:<PAT Token>" -H "Accept: application/vnd.github.everest-preview+json"  -H "Content-Type: application/json" https://api.github.com/repos/<Your GitHub ID>/<Your Repo Name>/dispatches --data '{"event_type": "activity-logs"}'
  ```

> Note: If you start with a green field deployment make sure that [this step](configure-own-environment.md#green-field-environment) has been successfully been deployed.

This triggers a GitHub Action which runs a discovery of the Azure environment. Please check progress in the GitHub repo in the Actions tab. The following steps will be executed to ensure that the current Azure environment is represented in the GitHub repository:

* Create a `system` branch
* Create a Pull Request (PR) with the name `Azure Change Notification` (`system`  -> `master`)

2. Verfiy PR and merge with `master` branch

   a. The `system` branch contains the discovered Azure environment (`azops` folder). Verfiy the Files changed tab in the PR.  
   b. Merge PR to `master`.

> Note: It is safe to delete the `system` branch at this point in time as it is created as part of the discovery process.

The current Azure environment is now represented in the `azops` folder of the master branch. With this step discovery of the configured environment is completed. The next section will deploy policy assignements.
