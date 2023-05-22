# ALZ Policy FAQ and Tips

## Frequently asked questions about ALZ policies

There is a lot of change happening for policies in Azure, and by extension ALZ, and we have a number of common issues being raised by our customers and partners. This page is intended to address those issues.

### Diagnostic Settings v2 (May 2023)

There are several issues raised around Diagnostic Settings, and we acknowledge that this is a complex area that is causing a lot of pain.

At this time, the owners of Azure features/services are reworking their policies to comply with the new diagnostic settings v2 schema (which includes logging categories which is a popular ask). New diagnostics settings policies are landing for Azure services, with dedicated policies depending on the logging target required (Log Analytics, Event Hub or storage accounts). We are working with the product groups to ensure that the policies are updated as soon as possible.

Check back here for updates, and be sure to bookmark [What's New](https://aka.ms/alz/whatsnew) to see the latest updates to ALZ.

To view the current list of GitHub issues related to diagnostic settings, please see [this link](https://github.com/Azure/Enterprise-Scale/labels/Area:%20Diagnostic%20Settings).

### Azure Monitor Agent (May 2023)

Similarly, as Microsoft Monitor Agent (MMA) is on a deprecation path, Azure Monitor Agent (AMA) is the recommended replacement. AMA is currently in preview, and we are working with the product group to ensure that the policies are updated as soon as possible. Some policies are ready, however, the initiative to activate all components is still being worked on.

### Sovereign Clouds

Numerous GitHub issues related to sovereign clouds are currently within our scope, and our team is actively endeavoring to resolve these concerns.

Regrettably, due to stringent security requirements inherent in sovereign cloud environments, our team lacks the necessary access privileges to validate policies or authenticate the successful deployment of ALZ. Presently, our access permissions are confined exclusively to the public cloud.

Given our constraints in conducting direct tests, we are dependent on the invaluable support of the broader community to assist us in identifying potential issues and offering constructive feedback. We intend to respond to issues pertaining to sovereign clouds on an "as soon as possible" basis, deploying our best efforts. However, due to the aforementioned limitations, we are unable to offer precise timelines for issue resolution.

To view the current list of GitHub issues related to sovereign clouds, please see [this link](https://github.com/Azure/Enterprise-Scale/labels/Area%3A%20Sovereign).

## Tips & Recommendations

### Enforcement mode instead of the audit effect

It is strongly suggested that the enforcement mode be utilized over the audit effect for policies such as deny or deployIfNotExists. The function of the audit effect primarily serves as a brief, introductory measure to gauge the impending impacts of the policy prior to activating the enforcement mode. This mechanism is not designed to act as a perpetual solution for these categories of policies.

By modifying the enforcement mode to a "do not enforce" state on a policy or initiative assignment, the enforcement of the effect (deny or DINE) is effectively suspended, while still maintaining the auditing of policy compliance. This strategy is particularly beneficial when seeking to deactivate deny or DINE on a policy or initiative assignment and comes highly recommended for such circumstances.

### Deny policies also audit

Numerous deny policies, constituting a part of the ALZ deployment, inherently carry out an action (i.e., denying the action). Nonetheless, it is critical to recognize that these policies additionally incorporate an auditing capability, particularly for pre-existing resources that remain unremediated or are inherently unremediable in instances of deny policies.

For instance, consider the policy assignment Deny the deployment of classic resources. While this policy predominantly prevents the deployment of classic resources, it also performs an audit of classic resources that have been previously deployed. This functionality is instrumental in comprehending the extent of the issue at hand and thereby facilitates effective remediation efforts.

### Unassigned custom policies deployed by ALZ

ALZ deploys a number of custom policies that are not assigned to any scope by default. There are some very useful policies included that would not necessarily benefit all customers, as there may be dependencies or other decisions needed that would drive the decision to implement them.

As an example, we provide the [Deploy a default budget on all subscriptions under the assigned scope](https://www.azadvertizer.net/azpolicyadvertizer/Deploy-Budget.html) policy that may be useful for managing costs for your subscriptions, e.g., subscriptions under the Sandboxes management group.

As a starting point reviewing ALZ provided custom policies, we recommend that you review the [ALZ custom policies](https://www.azadvertizer.net/azpolicyadvertizer_all.html#%7B%22col_11%22%3A%7B%22flt%22%3A%22ALZ%22%7D%2C%22col_3%22%3A%7B%22flt%22%3A%22!diag%22%7D%2C%22page_length%22%3A100%7D). This link will show you all the ALZ custom policies that are not diagnostic settings policies. Some of these are assigned to specific scopes or included in initiatives that are assigned, but many are not ([AzAdvertizer](https://www.azadvertizer.net/) is not aware of ALZ policy assignments).

Alternatively, we highly recommend you run [AzGovViz](https://github.com/JulianHayward/Azure-MG-Sub-Governance-Reporting) against your Azure estate to understand the policies that are assigned to your subscriptions and management groups, and get a tailored report that includes unassigned policies. An example, based on a vanilla ALZ deployment, is shown below:

![AzGovViz ALZ Policy example](./media/AzGovViz-ALZ-Policy.png)
To get the full list of unassigned ALZ policies, check "# Orphaned Custom Policy definitions" in the report.
