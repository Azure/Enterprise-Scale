# Create new empty subscription into a management group

The ARM template provided in this folder can be used to create new, empty subscriptions into the targeted management group.

## Parameters

- "subscriptionAliasName": It is recommended that the subscription alias name is the same as the displayName to ensure easier manageability
- "billingAccountId": Provide the full resourceId for the enrollmentAccount. E.g., "/providers/Microsoft.Billing/billingAccounts/{billingAccountName}/enrollmentAccounts/{enrollmentAccountName}"
- "targetManagementGroup": Provide the last segment of the management group resourceId for the target management group in order to place the subscription directly under a management group. E.g., "/providers/Microsoft.Management/managementGroups/{mgmtGroupId}" where "mgmtGroupId" is the expected input.

````json

    "parameters": {
        "subscriptionAliasName": {
            "type": "string",
            "metadata": {
                "description": "Provide a name for the alias. This name will also be the display name of the subscription."
            }
        },
        "billingAccountId": {
            "type": "string",
            "metadata": {
                "description": "Provide the full resourceId of the MCA or the enrollment account id used for subscription creation."
            }
        },
        "targetManagementGroup": {
            "type": "string",
            "metadata": {
                "description": "Provide the resourceId of the target management group to place the subscription."
            }
        }
    },
````

## Scope escape

This ARM template is using the "scope escape" property on the resource in order to create a tenant level resource (subscription aliases) while being invoked as a management group deployment

````json

        {
            "scope": "/", // routing the request to tenant root
            "name": "[parameters('subscriptionAliasName')]",
            "type": "Microsoft.Subscription/aliases",
            "apiVersion": "2020-09-01",
            "properties": {
                "workLoad": "Production",
                "displayName": "[parameters('subscriptionAliasName')]",
                "billingScope": "[parameters('billingAccountId')]",
                "managementGroupId": "[tenantResourceId('Microsoft.Management/managementGroups/', parameters('targetManagementGroup'))]"
            }
        }
````
## Deploy using AzOps

See these [instructions](https://github.com/Azure/Enterprise-Scale/wiki/Create-Landingzones) for how to use this template with the AzOps GitHub Actions/DevOps pipeline.

## Deploy using Azure PowerShell

````pwsh
New-AzManagementGroupDeployment `
            -Name <name> `
            -Location -<location> `
            -ManagementGroupId <mgmtGroupId> `
            -TemplateUri "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/examples/landing-zones/empty-subscription/emptySubscription.json"
````

## Deploy using Azure CLI

````cli
az deployment mg create \
  --name <name> \
  --location <location> \
  --management-group-id <mgmtGroupId> \
  --template-uri "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/examples/landing-zones/empty-subscription/emptySubscription.json"