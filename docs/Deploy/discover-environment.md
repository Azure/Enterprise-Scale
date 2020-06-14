# Discovery and initialize environment

This article will explain how to perform a discovery of your existing Azure environment. Then, as part of the discovery process, your GitHub environment will be initialized to reflect your current Azure environment.

1. In a bash terminal type the following command, by replacing the placeholders with your actual values:

  ```bash    
    curl -u "Codertocat:<PAT Token>" -H "Accept: application/vnd.github.everest-preview+json"  -H "Content-Type: application/json" https://api.github.com/repos/<Your GitHub ID>/<Your Repo Name>/dispatches --data '{"event_type": "activity-logs"}'
  ```

2. Monitor the discovery process by ...