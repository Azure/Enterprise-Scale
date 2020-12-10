# Azure DevOps - Setup Guide

Please complete the following steps at [Configure Azure permissions for ARM tenant deployments](setup-github.md) page before continuing:

* Step 3 - Create SPN and Grant Permission
* Step 5 - Configure your repo to update changes from upstream

## Implementation notes

The [AzOps](https://github.com/Azure/AzOps/) (CI/CD) process was initially designed to run on GitHub. However, we recognise that many customers have invested in Azure DevOps and continue to work with it. The Azure DevOps (ADO) implementation uses the same Docker image and appropriates it for use in ADO. This is achieved by passing in the correct environment variables for the process to work.

## Supported scenarios

We currently support all AzOps scenarios. However, the procedures slightly deviates from the review process in GitHib. ADO starts build validation process when the PR is created. To support this scenario the manual review process (approval) has to be completed before the `AzOps - Push` will start. In ADO, environments will be used in the push pipeline.
ADO deployment environments supporting `Approvals and checks`. For `AzOps - Push` approvals need to be configured after the pipeline creation.

## How to implement

There are two option to get started in ADO:

1. Start with an empty repo
   When you start with an empty repository, simply add the [`.azure-pipelines`](..\..\.azure-pipelines) folder from the [Enterprise-Scale GitHub repo](https://github.com/Azure/Enterprise-Scale) to the new and empty repository.

2. Import the repository
   Within the Azure DevOps project, import the [Enterprise-Scale](https://github.com/Azure/Enterprise-Scale) repository from GitHub. Instructions are [here](https://docs.microsoft.com/azure/devops/repos/git/import-git-repository).

### Configure the pipelines

Add two new pipelines, selecting the existing files `.azure-pipelines/azops-pull.yml` & `.azure-pipelines/azops-push.yml`. It is a good practice to name these pipelines `AzOps - Pull` & `AzOps - Push`.
When adding the pipelines define a new secret variable to each of the pipelines:

* AZURE_CREDENTIALS - Set the value to the JSON string created by the steps in the [GitHub - Setup Guide](setup-github.md). (escape the quotes in the json string from `"` to  `\"`)

_Optional step to configure approval steps_
The `AzOps - Push` push pipeline creates an ADO environment on this environment select `Approvals and checks` and configure an Approval for a user or group.

### Configure repository permissions

The build service account `<Project> Build Service (<Organization>)` must have the following permissions on the repository:

* `<Project>\Contributors`

### Configure branch policies

In order for the pull pipeline to run, set the `main` branch to [require build verification](https://docs.microsoft.com/en-us/azure/devops/repos/git/branch-policies).
It is also recommend to allow only `squash` merge types from branches into `main`.

### Discover Environment

If the `AzOps - Pull` pipeline is triggered manually the pipeline will discover the Azure environment.

The following steps will be executed automatically to ensure that the current Azure environment is represented in your Azure DevOps repository:

* Current Management Group, Subscriptions, Policy Definitions and Policy Assignments are discovered and RESTful representation of the resources are saved as ARM template parameters file.
* If changes are detected that is not represented in your `main` branch, it will create `system` branch representing your current configuration as ARM templates parameter file.
* Create a Pull Request (PR) with the name `Azure Change Notification` (`system`  -> `main`) and auto-merge into `main`.

Please now continue on the [Discover Environment](discover-environment.md#verify-pr-and-merge-with-main-branch) page, at the *"Verify PR and merge with `main` branch"* heading.
