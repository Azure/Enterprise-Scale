# Azure DevOps - Setup Guide

Please complete the following steps at [Configure Azure permissions for ARM tenant deployments](setup-github.md) page before continuing:

* Step 3 - Create SPN and Grant Permission
* Step 5 - Configure your repo to update changes from upstream

## Implementation notes

The [AzOps](https://github.com/Azure/AzOps/) (CI/CD) process was initially designed to run on GitHub. However, we recognise that many of our customers have invested in Azure DevOps and wish to continue to work with it. The Azure DevOps (ADO) implementation uses the same Docker image and appropriates it for use in ADO. This is achieved by passing in the correct environment variables for the process to work.

## Supported scenarios

We currently support all AzOps scenarios, **except for pull request review**. 

> This is in development and is estimated to be ready by 24 August 2020.

## How to implement

### Import the repository

Within the Azure DevOps project, import the [Enterprise-Scale](https://github.com/Azure/Enterprise-Scale) repository from GitHub.

https://docs.microsoft.com/en-us/azure/devops/repos/git/import-git-repository

### Configure the pipelines

Add two new pipelines, selecting the existing files `.azure-pipelines/azops-pull.yml` & `.azure-pipelines/azops-push.yml`.

We recommend naming these pipelines `AzOps - Pull` & `AzOps - Push`.

Add a new secret variable to each of the pipelines:

* AZURE_CREDENTIALS   (escape the quotes in the json string from `"` to  `\"` )

Set the value to the JSON string created by the steps in the [GitHub - Setup Guide](setup-github.md).

### Configure repository permissions

The build service account `<Project> Build Service (<Organization>)` must have the following permissions on the repository:

* `<Project>\Contributors`


### Configure branch policies

In order for the pull pipeline to run, set the `main` branch to require build verification.

https://docs.microsoft.com/en-us/azure/devops/repos/git/branch-policies

We also recommend you allow only `squash` merge types from branches into `main`.

### Discover Environment

If the 'AzOps - Pull' pipeline is triggered manually the pipeline will discover the Azure environment.

The following steps will be executed automatically to ensure that the current Azure environment is represented in your Azure DevOps repository:

* Current Management Group, Subscriptions, Policy Definitions and Policy Assignments are discovered and RESTful representation of the resources are saved as ARM template parameters file.
* If changes are detected that is not represented in your `main` branch, it will create `system` branch representing your current configuration as ARM templates parameter file.
* Create a Pull Request (PR) with the name `Azure Change Notification` (`system`  -> `main`) and auto-merge into `main`.

Please now continue on the [Discover Environment](discover-environment.md#verify-pr-and-merge-with-main-branch) page, at the *"Verify PR and merge with `main` branch"* heading.
