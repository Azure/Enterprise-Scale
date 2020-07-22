# Deploy your own ARM templates with AzOps pipeline

This article describes how AzOps pipeline can be used to deploy resources in Azure by using standard ARM template and parameter files. This capability enables to bring “your own” ARM template and parameter files to deploy resources at any scope.

To deploy a standard ARM template and its corresponding parameters file by using the AzOps pipeline, it is only required to copy the ARM template and its corresponding parameter files into the desired scope in your local clone of your GitHub repo. For example, you can copy your ARM template at root, management group or subscription scope, depending on the resources that you would like to deploy. Once you have copied your ARM template and parameters files at the desired scope submit a pull request. This will instruct AzOps to deploy the ARM template into the corresponding scope in Azure.

To demonstrate this capability, we will use a custom ARM template to deploy a new resource group into a subscription. 

> Before you start, please ensure, that your azops folder is in sync with your Azure environment.

1. Create a new feature branch. One way to create a feature branch from Visual Studio Code is by launching the command palette (CTRL + SHIFT + P) and select Git: Create Branch.

2. Create two new files (for example, new-rg.json and new-rg.parameters.json) in the __azops\Tenant Root Group (GUID)\path-to-your-subscription\subscriptionName (GUID)__ folder with the following contents:

     new-rg.json
    ```json
    {
    "$schema": "https://schema.management.azure.com/schemas/2019-08-01/subscriptionDeploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "rgName": {
            "type": "string"
        },
        "rgLocation": {
            "type": "string"
        }
    },
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.Resources/resourceGroups",
            "apiVersion": "2019-05-10",
            "location": "[parameters('rgLocation')]",
            "name": "[parameters('rgName')]",
            "properties": {}
        }
    ],
    "outputs": {}
    }
    ```

    new-rg.parameters.json
     ```json
    {
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "rgName": {
            "value": "new-pipeline-rg"
        },
        "rgLocation": {
            "value": "northeurope"
        }
      }
    }
    ```  

> Important:  
> The parameters file must have the same name as your template file, and must be followed by the .parameters.json. In our example, if the template file is called new-rg.json, the parameters file must be called new-rg.**parameters**.json

3. Commit changes to your feature branch and create a pull request.

4. __Wait for deployment to succeed__ and merge pull request to **main** branch. **Feature** branch can be deleted after the successful merge.

After a successful deployment, the resources defined in your template will be deployed at the selected scope. For the example above, a resource group called new-pipeline-rg will be deployed in an Azure subscription.

