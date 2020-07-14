
# Getting Started

This article describes how to get started with Enterprise-Scale reference implementation by walking you through prerequisites to deploy a platform-native reference implementation of Enterprise-Scale.
> Note:  Before you start, please make sure that you have read and understood the overall design objective and scope of the reference implementation.

## Target audience

The target audience for this guide DevOps / SRE role and assumes knowledge in Azure Resource Manager (ARM) / Infrastructure-as-Code (IaC), Git, and PowerShell.

## Prerequisites

This table lists the technical prerequisites needed to use the Enterprise-Scale reference implementation. We have chosen to base the reference implementation on PowerShell, but if desired, it is perfectly possible to use other tools such as e.g. Azure CLI for deployment operations.

|Requirement|Additional info | |
|---------------|--------------------|--------------------|
|Git >= 2.1| Latest version of git can be found [here](https://git-scm.com/). <br/> <br/> Run following command from command prompt to ensure your Git is correctly configured. You may be prompted for login that may require you to sign in with MFA. <br/> <br/>```git clone https://github.com/Azure/Enterprise-scale.git ``` | [Git handbook](https://guides.github.com/introduction/git-handbook/)|
| VSCode |  Latest version of VSCode. <br/><br/> Open the directory ```Enterprise-scale``` cloned from previous step inside VSCode and run ```git pull``` command to ensure Git Credentials are setup correctly in VSCode. <br/> <br/> Exit VSCode and delete ```Enterprise-scale``` directory as it will no longer be required. | [Install](https://code.visualstudio.com/download#)  |
Minimum version of PowerShell: 7.0|  The latest version of PowerShell including install instructions can be found [here](https://github.com/PowerShell/PowerShell). <br> Confirm the version of PowerShell that you are running by typing `$PSVersionTable` in a PowerShell session.| [Instructions](https://github.com/PowerShell/PowerShell)
|Az.Accounts >= 1.8 <br>Az.Resources >= 2.0.1 |  `Install-Module -Name Az.<ModuleName> -MinimumVersion <Version> -Scope AllUsers`<br>Confirm the version of the module you have by running <br>`Get-Module Az.<ModuleName> -ListAvailable`. | [Docs](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps)|
|GitHub Cli [optional] |  `choco install gh` | [Docs](https://github.com/cli/cli#installation)|
| Pester >= 4.10.1 |  ***Only required if you want to run pester-tests as a developer*** <br>`Install-Module -Name Pester -MinimumVersion 4.10.1 -Scope AllUsers`<br> You can confirm the version of the module you have by running <br>`Get-Module Pester -ListAvailable`. | [Docs](https://github.com/pester/Pester) |

>:iphone: If you have Multi-factor authentication (MFA) enabled on any of your accounts, make sure that you have your token app/phone easily accessible before you start.

## Enabling long paths on Windows

Enterprise-Scale reference implementation requires that you [enable long paths in Windows](https://docs.microsoft.com/en-us/windows/win32/fileio/naming-a-file#enable-long-paths-in-windows-10-version-1607-and-later). To enable this, execute the following command from a terminal with elevated privileges:

```bash
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f
```

You will also need to execute the following command line from an elevated terminal:

```bash
git config --system core.longpaths true
```

## Next steps

Once you have the technical prerequisites in place, you can proceed to the next step, [Setup GitHub and Azure for Ensterprise-Scale](./setup-github.md).