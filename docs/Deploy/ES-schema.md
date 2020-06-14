
# Azure Resource Manager templates

Azure Resource Manager (ARM) is the unified control-plane (global API front-door), and the gateway for all the CRUD operations for all resources in Azure.

One of the essential capabilities of ARM, is the template orchestration engine that allows users to declare their resource compositions, and deploy to one or more *scopes* in Azure.
With the philosophy that everything in Azure is a resource, that means you can declare the goal-state of your Azure tenant as a whole and all its resources using ARM templates.

This article will help you to familiarize with the [Enterprise scale ARM template](../../../../tree/master/template/tenant.json), which consist on one and only one ARM template (one template to rule them all). We recommend to also explore the [Examples](../../../../tree/master/examples) to understand how parameter files are used to provide the resources as objects to the template.

## ARM template objectives for Enterprise scale
Some of the key [design principles](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/design-principles) of Enterprise scale is to have a single control and management plane, be Azure native and aligned to the platform roadmap, and employ Azure Policy to enable policy driven governance and management. That means we rely on platform capabilities in order to compose and deploy the Enterprise scale architecture end-2-end.

The objectives includes:

- Any resource can be declared and deployd to Azure, using ARM templates
- Resources are configured and deployed in a consistent and deterministic way, using ARM template language expressions
- Deployments will target the appropriate ARM scope, subject to the resource compositions
- ARM will handle template validation, dependencies (both implicit and explicit), and the end-to-end orchestration
- The ARM template can be deployed using PowerShell, CLI, Portal, and directly from Git using GitHub Actions
- What we PUT, is also what we GET and vice versa
- Detection of drift for the resources within scope, and be able to reconcile into Git

Further, this excludes:

- A need for an overlay or custom orchestration to deploy and configure resources in Azure
- Having any infrastructure dependencies, e.g., existing subscription, management group etc.
- A need to learn a new language and deployment approach to Azure
- Imperative scripting

## Azure resources within scope of Enterprise scale

The following ARM resource types and deployment scopes are relevant for the Enterprise scale ARM template from a **platform** perspective, as it will build and operationalize the architecture itself. Any workload specific resource types (e.g., Microsoft.Compute/virtualMachines, Microsoft.Web/sites etc.) is **NOT** in scope.

| Resource Type          | Deployment Scope              | Description                                                        |
| ---------------------|--------------------|--------------------------------------------------------------------|
| Microsoft.Management/managementGroups          |Tenant root| Management groups, which can contain child management groups and subscriptions|
| Microsoft.Subscription/subscriptions          |Tenant root|Subscriptions, which will be the de-facto resource containers for workloads in Azure.|
| Microsoft.Management/managementGroups/subscriptions          |Tenant root|Placement of a subscription into a management group|
| Microsoft.Authorization/policyDefinitions          |Management group, subscription|Policy definitions can be created at management groups and subscriptions and can contain audit, deny, append, auditIfNotExists, deployIfNotExists, and modify policy effects|
| Microsoft.Authorization/policySetDefinitions          |Management group, subscription|PolicySetDefinitions can represent multiple policyDefinitions to simplify policyAssignment lifecycle|
| Microsoft.Authorization/policyAssignments         |Management group, subscription|PolicyAssignments will manifests the runtime representation of a policyDefinition at the given scope|
| Microsoft.Authorization/roleDefinitions          |Management group, subscription|Role-based access control definition, containing actions, notActions, dataActions, dataNotActions|
| Microsoft.Authorization/roleAssignments          |Management group, subscription|RoleAssignments will manifests the runtime representation of a roleDefinition at the given scope|

>Note: The Enterprise scale architecture that enables a policy driven governance and management will ensure that resource deployments to Resource Group scope from a platform perspective, such as virtual WAN, Log Analytics, diagnostics settings and more, are deployed using Azure Policy (policyDefinitions) with the **deployIfNotExists** effect. With regards to application teams; they can use any preferred method, tool, and interface when deploying their applications into the landing zones (subscriptions) that are constructed by the Enterprise scale platform architecture.

## Deployment sequencing for Enterprise scale ARM template

The ARM template for Enterprise scale is developed to honor the ARM graph and will start at the tenant root, so it can navigate across all scopes as needed per the resource type(s) that has been declared.
This is achieved by using logical operators and resource conditions so the ARM template can always resolve the correct scope(s) druing deployment runtime.

Examples:

- When a new management group is being declared, the ARM template will do a tenant root level deployment to create the management group into the new or existing management group hiearchy, and define parent/child relationships
- When a new subscription is declared into a management group, the ARM template will do a tenant level deployment to update the subscription placement into its management group.
- When a new policyAssignment is being declared, the deployment will start at tenant root level and do a nested deployment to the targeted scope for the assignment (which can be a management group or a subscription). This sequence is also the same for roleDefinitions.
- When a new policyDefinition and a policyAssignment is created, the deployment will first create the policyDefinition at scope, as the policyAssignment will have an implicit dependency using the reference() template function. This sequence is also the same for roleDefinitions and roleAssignments.
- When a new policyAssignment is being declared which references a policyDefinition with the "deployIfNotExist" effect with the deploymentScope set to subscription, the ARM template will invoke a template deployment from the policyDefinition directly to ensure the subscription is brought into its compliant goal state
- When multiple resources are declared at the same scope, the ARM template will deploy those in parallel

The illustration below shows an end-to-end deployment workflow across the Azure scopes (tenant, management group, subscription, resource group), where Enterprise scale ARM template deploys directly to tenant and management group scope, and policies using "deployIfNotExist" will carry out the deployments (also ARM template deployments) to the subscriptions, and the resource groups when they are being created.

![ARM template](./media/arm-template.png)

For additional infomration on how to use the Enterprise scale ARM template via GitHub actions and how to deploy manually, se the folowing articles:

[Deploy Enterprise scale platform infrastructure](./Deploy-platform-infra.md)

[Deploy Enterprise scale ARM template locally](./Trigger-local-deployment.md)