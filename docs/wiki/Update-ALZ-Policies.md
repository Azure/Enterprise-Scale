# Why update ALZ policies
fixme reference to ./EsLZ-Policies.md
Reference to CAF documentation

## Detect updates to policy

Release notes with reference to last time a policy was changed
Fixme if possible find one which was xferred to builtin


## Migrate single ALZ custom policy to built-in policy
fixme really need sample policy for this.
Set Contoso scene

### Determine if part of ALZ custom initiative
fixme should be part of release notes
fixme does AzGovViz help here?


### Remove single ALZ custom policy
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


 





