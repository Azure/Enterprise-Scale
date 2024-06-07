# Information relating to `policies.json` and `initiatives.json`

The `policies.json` and `initiatives.json` deployment templates provides a unified deployment experience for creating all Policy Definitions and Policy Set Definitions (Initiatives) as recommended for the Azure landing zone reference implementation.

This templates are designed to work across the following clouds, ensuring the supported combination of policies are created in the customer environment:

- AzureCloud (Public)
- AzureChinaCloud (Azure China / 21Vianet)
- AzureUSGovernment (US Government)

> **IMPORTANT:**
> Please note that the `policies.json` and `initiatives.json` files located in this directory is programmatically generated and **must not** be manually edited.
> When making changes to policies, please refer to the [policies.bicep](../../../src/templates/policies.bicep) and [initiatives.bicep](../../../src/templates/initiatives.bicep) files.

<!-- markdownlint-disable-next-line MD036 -->
*further guidance to follow*
