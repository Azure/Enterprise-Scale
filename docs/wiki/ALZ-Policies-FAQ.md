# ALZ Policy FAQ and Tips

[toc]

## Frequently asked questions about ALZ policies

There is a lot of change happening for policies in Azure, and by extension ALZ, and we have a number of common issues being raised by our customers and partners. This page is intended to address those issues.

### Diagnostic Settings v2

### Sovereign Clouds

## Tips & Recommendations

### Enforcement mode instead of the audit effect

We recommend that you use enforcement mode instead of the audit effect for `deny` or `deployIfNotExists` policies. The audit effect is intended to be used for a short period of time to help you understand the impact of the policy before you enable enforcement mode, the audit effect is not intended to be used as a long term solution for these types of policies.

Changing the enforcement mode to "do not enforce" on a policy or initiative assignment prevents the effect (deny or DINE) from being enforced, but still audits compliance of the policy. This is the recommended way to disable deny or DINE on a policy or initiative assignment.

### Deny policies also audit

There are a number of deny policies deployed as part of ALZ that automatically take an action (deny the action). However, it is worth noting that these policies also provide an auditing capability for existing resources that have not been remediated (or can't be automatically remediated in the case of deny policies).

As an example, the policy assignment `Deny the deployment of classic resources` will deny the deployment of classic resources, but it will also audit the existence of classic resources that have already been deployed. This is useful to understand the scope of the issue and to help you remediate the issue.

### Unassigned custom policies deployed by ALZ

ALZ deploys a number of custom policies that are not assigned to any scope by default. There are some very useful policies included that would not necessarily benefit all customers, as there may be dependencies or other decisions needed that would drive the decision to implement them. These policies are intended to be used as part of custom initiatives or assigned directly as needed.

As an example, we provide the [Deploy a default budget on all subscriptions under the assigned scope](https://www.azadvertizer.net/azpolicyadvertizer/Deploy-Budget.html) policy that may be useful for managing costs for your subscriptions, e.g., subscriptions under the Sandboxes management group.