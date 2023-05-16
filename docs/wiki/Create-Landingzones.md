## Create landing zones (subscriptions) via Subscription Vending

The approach of "Subscription Vending", materializes and standardizes the ALZ "Subscription Democratization" Design Principle, by formulating a process for requesting, deploying and governing Azure Subscriptions, and by doing so enabling the Applications Teams to onboard their workloads in a fast, yet deterministic way.

For further details, one can look into the following articles:
- [Deploy Azure landing zones (Subscription Vending)](https://learn.microsoft.com/azure/architecture/landing-zones/landing-zone-deploy#subscription-vending)
- [Subscription vending implementation guidance](https://learn.microsoft.com/azure/architecture/landing-zones/subscription-vending)

The respective Bicep and Terraform automation / IaC Modules for Subscription Vending, can be found in:

- [Bicep Subscription Vending](https://github.com/Azure/bicep-lz-vending)
- [Terraform Subscription Vending](https://registry.terraform.io/modules/Azure/lz-vending/azurerm/latest)

More broader information on programmatical creation of Azure Subscriptions (EA/MCA/MPA) via the latest APIs, can be found on the following articles:

- [Enterprise Enrollment (EA)](https://learn.microsoft.com/azure/cost-management-billing/manage/programmatically-create-subscription-enterprise-agreement)
- [Microsoft Customer Agreement (MCA)](https://learn.microsoft.com/azure/cost-management-billing/manage/programmatically-create-subscription-microsoft-customer-agreement)
- [Microsoft Partner Agreement (MPA)](https://learn.microsoft.com/azure/cost-management-billing/manage/programmatically-create-subscription-microsoft-partner-agreement)
