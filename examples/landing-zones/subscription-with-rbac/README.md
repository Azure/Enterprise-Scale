# Create new subscription and grant an SPN access via RBAC

The ARM template provided in this folder can be used to create new subscription into corp, online, or sanboxes management group, and optionally create a new - or use existing Service Principal that will be gratned access to the subscription

## Parameters

- "subscriptionAliasName": It is recommended that the subscription alias name is the same as the displayName to ensure easier manageability
- "billingAccountId": Provide the full resourceId for the enrollmentAccount. E.g., "/providers/Microsoft.Billing/billingAccounts/{billingAccountName}/enrollmentAccounts/{enrollmentAccountName}"
- "targetManagementGroup": Provide the last segment of the management group resourceId for the target management group in order to place the subscription directly under a management group. E.g., "/providers/Microsoft.Management/managementGroups/{mgmtGroupId}" where "mgmtGroupId" is the expected input.

````json

    "parameters": {
        "enterpriseScaleCompanyPrefix": {
            "type": "string",
            "maxLength": 10,
            "metadata": {
                "description": "Provide a prefix (max 10 characters, unique at tenant-scope) for the Management Group hierarchy and other resources created as part of Enterprise-scale."
            }
        },
        "subscriptionAliasName": {
            "type": "string",
            "metadata": {
                "description": "Provide alias (and displayName) for the subscription"
            }
        },
        "targetManagementGroup": {
            "type": "string",
            "metadata": {
                "details": "Select targeted management group that the subscription will land into"
            }
        },
        "billingAccountId": {
            "type": "string",
            "metadata": {
                "description": "Provide the resourceId for the enrollment account or MCA"
            }
        },
        "principalId": {
            "type": "array",
            "metadata": {
                "description": "Provide principalId for the user/group/service principal that should be granted access"
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
                "billingScope": "[parameters('billingAccountId')]"
            }
        }
````
## Deploy via Azure Portal

| Agreement types | ARM Template | Description |
|:-------------------------|:-------------|:---------------|
| Enterprise Agreement (EA) |[![Deploy To Azure](https://learn.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fexamples%2Flanding-zones%2Fsubscription-with-rbac%2FsubscriptionWithRbac.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale%2Fmain%2Fexamples%2Flanding-zones%2Fsubscription-with-rbac%2Fportal-subscriptionWithRbac.json)| Create subscription with RBAC for SPN
| Microsoft Customer Agreement  | Coming soon


## Deploy using AzOps

See these [instructions](https://github.com/Azure/Enterprise-Scale/wiki/Create-Landingzones) for how to use this template with the AzOps GitHub Actions/DevOps pipeline.

## Deploy using Azure PowerShell

````pwsh
New-AzManagementGroupDeployment `
            -Name <name> `
            -Location -<location> `
            -ManagementGroupId <mgmtGroupId> `
            -TemplateUri "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/examples/landing-zones/subscription-with-rbac/subscriptionWithRbac.json"
````

## Deploy using Azure CLI

````cli
az deployment mg create \
  --name <name> \
  --location <location> \
  --management-group-id <mgmtGroupId> \
  --template-uri "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/examples/landing-zones/subscription-with-rbac/subscriptionWithRbac.json"