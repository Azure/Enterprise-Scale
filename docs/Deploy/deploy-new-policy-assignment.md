# Deploy Policy assignment

This article will explain how to deploy Policy assignments for `Platform` and `Landing Zones` in your Azure environments that has been discovery in the [previous article](discover-environment.md). The following approach will deploy Policy assignment and deploy the target state defined in the policy.

## Deployment artifact overview

It is important, that you are familiar with the AzOps folder structure that has been created during the environment discovered and repository initialization. To describe the desired state of Platform Subscriptions and Landing Zone we apply changes only in the _managementgroupscope_.parameters.json in the .AzState folder. This is how the folder structure should look like for your environment:

```bash
    AzOps
    └───Tenant Root Group
        ├───<YourCompanyName>      # NEW company root Management Group
        │   ├───.AzState
        │   │   └───Microsoft.Management-managementGroups_<YourCompanyName>.parameters.json
        │   ├───Landing Zones
        │   │   └───.AzState
        │   │       └───Microsoft.Management-managementGroups_LandingZones.parameters.json
        │   ├───Platform
        │   │   └───.AzState
        │   │       └───Microsoft.Management-managementGroups_Platform.parameters.json
        │   ├───Sandbox
        │   │   └───.AzState
        │   │       └───Microsoft.Management-managementGroups_Sandbox.parameters.json
        │   └───Decommissioned
        │       └───.AzState
        │           └───Microsoft.Management-managementGroups_Decommissioned.parameters.json
        ├───.....
```

Each Microsoft.Management-managementGroups_<_managementgroupscope_>.parameters.json file has the following section, and it is the most important part of the parameter files and the section you have to primarily apply changes to using this guide. You can learn more about the *.parameters.json schema [here](./ES-schema.md).

``` bash
    # Empty part of a parameter JSON file after initialization
    "properties": {
        "policySetDefinitions": [],
        "roleAssignments": [],
        "policyAssignments": [],
        "policyDefinitions": [],
        "roleDefinitions": []
    }
```

There are two groups of properties in this section _\*Definitions\*_ and _\*Assignments\*_.

__Definitions:__ All the definitions (`policy`, `role` and `policySet`) have been deployed if you have used one of the Enterprise-Scale reference implementations (such as Contoso). Policy definitions have been deployed on the 'YourCompanyName' Management Group scope and with this in the 'YourCompanyName'.parameters.json file.
>Note: In the Azure portal `policySetDefinitions` is also known as an initiative. It represents a set of Azure Policy definition.

__Assignments :__ The assignments (`role`, `policy`) can be deployed at any Management Group scope as long as the definition exists on the same scope or above. To simplify the management, it is highly recommended to reduce the number of scopes where you assign Azure Policy and RBAC roles. In the Enterprise-Scale reference implementation we recommend to do assignment at the following three scopes only:

* 'YourCompanyName' __Management Group__ scope for all company wide policies
* Platform Subscription scope for Azure Policy deploying Platform Resources
* Landing Zones __Management Group__ scope for all Landing Zone specific Azure Policy

## Assign Azure Policy

In Enterprise-Scale reference implementation, changes in the platform are always deployed via a feature branch. The steps below have to be repeated whenever you want to make changes in your Azure environment.

1. Create a feature branch in GitHub

2. Add the policy assignment to the target scope

    For `policyAssignments` and `roleAssignments`, you will use the _managementGroupName_.parameters.json file.

    Enterprise-Scale reference implementation recommends the following three scopes for the assignments:

   * 'YourCompanyName' Management Group scope
   * Landing Zones Management Group scope
   * _Connectivity_ / _Management_ / _Identity_ Subscription scope

    Enterprise-Scale provides a set of sample Azure Policy assignments that you can use as reference when assigning policies to your environment. You can find these sample Policy assignment in the [azopsreference](../../azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState) folder. Filter files with _policyAssignments_ in the name. After you copied the object replace all the values with the value  \<replace-me\>, these needs to be done mainly for the attributes `policyDefinitionId` and `scope`.

   * `policyDefinitionId`: Full Resource ID (including scope path) of the definition
   * `scope`: Assignment scope for the definition

``` bash
    ....
    # here an empty example for the policyAssignments
    "policyAssignments": [
        {
            # Copy value object content of a Azure Policy from the azopsreference here.
        },
        {
            # Copy value object content of a Azure Policy from the azopsreference here.
        }
    ],
    ...
```

3. Commit change to the feature branch and create a Pull Request to the `main` branch. GitHub Actions runs a PR check and pushes the changes to the target Azure environment.

4. You can monitor the status in the Actions log. Once all the checks are successful you have to squash and merge your changes to the main branch.


>Note: For future, Azure Policy assignment please see the examples in the [Contoso reference article](../reference/contoso).

## Next steps

Once you have deployed new policy assignments, you can start [deploy Landing Zones](./deploy-landing-zones.md)