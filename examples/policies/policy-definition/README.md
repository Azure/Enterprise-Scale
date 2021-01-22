# Create new policy definition

The ARM template provided in this folder shows how a new policy definition is created at the targeted scope.

## Parameters

- "policyName": Provide a name for the policyDefinition
- "policyDescription": Provide a description for the policy
- "namePattern": Provide the naming pattern for this policy to ensure naming convention for all resource names

````json

    "parameters": {
        "policyName": {
            "type": "string",
            "metadata": {
                "description": "Provide name for the policyDefinition."
            }
        },
        "policyDescription": {
            "type": "string",
            "metadata": {
                "description": "Provide a description for the policy."
            }
        },
        "namePattern": {
            "type": "string",
            "metadata": {
                "description": "Provide naming pattern."
            }
        }
    },
````

## Deploy using AzOps

See these [instructions](../../../docs/Deploy/deploy-new-arm.md) for how to use this template with the AzOps GitHub Actions/DevOps pipeline.

## Deploy using Azure PowerShell

````pwsh
New-AzManagementGroupDeployment `
            -Name <name> `
            -Location -<location> `
            -ManagementGroupId <mgmtGroupId> `
            -TemplateUri "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/examples/policies/naming-convention/naming-convention.json"
````

## Deploy using Azure CLI

````cli
az deployment mg create \
  --name <name> \
  --location <location> \
  --management-group-id <mgmtGroupId> \
  --template-uri "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/examples/policies/naming-convention/naming-convention.json"