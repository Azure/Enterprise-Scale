# ARM templates for Management Groups

This folder contains example ARM templates for organizations to create new subscriptions into management groups.

## Recommendations

In order to create subscriptions at scale using ARM templates, we strongly recommends the following settings, convention and authoring styles.

* Always use the “scope” resource property to route the request to the tenant root

    As management groups should be placed into a management group, we recommend to invoke the template deployment at the targeted management group, and use the "scope" property to interact with the tenant RP directly vs invoking the deployment at the tenant root (/). From a security perspective, this reduces need for having blast-radius permissions in the Azure tenant.

    The example resource below shows how to use the "scope" property and route the request to the tenant root.

    ````json
    {
            "scope": "/", // routing the request to the tenant root
            "type": "Microsoft.Management/managementGroups",
            "apiVersion": "2020-05-01",
            "name": "[parameters('mgmtGroupName')]",
            ...
    }
    ````

* Always specify the parent management group to avoid creating management group directory under the root group

    Management groups can be created into the existing hierarchy, and default behavior when not specifying the parentId will create the management group under the root directly. To avoid this, always provide the parentId as an input parameter that should have the same value as the management group id used when invoking the deployment.

    The example below shows the "parent object" property to determine the parent and child relationship, using a conditon to avoid failure if not provided.

    ````json
        "properties": {
                "displayName": "[parameters('mgmtGroupName')]",
                "details": {
                    "parent": {
                        "id": "[if(not(empty(parameters('parentMgmtGroupId'))), concat('/providers/Microsoft.Management/managementGroups/', parameters('parentMgmtGroupId')), json('null'))]"
                    }
                }
    ````

* Always use the same name for the management group id and the display name

    We recommend to use the same name for the management group id and the management group display name and also to ensure uniqueness in your tenant

    The example below shows that the 'mgmtGroupName' parameter is used for both the management group id name, and the displayName of the management group.

    ````json

        {
            "scope": "/", // routing the request to the tenant root
            "type": "Microsoft.Management/managementGroups",
            "apiVersion": "2020-05-01",
            "name": "[parameters('mgmtGroupName')]",
            "properties": {
                "displayName": "[parameters('mgmtGroupName')]",
    ````

* Enable the Management Group hierarchy settings

    It is recommend to enable the management group hierarchy settings in your Azure tenant to ensure that role-based-access-control is required to create, update, and delete management groups.

    ![management group hierarchy settings](../../docs/wiki/media/mg-hierarchy-settings.png)
