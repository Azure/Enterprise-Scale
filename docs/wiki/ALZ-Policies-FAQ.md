# FAQ and Tips

## Frequently asked questions about ALZ policies

There is a lot of change happening for policies in Azure and we have a number of common issues being raised by our customers. This page is intended to address those issues.


## Tips & Recommendations

### Enforcement mode instead of the audit effect

We recommend that you use enforcement mode instead of the audit effect for `deny` or `deployIfNotExists` policies. The audit effect is intended to be used for a short period of time to help you understand the impact of the policy before you enable enforcement mode, the audit effect is not intended to be used as a long term solution for these types of policies.

Changing the enforcement mode to "do not enforce" on a policy or initiative assignment prevents the effect (deny or DINE) from being enforced, but still audits compliance of the policy. This is the recommended way to disable deny or DINE on a policy or initiative assignment.