# Create Landing Zone(s)

It is now time to turn the lights ON :bulb:

At this point you have necessary platform setup and configured to support one or many Landing Zone(s) with required definitions (Roles, Policies and PolicySet) and assignments (Roles and Policies).

Provisioning Landing Zone(s) will mean either **creating new subscription** or **moving existing subscription** to desired management group and platform will do the rest. In large environments with 10s and 100s of Landing Zones, platform team can also delegate Landing Zone(s) to respective business units and/or application portfolio owners while being confident of security, compliance and monitoring. Furthermore, platform team may also delegate necessary access permissions 1) IAM roles to create new subscription and 2) place subscription in the appropriate management groups for business units and/or application portfolio owners to provide self-service access to create their own Landing Zone(s).

## Create or move a Subscription under the Landing Zone Management Group

Depending upon reference implementations deployed, navigate to appropriate management group under "Landing Zones" management group and create or move existing subscription. This can be done via Azure Portal or PowerShell/CLI.

Business units and/or application portfolio owners can use their preferred tool chain - ARM, PowerShell, Terraform, Portal, CLI etc. for subsequent resource deployments within their Landing Zone(s).
