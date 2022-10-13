# Why update ALZ policies
Azure Landing Zone (ALZ) fixme

fixme reference to ./EsLZ-Policies.md
Reference to CAF documentation

## Detect updates to policy
1. To determine if there has been updates to ALZ your first reference should be [What's New](https://github.com/Azure/Enterprise-Scale/wiki/Whats-new). Any updates to policies or other ALZ related artifacts will be reflected here upone release. fixme link to what's new with Deny Public IP update. fixme list of deprecated policies

2. Alternatively or supplementary to the information available in [What's New](https://github.com/Azure/Enterprise-Scale/wiki/Whats-new), the AzPolicyAdvertizer with the ALZ flag enabled (see [here](https://www.azadvertizer.net/azpolicyadvertizer_all.html#%7B%22col_10%22%3A%7B%22flt%22%3A%22ALZ%22%7D%2C%22col_9%22%3A%7B%7D%7D)) can be leveraged to determine deprecated ALZ policies
fixme need screenshot once it's deprecated.

3. A third alternative or supplementary tool is [Azure Governance Visualizer](https://github.com/JulianHayward/Azure-MG-Sub-Governance-Reporting) which can be run in your environment and reveal information 

### Determine if part of ALZ custom initiative
fixme should be part of release notes
fixme does AzGovViz help here?


### Migrate single ALZ custom policy to built-in policy
[Azure Portal](#tab/azure-portal)

- Go to https://portal.azure.com
- Open Policy
- Go to Definitions and in Search find the ALZ custom policy. For this example we will use the ALZ custom policy _Deny the creation of public IP_ which will be migrated to the built-in policy _Not allowed resource types_

  ![alz-custom-policy-def-search](media/alz-update-to-builtin-01.png)

- Click on the hyperlink for the policy definition
- To determine if the policy is assigned at any scope in the ALZ management group structure start by getting the policy name

  ![alz-custom-policy-def-name](media/alz-determine-policy-assign-01.png)

- Since there is no easy way to get the various scopes a policy is assigned to, got Azure Resource Graph Explorer
- Execute the following kusto query:

  ```kusto
    PolicyResources | 
    where kind =~ 'policyassignments' and tostring(properties.policyDefinitionId) =~ '/providers/Microsoft.Management/managementGroups/contoso/providers/Microsoft.Authorization/policyDefinitions/Deny-PublicIP'
    | extend 
        assignmentScope = tostring(properties.scope),
        assignmmentNotScopes = tostring(properties.notScopes),
        assignmmentParameters = tostring(properties.parameters)
    | project assignmentScope,
        assignmmentNotScopes,
        assignmmentParameters
  ```

- The above command will give a result similar to what is shown below

  ![alz-custom-policy-assignments](media/alz-determine-policy-assign-02.png)

- As can be seen this particular policy is assigned with only a simple Deny effect parameter at the following levels in the management group structure
  - Contoso/contoso-landingzones/contoso-landingzones-corp
  - Contoso/contoso-platform/contoso-platform-identity

> Note
that the provided example has a simple parameter set. If more complex parameters are assigned to a policy which is to be migrated those should be noted down. In that respect the possibility to download the query results as CSV could be leveraged.

- Switch from Azure Resource Graph Explorer back to the Policy view 
- Change the scope to include the two scopes described above, and search for the relevant policy

  ![alz-delete-policy-assignments](media/alz-delete-policy-assign-01.png)

- For each assignment, click the ellipsis and select Delete Assignment.
- Once all policy assignments are deleted, go to the Definitions pane, search for the definition. Once found click the ellipsis and choose Delete Policy Definition

  ![alz-custom-policy-def-search](media/alz-update-to-builtin-01.png)

- To assign the _Not allowed Resource types_ policy search for that policy definition. Once found click the ellipsis and choose Assign

  ![alz-builtin-policy-def-search](media/alz-assign-builtin-policy-01.png)

- Set relevant parameters, for this particular policy this would be the resource type to disallow, i.e. Microsoft.Network/publicIpAddresses, then assign the policy to the scopes previously determined.



### Determine if an ALZ custom policy or initiative is assigned in the ALZ management group structure



### Assign single Built-in policy
[Azure Portal](#tab/azure-portal)
- Go to https://portal.azure.com
- Open Policy
- Go to Definitions and in Search find the built-in policy replacing the ALZ custom policy (screenshot with sample)
- Click on the hyperlink for the policy definition
- In the policy definition view, click the Assign link (screenshot) 
- In the Assign policy view (screenshot), assign the policy with similar settings as was noted down in 1 and 3 as appropriate, being mindful that built-in policy may have different possibilities for parameters etc.
- Assign the policy at all the relevant scopes as noted in step 3.

## Migrate ALZ custom policy in ALZ custom policy initiative to built-in policy
fixme really need sample policy for this.
Set Contoso scene
Key vault diagnostics would be relevant for this. 

If no major change, i.e. minor version increment.
Get new version of ALZ custom policy initiative from here. 


### Remove ALZ custom policy
[Azure Portal](#tab/azure-portal)
- Go to https://portal.azure.com
- Open Policy
- Go to Definitions and in Search find the ALZ custom policy (screenshot with sample)
- Click on the hyperlink for the policy definition
- In the policy definition view, check the Assignments pane (screenshot). If there are no assignments, go directly to fixme delete policy definition. 
- If there are assignments, switch to the assignments pane (screenshot), and choose Edit assignment for the first policy assignment.
  1. In the Edit Policy Assignment dialog, switch to the Parameters pane to note down any specific parameters. (screenshot)
  2. After doing this choose Cancel to go back to the assignment overview
  3. Note down the assignment scope for the policy assignment just reviewed then delete the policy assignment
- Repeat steps 1 through 3 for all policy assignments for that particular policy definition.
- Once all policy assignments are deleted, delete the policy definition through the Delete definition button at the top of the page. screenshot.

### Assign Built-in policies
[Azure Portal](#tab/azure-portal)
- Go to https://portal.azure.com
- Open Policy
- Go to Definitions and in Search find the built-in policy replacing the ALZ custom policy (screenshot with sample)
- Click on the hyperlink for the policy definition
- In the policy definition view, click the Assign link (screenshot) 
- In the Assign policy view (screenshot), assign the policy with similar settings as was noted down in 1 and 3 as appropriate, being mindful that built-in policy may have different possibilities for parameters etc.
- Assign the policy at all the relevant scopes as noted in step 3.


 





