
# Contents

This article describes how to trigger local definitions/assignments deployments from your computer whenenver you need to validate deployments without using GitHub actions.

For local debugging purposes, you can trigger a deployment from your computer by running the following commands from a PowerShell terminal.

 Before running the commands below:

* Ensure you are located in the root folder of your local clone.
* Ensure you have made either definitions or assignments changes in your local clone as described on the [Deploy platform infrastructure](./Deploy-platform-infra.md) and [Deploy landing zones](./Deploy-lz.md) articles.

    ```powershell
    Import-Module .\src\AzOps.psd1 -force
    Get-ChildItem -Path .\src -Include *.ps1 -Recurse | ForEach-Object {.$_.FullName}
    Invoke-AzOpsGitPush -Verbose
    ```

Those commands will trigger a definition or assignment deployment (depending which one you configured in your local folder structure) without involving the GitHub actions deployment process described on the previous sections.