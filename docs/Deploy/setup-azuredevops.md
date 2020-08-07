# AzureDevOps Configuration

> Support for Azure DevOps is currently in ***preview***

Please complete prerequisites documented at [Configure Azure permissions for ARM tenant deployments](setup-github.md) page before continuing:

* Step 3 - create SPN with tenant root '/' owner rights
* Step 5 - Add the GitHub repo as an upstream remote (so you can pull in changes)

Follow this guide, then resume the main documentation set at the heading on the [Discover Environment](discover-environemnt.md#verify-pr-and-merge-with-main-branch) page, at the *"Verify PR and merge with `main` branch"* heading.

## Implementation notes

The [AzOps](https://github.com/Azure/AzOps/) (CI/CD) process was designed foremost to run on GitHub.
However, we recognise that many of our customers have invested in Azure DevOps and wish to continue to work with it.

The Azure DevOps (ADO) implementation uses the same Docker image and appropriates it for use in ADO.

This is achieved by passing in the correct environment variables for the process to work.

## Supported scenarios

We currently support all AzOps scenarios, **except for pull request review**.
This is in development and is estimated to be ready by 10 August 2020.

## How to implement

### Import the Enterprise-Scale repo

In your ADO project, import the [Enterprise-Scale](https://github.com/Azure/Enterprise-Scale) repo from GitHub.

### Configure the pipelines

Add a new pipeline, selecting the existing `.azure-pipelines/azops-pull.yml` file.
Add a new pipeline, selecting the existing `.azure-pipelines/azops-push.yml` file.

Add a new variable to the pipelines:

* AZURE_CREDENTIALS **(secret)** - Set this to the JSON object created by the steps in the [setup GitHub](setup-github.md) page

 > Note: The JSON must have the double quotes escaped with a backslash, e.g. `"` becomes `\"`

### Configure repository permissions

The build service account `<Project> Build Service (<Organization>)` must have the following permissions on the repository:

* Contribute
* Contribute to pull requests
* Create branch
* Force push

### Configure branch protection

In order for the pull request pipeline to run, set the main branch to require build verification from the AzOps pipeline.
We suggest that the build verification is set top optional at this time, as the pipeline performs a commit, which will invalidate the build verification if it is set to required.

We also recommend you allow only `squash` merge types from branches into `main`.

### Discover Environment

If the 'AzOps Pull' pipeline is triggered manually the pipeline will discover the Azure environment.

The following steps will be executed automatically to ensure that the current Azure environment is represented in your GitHub repository:

* Current Management Group, Subscriptions, Policy Definitions and Policy Assignments are discovered and RESTful representation of the resources are saved as ARM template parameters file.
* If changes are detected that is not represented in your `main` branch, it will create `system` branch representing your current configuration as ARM templates parameter file.
* Create a Pull Request (PR) with the name `Azure Change Notification` (`system`  -> `main`)

Please now continue on the [Discover Environment](discover-environemnt.md#verify-pr-and-merge-with-main-branch) page, at the *"Verify PR and merge with `main` branch"* heading.
