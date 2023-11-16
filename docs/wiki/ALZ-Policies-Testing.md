# Azure Landing Zone Policy Testing Framework

## Overview

The ALZ Policy Testing Framework is a set of tools and scripts that can be used to test Azure Policies do what is expected and prevent breaking regressions. The framework is designed to be used with pipelines as part of CI/CD processes to test policies as they are developed and integrated to ultimately improve the quality and stability of policies going into production environments.

This framework is based on the work done by @fawohlsc in this repo [azure-policy-testing](https://github.com/fawohlsc/azure-policy-testing), and is built on the well established PowerShell testing framework [Pester](https://pester.dev/).

## How it works

The framework is designed to be used with GitHub Actions, but can be used with any CI/CD pipeline that supports PowerShell. The framework is designed to be used with the following workflow:

1. A pull request is created to update a policy definition
2. The pull request triggers a GitHub Action workflow
3. The workflow runs the Pester tests against the policy definition
4. The workflow reports the results of the tests back to the pull request
5. The pull request is reviewed and approved

## How to use it

### 1. Create a new GitHub Action workflow

Create a new GitHub Action workflow in the `.github/workflows` folder of your repository. The workflow should be triggered on pull request events and should run on the `main` branch. The workflow should also be triggered manually to allow for testing of policies outside of pull requests.

[SAMPLE](ALZ-Policies-Test-Workflow-Sample.md)

### 2. Create a new Pester test file

Create a new Pester test file in the `tests/policy` folder of your repository. The test file should be named the same as the policy definition file it is testing, but with a `.tests.ps1` extension. For example, if the policy definition file is named `azurepolicy.json`, the test file should be named `azurepolicy.tests.ps1`.

### 3. Write the Pester tests

Write the Pester tests in the test file. The tests should cover the following scenarios:

- Conditions that should be true when the policy is evaluated, so it is compliant
- Conditions that should be false when the policy is evaluated, so it is non-compliant

It is key to test all the conditions addressed in the policy.

## Getting Started

### Prerequisites

- [Pester](https://pester.dev/docs/introduction/installation)
- [Az PowerShell Module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-6.2.0)
