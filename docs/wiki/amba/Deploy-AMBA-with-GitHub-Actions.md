## 1. Parameter configuration:

To start, you can either download a copy of the parameter file or clone/fork the repository.

- [ambaArm.param.json](../blob/main/eslzArm/ambaArm.param.json)

The following changes apply to all scenarios, whether you are aligned or unaligned with ALZ or have a single management group.

- Change the value of _enterpriseScaleCompanyPrefix_ to the management group where you wish to deploy the policies and the initiatives. This is usually the so called "pseudo root management group", e.g. in [ALZ terminology](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/resource-org-management-groups), this would be the so called "Intermediate Root Management Group" (directly beneath the "Tenant Root Group").
- Change the value of _ALZMonitorResourceGroupName_ to the name of the resource group where the activity logs, resource health alerts, actions groups and alert processing rules will be deployed in.
- Change the value of _ALZMonitorResourceGroupTags_ to specify the tags to be added to said resource group.
- Change the value of _ALZMonitorResourceGroupLocation_ to specify the location for said resource group.
- Change the value of _ALZMonitorActionGroupEmail_ (specific to the Service Health initiative) to the email address where notifications of the alerts are sent to.
- If you would like to disable initiative assignments, you can change the value on one or more of the following parameters; _enableAMBAConnectivity_, _enableAMBAIdentity_, _enableAMBALandingZone_, _enableAMBAManagement_, _enableAMBAServiceHealth_ to "No".

#### If you are **aligned to ALZ**
- Change the value of _IdentityManagementGroup_ to the management group id for Identity.
- Change the value of _managementManagementGroup_ to the management group id for Management.
- Change the value of _connectivityManagementGroup_ to the management group id for Connectivity.
- Change the value of _LandingZoneManagementGroup_ to the management group id for Landing Zones.

#### If you are **unaligned to ALZ** 
- Change the value of _IdentityManagementGroup_ to the management group id for Identity. The same management group id may be repeated.
- Change the value of _managementManagementGroup_ to the management group id for Management. The same management group id may be repeated.
- Change the value of _connectivityManagementGroup_ to the management group id for Connectivity. The same management group id may be repeated.
- Change the value of _LandingZoneManagementGroup_ to the management group id for Landing Zones. The same management group id may be repeated
> For ease of deployment and maintenance we have kept the same variables. If, for example, you combined Identity, Management and Connectivity into one management group you should configure the variables _identityManagementGroup_, _managementManagementGroup_ and _connectivityManagementGroup_ with the same management group id.

#### If you have a **single management group**
- Change the value of _IdentityManagementGroup_ to the pseudo root management group id, also called the "Intermediate Root Management Group".
- Change the value of _managementManagementGroup_ to the pseudo root management group id, also called the "Intermediate Root Management Group".
- Change the value of _connectivityManagementGroup_ to the pseudo root management group id, also called the "Intermediate Root Management Group".
- Change the value of _LandingZoneManagementGroup_ to the pseudo root management group id, also called the "Intermediate Root Management Group".
> For ease of deployment and maintenance we have kept the same variables. Configure the variables _enterpriseScaleCompanyPrefix_, _identityManagementGroup_, _managementManagementGroup_, _connectivityManagementGroup_ and _LZManagementGroup_ with the pseudo root management group id.


## 2. Example Parameter file:

Note that the parameter file shown below has been truncated for brevity, compared to the samples included.

```json 
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "enterpriseScaleCompanyPrefix": {
            "value": "contoso"
        },
        "IdentityManagementGroup": {
            "value": "contoso-identity"
        },
        "managementManagementGroup": {
            "value": "contoso-management"
        },
        "connectivityManagementGroup": {
            "value": "contoso-connectivity"
        },
        "LandingZoneManagementGroup": {
            "value": "contoso-landingzone"
        },
        "enableAMBAConnectivity": {
            "value": "Yes"
        },
        "enableAMBAIdentity": {
            "value": "Yes"
        },
        "enableAMBALandingZone": {
            "value": "Yes"
        },
        "enableAMBAManagement": {
            "value": "Yes"
        },
        "enableAMBAServiceHealth": {
            "value": "Yes"
        },
        "policyAssignmentParametersCommon": {
            "value": {
                "ALZMonitorResourceGroupName": {
                    "value": "rg-alz-monitor"
                },
                "ALZMonitorResourceGroupTags": {
                    "value": {
                        "Project": "alz-monitor"
                    }
                },
                "ALZMonitorResourceGroupLocation": {
                    "value": "eastus"
                }
            }
        }
    }
}
```

## 3. Configure and run the workflow
First, configure your OpenID Connect as described [here](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows#use-the-azure-login-action-with-openid-connect).

To deploy through GitHub actions, please refer to the [amba-sample-workflow.yml](../../examples/amba/amba-sample-workflow.yml).

### Modify variables and run the workflow

- Modify the following values in [amba-sample-workflow.yml](../../examples/amba/amba-sample-workflow.yml):
  - Change _Location: "norwayeast"_, to your preferred Azure region
  - Change _ManagementGroupPrefix: "alz"_, to the pseudo root management group id parenting the identity, management and connectivity management groups.
- Go to GitHub actions and run the action *Deploy AMBA*

> *IMPORTANT:* Above-mentioned "ManagementGroupPrefix" variable value, being the so called "pseudo root management group id", should _coincide_ with the value of the "parPolicyPseudoRootMgmtGroup" parameter, as set previously within the parameter files.

# Next steps
- To remediate non-compliant policies, please proceed with [Policy remediation](./Remediate-AMBA-Policies)
