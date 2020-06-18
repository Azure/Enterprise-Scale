# AzureDevOps Configuration

> Support for Azure DevOps is currently in ***preview***

Please complete the following steps from the [setup GitHub](setup-github.md) page before continuing:

* Step 3 - create SPN with tenant root '/' owner rights
* Step 5 - Add the GitHub repo as an upstream remote (so you can pull in changes)

Follow this guide, then resume the main documentation set at the heading on the [Discover Environment](discover-environemnt.md#verify-pr-and-merge-with-main-branch) page, at the *"Verify PR and merge with `main` branch"* heading.

## Implementation notes

The Enterprise Scale *AzOps* (CI/CD) process was designed foremost to run on GitHub.
However, we recognise that many of our customers have invested in Azure DevOps and wish to continue to work with it.

The Azure DevOps (ADO) implementation uses the same GitHub action hosted in [GitHub](https://github.com/Azure/AzOps) and appropriates it for use in ADO.

This is achieved using Docker, passing in the correct environment variables for the process to work.

## Supported scenarios

We currently support all AzOps scenarios, **except for pull request review**.
This is in development and is estimated to be ready by 31 July 2020.

## How to implement

### Container registry

Currently we do not host the Docker container on the Microsoft container registry, therefore you must host it yourself.
We are not prescriptive about the registry, only that the pipeline build agent must be able to connect to it to pull the image.

Once you have selected your container registry, you need to build the container and push it. There are two approaches for this:

1. Clone the [Azure/AzOps](https://github.com/Azure/AzOps) repo and perform a docker build and docker push.

2. Fork the [Azure/AzOps](https://github.com/Azure/AzOps) repo and use the AzOpsDockerBuild.yml pipeline. You can add the GitHub repo as a upstream remote to pull changes and rebuild the image.

   * Change the ContainerRegistry variable in the pipeline yaml to suit your registry:

```yaml
  variables:
    ContainerRegistry: AzOpsRegistry
    ContainerTag: stable
    ContainerRepository: <replaceme>
    DockerVersion: '19.03.11'
```

### Create a Service Connection to your container registry

In your DevOps projects, create a service connection to your container registry.
Set the service connection name to:  `AzOpsRegistry`

> This should be performed for the `AzOps` and `Enterprise-Scale` repos if you are using both

### Import the Enterprise-Scale repo

In your ADO project, import the [Enterprise-Scale](https://github.com/Azure/Enterprise-Scale) repo from GitHub.

### Configure the pipeline

Add a new pipeline, selecting the existing `.azure-pipelines/AzOps.yml` file.

Add two new variables to the pipeline:

* DoPull - set this to the value ```false```
* AzureCredentials **(secret)** - Set this to the JSON object created by the steps in the [setup GitHub](setup-github.md) page

  > Note: The JSON must have the double quotes escaped with a backslash, e.g. `"` becomes `\"`

Finally, change the pipeline variable COntainerImage from `<replaceme>` to the 

```yml
variables:
  ContainerRegistry: AzOpsRegistry
  ContainerImage: <replaceme>:stable
  GitHubEmail: noreply@azure.com
  DockerVersion: '19.03.11'
  GitHubUserName: AzOps
  AzOpsDebug: "false"
  AzOpsVerbose: "true"
```

### Configure repo permissions

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

If the AzOps pipeline is triggered manually *AND* has the pipeline variable `DoPull` set to `true`, the pipeline will discover the Azure environment.

The following steps will be executed automatically to ensure that the current Azure environment is represented in your GitHub repository:

* Current Management Group, Subscriptions, Policy Definitions and Policy Assignments are discovered and RESTful representation of the resources are  saved as ARM Template parameters file.
* If changes are detected that is not represented in your `main` branch, it will create `system` branch representing your current configuration as ARM templates parameter file.
* Create a Pull Request (PR) with the name `Azure Change Notification` (`system`  -> `main`)

Please now continue on the [Discover Environment](discover-environemnt.md#verify-pr-and-merge-with-main-branch) page, at the *"Verify PR and merge with `main` branch"* heading.
