# Create new connected subscription into a management group

The ARM template provided in this folder can be used to create new, connected subscriptions into the targeted management group.

## Pre-requisites

This ARM template takes a dependency on the 'Deploy-VNET-HubSpoke' policy provided by Enterprise-Scale reference implementations, and will invoke the template deployment in the policyDefinition as part of assigning the policy to the newly created landing zone (subscription).
When deploying the Enterprise-Scale reference implementations, the definition will be located at the top level management group, and the resource Id will be "/providers/Microsoft.Management/managementGroups/<prefixProvidedDuringSetup>/Microsoft.Authorization/policyDefinitions/Deploy-VNET-HubSpoke"

Also, a connectivity subscription must exist in the <prefix>-connectivity management group containing the virtual network hub you will connect the corp connected landing zones (subscriptions) to.

## Policy Driven Governance

One of the design principles of Enterprise-Scale is to use Policy Driven Governance to ensure autonomy and a secure, compliant goal state for the Azure platform and the landing zones (subscriptions). This template will ensure that the virtual network is created in the landing zone and also subject to continuous compliance by Azure Policy, so organizations can ensure their corp connected landing zones are connected to the connectivity hub through the life-cycle of the landing zone.

## Parameters

- "subscriptionAliasName": It is recommended that the subscription alias name is the same as the displayName to ensure easier manageability
- "billingAccountId": Provide the full resourceId for the enrollmentAccount. E.g., "/providers/Microsoft.Billing/billingAccounts/{billingAccountName}/enrollmentAccounts/{enrollmentAccountName}"
- "targetManagementGroup" Provide the last segment of the management group resourceId for the target management group in order to place the subscription directly under a management group. E.g., "/providers/Microsoft.Management/managementGroups/{mgmtGroupId}" where "mgmtGroupId" is the expected input.
- "lzVnetCidr": Provide the CIDR for the landing zone vNet that will be created
- "lzVnetRegion": Provide the region for where the virtual network will be created
- "esConnectivityHubId": Provide the resourceId of the existing virtual network in the connectivity subscription

````json

    "parameters": {
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
        "lzVnetCidr": {
            "type": "string",
            "metadata": {
                "description": "Provide the CIDR for the new VNet that will be created. Ensure this is not overlapping with other vnet in your Azure environment."
            }
        },
        "lzVnetRegion": {
            "type": "string",
            "metadata": {
                "description": "select the Azure region where the VNet will be created."
            }
        },
        "esConnectivityHubId": {
            "type": "string",
            "metadata": {
                "description": "Provide the resourceId of the virtual network in the connectivity hub where you will connect the landing zone VNet to."
            }
        }
    },
````

## Scope escape

This ARM template is using the "scope escape" property on the resource in order to create a tenant level resource (subscription aliases) while being invoked as a management group deployment

````json

        {
            "scope": "/", // routing the request to tenant root
            "name": "[parameters('subAliasName')]",
            "type": "Microsoft.Subscription/aliases",
            "apiVersion": "2020-09-01",
            "properties": {
                "workLoad": "Production",
                "displayName": "[parameters('subAliasName')]",
                "billingScope": "[parameters('billingId')]",
                "managementGroupId": "[tenantResourceId('Microsoft.Management/managementGroups/', parameters('mgmtGroupId'))]"
            }
        }
````
## Inner and outer scope expression evaluation

This ARM template will pass states from outer to inner during the deployment in order to use the generated subscriptionId to target subsequent deployments.

````json

        {
            "type": "Microsoft.Resources/deployments",
            "apiVersion": "2019-10-01",
            "name": "[concat('create-', parameters('subscriptionAliasName'))]",
            "scope": "[concat('Microsoft.Management/managementGroups/', parameters('targetManagementGroup'))]",
            "location": "[deployment().location]",
            "properties": {
                "mode": "Incremental",
                "expressionEvaluationOptions": {
                    "scope": "inner"
                },
                "parameters": {
                    // Sharing parameter values from outer to inner execution scope
                    "subAliasName": {
                        "value": "[parameters('subscriptionAliasName')]"
                    },
                    "mgmtGroupId": {
                        "value": "[parameters('targetManagementGroup')]"
                    },
                    "billingId": {
                        "value": "[parameters('billingAccountId')]"
                    }
                },
                "template": {
                    "$schema": "https://schema.management.azure.com/schemas/2019-08-01/managementGroupDeploymentTemplate.json#",
                    "contentVersion": "1.0.0.0",
                    "parameters": {
                        // parameters for inner scope
                        "subAliasName": {
                            "type": "string"
                        },
                        "mgmtGroupId": {
                            "type": "string"
                        },
                        "billingId": {
                            "type": "string"
                        }
                    },
                    "resources": [
                        {
                            "scope": "/", // routing the request to tenant root
                            "name": "[parameters('subAliasName')]",
                            "type": "Microsoft.Subscription/aliases",
                            "apiVersion": "2020-09-01",
                            "properties": {
                                "workLoad": "Production",
                                "displayName": "[parameters('subAliasName')]",
                                "billingScope": "[parameters('billingId')]",
                                "managementGroupId": "[tenantResourceId('Microsoft.Management/managementGroups/', parameters('mgmtGroupId'))]"
                            }
                        }
                    ],
                    "outputs": {
                        // Referencing the guid generated for the subscription to be used in subsequent (optional) deployments to this subscription
                        "subscriptionId": {
                            "type": "string",
                            "value": "[reference(parameters('subAliasName')).subscriptionId]"
                        }
                    }
                }
            }
        },
````

## Deploy using AzOps

See these [instructions](https://github.com/Azure/Enterprise-Scale/wiki/Create-Landingzones) for how to use this template with the AzOps GitHub Actions/DevOps pipeline.

## Deploy using Azure PowerShell

````pwsh
New-AzManagementGroupDeployment `
            -Name <name> `
            -Location -<location> `
            -ManagementGroupId <mgmtGroupId> `
            -TemplateUri "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/examples/landing-zones/connected-subscription/connectedSubscription.json"
````

## Deploy using Azure CLI

````cli
az deployment mg create \
  --name <name> \
  --location <location> \
  --management-group-id <mgmtGroupId> \
  --template-uri "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/examples/landing-zones/connected-subscription/connectedSubscription.json"
