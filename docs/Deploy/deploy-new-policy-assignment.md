# Deploy Policy assignment

This article will explain how to deploy Policy assignments for `platform` and `landing zones` in your Azure environments that has been discovery in the [previous article](discover-environment.md). The following approach will deploy Policy assigment and deploy the target state defined in the policy.

## Deployment artifact overview

It is important, that you are familiar with the AzOps folder structure that has been created during the environment discovery and repository initialization. To describe the desired state of Platform Subcriptions and Landing Zone we apply changes only in the _managementgroupscope_.parameters.json in the .AzState folder. This is how the folder structure should look like for your environment:

```bash
    azops
    └───Tenant Root Group
        ├───<prefix>                              # NEW company root management group
        │   ├───.AzState
        │   │   └───<YourCompanyName>.parameters.json
        │   ├───<prefix>-landing Zones
        │   │   └───.AzState
        │   │       └───LandingZones.parameters.json
        │   ├───<prefix>-platform
        │   │   └───.AzState
        │   │       └───Platform.parameters.json
        │   ├───<prefix>-sandbox
        │   │   └───.AzState
        │   │       └───Sandbox.parameters.json
        │   └───<prefix>-decommissioned
        │       └───.AzState
        │           └───Decommissioned.parameters.json
        ├───.....
```

Each _managementgroupscope_.parameters.json file has the following section, and it is the most important part of the parameter files and the section you have to primarily apply changes to using this guide. You can learn more about the *.parameters.json schema [here](./ES-schema.md).

``` bash
    # empty part of a parameter json file after initialization
    "properties": {
        "policySetDefinitions": [],
        "roleAssignments": [],
        "policyAssignments": [],
        "policyDefinitions": [],
        "roleDefinitions": []
    }
```

There are two groups of properties in this section _\*Definitions\*_ and _\*Assignments\*_.  

__Definitions:__ All the definitions (`policy`, `role` and `policySet`) have been deployed if you have used the green field approach. Policy definitions have been deployed on the 'YourCompanyName' Management Group scope and with this in the 'YourCompanyName'.parameters.json file.
>Note: In the Azure portal `policySetDefinitions` is also known as an initiative. It represents a set of Azure Policy definition.

__Assignments :__ The assignments (`role`, `policy`) can be deployed at any Management Group scope as long as the definition exisits on the same scope or above. To simplify the management, it is highly recommended to reduce the number of scopes where you assign Azure Policy and RBAC roles. In the Enterprise-Scale reference implementation we recommend to do assignment at the following three scopes only:

* 'YourCompanyName' __Management Group__ scope for all companywide policies
* Platform Subscription scope for Azure Policy deploying Platform resourses
* Landing Zones __Management Group__ scope for all Landing Zone specific Azure Policy

## Assign Azure Policy

Changes in the platform will always be deployed via a feature branch. The described flow below has to be repeated for all changes in your Azure environment.

1. Create a feature branch in GitHub

2. Add the policy assignment to the target scope

    To do the assignments for `policyAssignments` and `roleAssignments` the _managementGroupName_.parameters.json need to be updated a second time as done it for the defintions.  

    Three scopes for the assignment need to be considered to follow the Enterprise-Scale reference implementation:

   * 'YourCompanyName' Management Group scope
   * Landing Zones Management Group scope
   * _connectivity_ / _management_ / _identity Subscription scope

    As a reference for Azure Policy assignment you can select a reference Azure Policy assignment in the [azopsreference](../../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState) folder. Filter files with _policyAssignments_ in the name. After you copied the object replace all the values with the value  \<replace-me\>, these needs to be done mainly for the attributes `policyDefinitionId` and `scope`.

   * `policyDefinitionId`: Full resource ID (including scope path) of the definition
   * `scope`: Assignment scope for the definition

``` bash
    ....
    # here an empty example for the policyAssigments
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

3. Commit change to the feature branch and create a Pull Request to the `master` branch. GitHub Actions runs a PR check and pushes the changes to the target Azure enviroment.

4. You can monitor the status in the Actions log. Once all the checks are successful you have to squash and merge your changes to the master branch.

>Note: If the Azure Policy assigments fails please re-run the checks a second time. There is currently a known problem with the Azure Policy assigment on Azure which the product team is currently fixing.

>Note: For the repective Azure Policy assignment please see the examples in the [Contoso reference article](../reference/contoso/Readme.md).
