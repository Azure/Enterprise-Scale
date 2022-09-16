## Enterprise-Scale Platform DevOps and Automation

### In this section:

- [Enable deployment of Landing Zones with Infrastructure as Code using Github and Github Actions](#reference-implementation-deployment)
- [Validation post deployment (GitHub)](#validation-post-deployment-github)
- [Operating the Azure platform using AzOps (Infrastructure as Code with GitHub Actions)](#operating-the-azure-platform-using-azops-infrastructure-as-code-with-github-actions)

---

### Enable deployment of Landing Zones with Infrastructure as Code using Github and Github Actions

You can choose to bootstrap your CI/CD pipeline (GitHub with GitHub actions). Provide your GitHub user/org name, the preferred name of the GitHub repository that is to be created, as well as the PA token that the deployment will use to create a new repository and discover the Enterprise-Scale deployment ARM templates and merge them into your main branch.

![Graphical user interface, text, application  Description automatically generated](./media/clip_image015.png)

1.1.1    To create a PA token, follow the instructions here: https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token

1.1.2    Ensure the PA token has the following permissions:

![Graphical user interface, text, application  Description automatically generated](./media/github_developer_createPAT.png)

> For Microsoft employees who are enrolled into the Azure GitHub organization, you must also authorize the PA token to this Org!

![Graphical user interface, text, application, email  Description automatically generated](./media/github_developer_enablesso.png)

![Graphical user interface, text, application, email  Description automatically generated](./media/github_developer_disablesso.png)

1.2  Lastly, a Service Principal is required for Git to authenticate to – and be authorized to your Azure tenant. You can either use an existing Service Principal or create a new one. The Service Principal will be granted *Owner* permission on the top level Management Group that gets created.

1.2.1    If using an existing Service Principal, ensure you have the *client secret* as this must be provided as the *Password* for the service principal and confirm it has the right level of permission.

![Graphical user interface, text, application  Description automatically generated](./media/clip_image020.jpg)

1.2.2    If creating a new Service Principal, select "Create New" and click on Make selection” and the portal will open a new blade for app registration

![img](./media/clip_image022.png)

 ![img](./media/clip_image024.png)

Once the App has been registered, you must explicitly create a new secret.

 ![img](./media/clip_image026.png)

 ![img](./media/clip_image028.jpg)

Make sure to note down the “Value” of the new client secret.
 ![img](./media/clip_image030.jpg)

The default API Permissions for this App are “User.Read”, as depicted below:

![img](./media/clip_image032.jpg)

 After copying the secret, go to “Enterprise-Scale Landing Zones” (in the upper left) to return to the deployment.

 ![img](./media/clip_image034.png)

 At this point, paste the client secret value of the newly created client secret from a few step above into the Password field.

 ![Graphical user interface, application  Description automatically generated](./media/clip_image035.png)

### Validation post deployment (GitHub)

Once Enterprise-Scale has deployed and you enabled the CI/CD bootstrap, you should validate in your GitHub account that:

*    A new repository has been created, with the name provided during setup.

![Graphical user interface, text, application  Description automatically generated](./media/clip_image040.png)

*    4 Secrets are created into this GitHub repository.

ARM_CLIENT_ID = Service Principal

ARM_CLIENT_SECRET = Service Principal Client Secret created in the Tenant
ARM_SUBSCRIPTION_ID = The management subscription ID created in the Tenant
ARM_TENANT_ID = Tenant ID of the Azure Tenant that was used to create ESLZ

![img](./media/clip_image042.jpg)

*    A Pull Request is either in progress or has completed and automatically merged into the main branch.

![img](./media/clip_image044.png)

*    The Azure hierarchy that got created using ARM templates as part of the Enterprise-Scale setup, such as management groups, subscription organization as well as policy definitions, policy assignments and role assignments are hydrated and organized into Git:

![Graphical user interface  Description automatically generated with medium confidence](./media/clip_image046.jpg)


![Graphical user interface, application  Description automatically generated](./media/clip_image048.jpg)

*    In each folder, you will find the ARM templates that were deployed at the scopes during the Enterprise-Scale setup. E.g., on the intermediate root group, you will find all policy definitions, and depending on the selection you made during the deployment, you will find resource templates in the platform subscriptions. Users can – whenever they are ready, start using these templates and bring their own templates to manage the platform using ARM templates and infrastructure as code.

![Graphical user interface, application  Description automatically generated](./media/clip_image050.jpg)

## Operating the Azure platform using AzOps (Infrastructure as Code with GitHub Actions)

When you have deployed Enterprise-Scale with GitHub integration, you will have a ready-to-go repository with integrated GitHub Actions containing all the ARM templates that were used during deployment, organized in the following way:

*    Management group tree structure represented as folders in Git

*    Subscriptions represented as folders in their respective management group folder in Git

*    Resource Groups represented as folders in their respective subscription folder in Git

*    Policy Definitions, Policy Set Definitions, Role Definitions, and Role Assignments as composite ARM resource templates partitioned at the folder representing the respective scope in Azure (management group, subscription)

*    Resources (e.g., virtual networks, Log Analytics workspace, Automation account etc.) represented as composite ARM resource templates into their respective resource group (folder)

You can edit/update the existing ARM templates in your repository and GitHub actions will push (deploy) to the respective Azure scope. You can also author and bring your own ARM templates and deploy them to the respective Azure scope.

The following section will demonstrate how one can operationalize the Enterprise-Scale platform using ARM templates, via the GitHub repository that got created using AzOps (GitHub Actions).

### What is AzOps?

AzOps is an opinionated CI/CD pipeline to operationalize the Azure *platform* and *landing zones* that enables organizations to focus on the ARM template development, and not having to deal with multiple deployment scripts targeting different Azure scopes. The organization and folder structure in Git is dynamically representing the Azure graph (management groups (parent, child relationships), and subscription organization), so the platform operators can easily determine at which *scope* they want to invoke the ARM template deployment by simply making a PR with the ARM template(s) and parameter files (optionally), and AzOps will invoke the deployment accordingly.

Also, when there’s a new *scope* (management groups, subscriptions, and resource groups) being created, either explicitly via the pipeline – and also out of band (via Portal, CLI, PS etc.), AzOps will discover these and represent them correctly back into Git.

### Create new Policy Assignment for validation

Enterprise-Scale with its Policy Driven Governance principle relies heavily on Azure Policy to determine the goal state of the overall platform. As an example, this exercise will demonstrate how a developer can make a new policy assignment at the “Online” landing zone management group scope.

1.   In GitHub, navigate to your repository and click on the ‘azops’ folder. From here, navigate to your <prefix>-online folder which represents the management group for all your online landing zones.

![img](./media/clip_image052.jpg)

2.   Click on ‘Add file’, and ‘Create new file’.

3.   Name the file ‘locationAssignment.json’

4.   Copy and paste the following ARM template json

``` json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-08-01/managementGroupDeploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "policyAssignmentEnforcementMode": {
            "type": "string",
            "allowedValues": [
                "Default",
                "DoNotEnforce"
            ],
            "defaultValue": "DoNotEnforce",
            "metadata": {
                "description": "Input will determine if the policyAssignment should be enforced or not."
            }
        },
        "policyDefinitionId": {
            "type": "string",
            "defaultValue": "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c",
            "metadata": {
                "description": "Provide the policyDefinition resourceId"
            }
        },
        "policyAssignmentName": {
            "type": "string",
            "defaultValue": "AllowedLocations"
        },
        "policyDescription": {
            "type": "string",
            "defaultValue": "Policy to ringfence Azure regions."
        },
        "listOfAllowedLocations": {
            "type": "array",
            "defaultValue": [
                "westeurope",
                "northeurope"
            ]
        }
    },
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.Authorization/policyAssignments",
            "apiVersion": "2019-09-01",
            "name": "[parameters('policyAssignmentName')]",
            "identity": {
                "type": "SystemAssigned"
            },
            "location": "[deployment().location]",
            "properties": {
                "description": "[parameters('policyDescription')]",
                "displayName": "[parameters('policyDescription')]",
                "policyDefinitionId": "[parameters('policyDefinitionId')]",
                "enforcementMode": "[parameters('policyAssignmentEnforcementMode')]",
                "parameters": {
                    "listOfAllowedLocations": {
                        "value": "[parameters('listOfAllowedLocations')]"
                    }
                }
            }
        }
    ]
}
```

5.   Examine the file and note that we are using default values for the parameters. You could modify these, or you could also provide a locationAssignment.parameters.json file to provide the parameters.

6.   On the ‘Commit new file’ option, select ‘Create a new branch for this commit and start a pull request’, and give it a name.

![Graphical user interface, text, application, email  Description automatically generated](./media/ESLZ-location-assignment-policy.JPG)

7.   Click ‘Propose new file' and on the next page, click 'Create Pull Request." A new Pull Request is being created which will trigger the Push workflow. Go to Actions to monitor the process.

![Graphical user interface, text, application, chat or text message  Description automatically generated](./media/clip_image056.jpg)

8.   Once completed, the pull request should automatically merge.

9.   In Azure portal, you can navigate to the <prefix>-online management group and verify that the deployment resource got created and deployed successfully. Each deployment invoked via AzOps will have an ‘AzOps’ prefix.

![Graphical user interface, text, application, email  Description automatically generated](./media/clip_image058.jpg)

10.  Navigate to ‘Policies’ on the <prefix>-online management group and verify that there’s a new assignment called ‘Policy to ring-fence Azure regions’.

![Graphical user interface, text, application, email  Description automatically generated](./media/clip_image060.jpg)

11.  Click on ‘Edit assignment’ to verify that the Policy is not being enforced but will only scan for compliance and validate resources per the policy rule defined in the policy definition.

![Text  Description automatically generated with low confidence](./media/clip_image062.jpg)

Once the policy compliance scan has completed, you will get a compliance result for the policy you assigned to validate the effect is working as intended, before going to the next step to update the enforcement mode. I.e., this policy will prevent resources being created outside of the allowed locations specified.

You can now merge the pull request and delete the branch.

### Update a Policy Assignment to enforce

In this exercise, we will modify the existing policy assignment to ensure the policy effect will be enforced.

1.   Navigate the locationAssignment.json file you placed into the <prefix>-online folder, representing the online landing zone.

2.   Click on ‘Edit this file’ ![img](./media/clip_image063.png)

3.   Change the parameter “policyAssignmentEnforcementMode” default value to be ‘Default’.

![Graphical user interface, text, application, email  Description automatically generated](./media/clip_image065.jpg)

4.   On the ‘Commit changes’ dialogue box, select ‘Create a new branch for this commit and start a pull request’, and provide a branch name. Click ‘Propose changes’ and create the pull request

![Graphical user interface, text, application, email  Description automatically generated](./media/ESLZ-Update-location-assignment-policy.JPG)

This will now start the AzOps push workflow and deploy the template with the updated property so that the policy effect will be enforced (in this case, deny resource creation outside of the ringfenced Azure regions).

Once the job has completed, you can revisit the policy in Azure portal and see that the policy enforcement is set to ‘Enabled’.

![Graphical user interface, text, application, email  Description automatically generated](./media/clip_image069.jpg)

You can now merge the pull request and delete the branch.

### Create new Role Assignment on a landing zone

To grant a user, a group, or a service principal access to a landing zone (subscription), you can use the following ARM template where you provide the principalId (object id of the user, group, or service principal) as input to the parameter, and place the template into the subscription folder into your landing zone management group(s).

Replace Provide-Principal-Id with Id of the principal.

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "principalId": {
            "type": "string",
            "defaultValue": "<Provide-Principal-Id>",
            "metadata": {
                "description": "Provide the objectId of the principal (user, group, SPN, managed identity etc.) that will be granted RBAC at scope."
            }
        },
        "roleDefinitionId": {
            "type": "string",
            "defaultValue": "b24988ac-6180-42a0-ab88-20f7382dd24c",
            "metadata": {
                "description": "Provide the id of the built-in roleDefinition. Default is 'Contributor'."
            }
        }
    },
    "resources": [
        {
            "type": "Microsoft.Authorization/roleAssignments",
            "apiVersion": "2017-09-01",
            "name": "[guid(parameters('principalId'))]",
            "properties": {
                "principalId": "[parameters('principalId')]",
                "roleDefinitionId": "[concat('/providers/Microsoft.Authorization/roleDefinitions/', parameters('roleDefinitionId'))]"
            }
        }
    ]
} 
```
