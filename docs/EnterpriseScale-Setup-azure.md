# Configure Azure permissions for ARM tenant deployments

This article will guide you through the process to configure permissions to your Azure environment to do ARM tenant level deployments.

> Note: The steps below requires you to use an identity that is local to the Azure AD, and **_not_** Guest user account due to known restrictions.

Enterprise-Scale reference implementation requires permission at tenant root scope "/" to be able to configure Management Group and create/move subscription. In order to grant permission at tenant root scope "/", users in "AAD Global Administrators" group can temporarily elevate access, to manage all Azure resources in the directory.

Once UAA role is enabled, User Access Administrator can grant **_other users and service principles_** within organization to deploy/manage Enterprise-Scale reference implementation by granting "Owner" permission at tenant root scope "/".

Once permission is granted to other users and service principles, you can safely disable "User Access Administrator" permission for the "AAD Global Administrator" users. For more information please follow this article [elevated account permissions](https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin)

## 1. Elevate Access to manage Azure resources in the directory

1.1 Sign in to the Azure portal or the Azure Active Directory admin center as a Global Administrator. If you are using Azure AD Privileged Identity Management, activate your Global Administrator role assignment.

1.2 Open Azure Active Directory.

1.3 Under _Manage_, select _Properties_.
![alt](https://docs.microsoft.com/en-us/azure/role-based-access-control/media/elevate-access-global-admin/azure-active-directory-properties.png)

1.4 Under _Access management for Azure resources_, set the toggle to Yes.

![alt](https://docs.microsoft.com/en-us/azure/role-based-access-control/media/elevate-access-global-admin/aad-properties-global-admin-setting.png)

## 2. Grant Access to User at root scope "/" to deploy Enterprise-Scale reference implementation

Please ensure you are logged in as a user with UAA role enabled in AAD tenant and logged in user is not a guest user.

Bash

````bash
az role assignment create  --scope '/' --role 'Owner' --assignee-object-id $(az ad user show -o tsv --query objectId --id '<replace-me>@<my-aad-domain.com>')
````

PowerShell

````powershell
#get object Id of the user
$user = Get-AzADUser -UserPrincipalName '<replace-me>@<my-aad-domain.com>'

#Assign Owner role to Tenant root scope ("/") as a User Access Administrator
New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $user.Id
````

Please note, it may take up to 15-30 minutes for permission to propagate at tenant root scope. It is highly recommended that you log out and log back in.

## Next steps

Please proceed with [deploying reference implementation](./EnterpriseScale-Deploy-reference-implentations.md).
