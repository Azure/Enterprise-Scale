# Setup GitHub Action for CI/CD

One of the **design goals of** the Enterprise-Scale reference implementation is to allow customers to transition between using the Azure Portal and Infrastructure-as-code seamlessly. Although the previous exercise used an ARM template to deploy the necessary Management Group hierarchy and Policy definitions in Azure, it did not really provide a way to manage changes made after initial deployment.

In this exercise you will learn how to fully use the Enterprise-Scale GitHub repository to create a DevOps pipeline using GitHub Actions for deploying resources to Azure, and reconcile changes made through tools outside the DevOps pipeline.

> Note: Enterprise-Scale AzOps is also supported on Azure DevOps, the instructions to setup AzOps using Azure DevOps are [here](../Deploy/setup-azuredevops.md).

To better understand this process, in this section you will leverage the **ES-management** Management Group that was created in the previous step [Deploy the Management Group structure and policy/PolicySet definitions](./deploy-tenant.md#deploy-the-management-group-structure-and-policypolicyset-definitions) and an Azure subscription which has been moved under it. We will now be a GitHub repository in your organization to discover the tenant, and save a RESTfull representation of the Azure environment in a GitHub repository, make changes to it and then get them deployed to your Azure environment.

## Configure GitHub

In this section we will create and configure a GitHub repository and run a discovery process of your Azure environment to initialize the repository with the current state of your environment. Once the state is represented in repository, we will be able to deploy resources by using infrastructure-as-code directly via GitHub Actions. Discovery is a one-time process to ensure the current baseline is established.

### Create a GitHub repository from Enterprise-Scale repo

To create a GitHub repository from the Enterprise-Scale repo as a template, execute the following steps.

1. Clone current [Enterprise-Scale repository](https://github.com/Azure/Enterprise-Scale) to your organization by clicking on **Use this template** function.

    ![Clone Enterprise-Scale repository](./media/wt-1.1-1.png)

2. On the **Create a new repository from Enterprise-Scale** window, create a new repo under your GitHub-ID. Provide a repository name (for example, `ES-IAB`). The repository can be created as **Public** or **Private** and the **Include all branches** should be unchecked.

    ![Create a new repository](./media/wt-1.1-2.png)

3. Once the new repository has been created under your GitHub-ID, click on **Code**, and copy the URL provided by clicking on the button highlighted.

    ![Clone repository localy](./media/wt-1.1-3.png)

4. On your local computer, launch Visual Studio Code and open the command palette (CTRL + SHIFT + P). In the command palette, type (or select) ```Git: clone```

    ![Git clone](./media/wt-1.1-4.png)

5. After selecting Git: Clone, paste the URL that you copied to the clipboard in your previous step (for example, https://github.com/yourGitHubID/your-RepoName.git), and then hit enter.

    ![_Figure_](./media/wt-1.1-5.png)

6. In the **Select folder** window, select a folder to save a local copy of the GitHub repo (for example, you can select **This PC > Documents > GitHub**), and then click **Select repository location**.

7. In the **Would you like to open the cloned repository?** pane, click **Open**.

    ![_Figure_](./media/wt-1.1-6.png)

    Visual Studio Code will open the local copy of the repo. You should see a series of folders and files on the left section. Ensure that you have checkout your main branch:

    ![_Figure_](./media/wt-1.1-7.png)

### Initialize repository

The Discovery/Initialization process will run entirely on GitHub. This guide uses Visual Studio Code to illustrate the process, but any other editor or GitHub online editing experience can be used. Follow these steps below to initialize:

1. In **Visual Studio Code**, click **Terminal > New Terminal**.

2. In the **TERMINAL WINDOW (PowerShell 7)** or any other **PowerShell 7** shell, execute the following command to log into your Azure tenant by using your Azure AD tenant admin account. Follow [this instructions here](../Deploy/setup-github.md#setup-github-and-azure-for-enterprise-scale) to enable your Azure AD tenant admin to access resources.

    ```PowerShell
    Connect-AzAccount -TenantId <your-tenant-id>
    ```

3. After you login, run the command below to create a service principal to be used for the GitHub integration. Make sure the **DisplayName** for the service principal is unique within your tenant.

    ```PowerShell
    $servicePrincipal = New-AzADServicePrincipal -Role Owner -Scope "/" -DisplayName es-<yourAlias>
    ```

4. Run the command below to retrieve the necessary information from the service principal that needs to be added to GitHub to integrate the git workflow with your Azure environment.

    ```PowerShell
    [ordered]@{
        clientId = $servicePrincipal.ApplicationId
        displayName = $servicePrincipal.DisplayName
        name = $servicePrincipal.ServicePrincipalNames[1]
        clientSecret = [System.Net.NetworkCredential]::new("",$servicePrincipal.Secret).Password
        tenantId = (Get-AzContext).Tenant.Id
        subscriptionId = (Get-AzContext).Subscription.Id
    } | ConvertTo-Json
    ```

5. Copy the output of the command above, you will need it to setup credentials in GitHub.

6. In your GitHub repo, click **Settings > Secrets**, and then click **New secret**.

    ![_Figure_](./media/wt-2.1-1.png)

7. Create a secret as described below.

    Name: **AZURE_CREDENTIALS**

   Paste the information that you got in the clipboard (the outcome from the last PowerShell step you executed). The outcome should look like this:

   ```PowerShell
   {
   "clientId": "xxxx-xxxx-xxxx-xxxx-xxxxx",
   "displayName": "es-xxxx",
   "name": "http://es-xxxx",
   "clientSecret": "xxxxxx-xxxx-xxxx-xxxx-xxxxxx",
   "tenantId": "xxxxxx-xxxx-xxxx-xxxx-xxxxxx",
   "subscriptionId": "xxxxxx-xxxx-xxxx-xxxx-xxxxxx"
   }
   ```

8. Once the secrets is created, you should see the following entries in the **Secrets** window.

    ![_Figure_](./media/wt-2.1-2.png)

9. In your GitHub repo, navigate to the main page of the repository. Click on **Settings** and scroll down to the **Merge button** section. Ensure the **Automatically delete head branches** option is selected.

    ![_Figure_](./media/wt-2.1-2.5.png)

10. Now, we will run discovery using GitHub Actions, this initializes your GitHub repo with your Azure environment. This uses the GitHub Actions `workflow_dispatch` trigger and requires requires the latest [`.github/workflows/azops-pull.yml`](../../../.github/workflows) file containing the `workflow_dispatch` section your current repo.

    Go to the **Actions** tab in your GitHub repository and select the **AzOps-Pull** workflow. Click on **Run workflow**, select _Branch: main_ and _Action to trigger = pull_ and start the process with **Run workflow** button.

    ![_Figure_](./media/wt-2.1-3.png)

    > **NOTE:**
    >If you prefer, execute the discovery process via commandline as described on this [article](../Deploy/discover-environment.md).

11. You should now see an GitHub Action running with the name **AzOps**.

    ![_Figure_](./media/wt-2.1-5.png)

    > **NOTE:**
    > If the discovery process fails, just re-run the workflow.

12. The GitHub Action in the previous step will create the following artifacts in your GitHub repository:

    - Current Management Group, Subscriptions, Policy Definitions and Policy Assignments are discovered, and RESTful representation of the resources are saved as ARM Template parameters file.

    - It will create **system** branch representing your current configuration as ARM template parameter file and merge it automatically into **main**.

> Note: When AzOps cannot perform the merge automatically it will create a _Azure Change Notification_ PR in your GitHub repository. This has then be resolved manually.

With this step you have completed the discovery and your **main** branch should contain an **azops** folder with a RESTful ARM API representation of the resources as ARM Template parameters file.
    ![_Figure_](./media/wt-2.1-7.png)

13. **Pull** the changes in the main branch to your local clone by launching the command palette **(CTRL + SHIFT + P)** in **Visual Studio Code** and type `Git: Pull` then press **Enter**. Alternatively, you can select the main branch at the bottom-left section in Visual Studio Code and then click on the Sync icon as depicted in the picture below.
    ![_Figure_](./media/wt-2.1-8.png)

## Configure default deployment regions

The ARM template deployment will be performed via GitHub Actions to a single region where the deployments will happen. This region needs to be the same you used for the initial ARM template deployment in step 4 in section [Deploy the Management Group structure and policy/PolicySet definitions](./deploy-tenant.md#deploy-the-management-group-structure-and-policypolicyset-definitions).

Please perform the following steps to configure the region for the template deployment:

1. Open the files **azops-pull.yml** and **azops-push.yml** in the folder **/**.**github/workflows** in your Visual Studio Code.

2. Change the **AZOPS_DEFAULT_DEPLOYMENT_REGION** attribute in the **env** section of **both** yml file.

    ![_Figure_](./media/wt-2.2-1.png)

    For example, for a deployment in the _North Europe_ Azure region, you would provide:

    `AZOPS_DEFAULT_DEPLOYMENT_REGION: "northeurope"`

    Since deployment names have to be unique across regions, you must select the region that you have used in portal to bootstrap Enterprise-Scale environment.

3. Commit changes to the main branch by launching the command palette **(CTRL + SHIFT + P)** in **Visual Studio Code** and type `Git: Commit` then press **Enter** and push it to your GitHub repository (remote) **(CTRL + SHIFT + P)** in **Visual Studio Code** and type `Git: push` then press **Enter**.

## Next steps

For the deployment using the GitHub CI/CD pipeline continue to the [next section](./use-git-pipeline.md).
