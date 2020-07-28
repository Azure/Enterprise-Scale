# Configure Azure permissions for ARM tenant deployments & setup GitHub

This article will guide you through the process to configure permissions to your Azure environment to do ARM tenant level deployments, and setup GitHub in preparation to use [AzOps GitHub actions](https://github.com/Azure/AzOps/)
>Note: The steps below requires you to use an identity that is local to the Azure AD, and *not* a Guest user account due to known restrictions.

## 1. Create a new GitHub repository for your organization

[Enterprise-Scale GitHub repo](https://github.com/Azure/Enterprise-Scale) as a template in your GitHub organization.

## 2. Elevate Access to manage Azure resources in the directory

To grant permission for SPN at tenant root scope "/", please [elevate your access to manage Azure resources](../EnterpriseScale-Setup-azure.md).

## 3. Create SPN and Grant Permission

>Note: The Service Principal requires "Owner" permission at the tenant root scope (/) in order to complete all the requisite steps (roleAssignments, creation of management groups, subscriptions, policyAssignments etc.), and the permission will be inherited to all child scopes in Azure. Similar, if you want a user to deploy the reference implementation(s) using Azure Portal, a roleAssignment at the tenant root (/) is required with "Owner".

"App registration" needs to be enabled on the Azure AD Tenant to self-register an Application (Option 1).

Option 1 (App registration enabled)

```powershell
#Create Service Principal and assign Owner role to Tenant root scope ("/")
$servicePrincipal = New-AzADServicePrincipal -Role Owner -Scope / -DisplayName AzOps
```

Option 2 (App registration disabled)

````powershell
#Create Service Principal as the Azure AD administrator
$servicePrincipal = New-AzADServicePrincipal -Role Owner -Scope / -DisplayName AzOps -SkipAssignment

#Assign Owner role to Tenant root scope ("/") as a User Access Administrator
New-AzRoleAssignment -ApplicationId $servicePrincipal.ApplicationId -RoleDefinitionName Owner -Scope /
````

Export the SPN information. Perform this step in the same PowerShell instance the SPN was created.

```powershell
#Prettify output to print in the format for AZURE_CREDENTIALS to be able to copy in next step.
[ordered]@{
    clientId = $servicePrincipal.ApplicationId
    displayName = $servicePrincipal.DisplayName
    name = $servicePrincipal.ServicePrincipalNames[1]
    clientSecret = [System.Net.NetworkCredential]::new("", $servicePrincipal.Secret).Password
    tenantId = (Get-AzContext).Tenant.Id
    subscriptionId = (Get-AzContext).Subscription.Id
} | ConvertTo-Json
```

> Note: It can take up to 15 minutes for newly added permission to reflect for SPN

## 4. Connect GitHub to Azure

To create the following secrets on GitHub, navigate to the main page of the repository and under your repository name, click **Settings**, click **Secrets**, and then click **New secret**.

* Name: AZURE_CREDENTIALS

```json
{
  "clientId": "<<appId>>",
  "displayName": "<<redacted>>",
  "name": "<<redacted>>",
  "clientSecret": "<<redacted>>",
  "tenantId": "<<redacted>>",
  "subscriptionId": "<<default-subscriptionId>>"
}
```

* Name: AZURE_ENROLLMENT_ACCOUNT_NAME [Optional]

    This parameter is required if you are planning to create new Subscription though this workflow. This secret must contain the **ObjectId** for the Azure Enrollment Account. You can obtain the id by running ```Get-AzEnrollmentAccount```

```bash
ObjectId
```

## 5. Configure your repo to update changes from upstream

1. Add upstream repo to your local repository to get latest changes

Follow these steps in order to synchronize the latest changes from the upstream repo into your local repositories.

Run the following git commands once you change your directory to your local fork to add a reference to the upstream repo

```shell
git remote -v
git remote add upstream https://github.com/Azure/Enterprise-scale.git
git remote -v
```

Execute the following git commands when you want to synchronize changes from upstream repo into your local fork:

```shell
git fetch upstream
git pull upstream main --allow-unrelated-histories
```

## Next steps

Once GitHub and Azure is ready, you can [Deploy Enterprise-Scale reference implementation in your own environment](./configure-own-environment.md).
