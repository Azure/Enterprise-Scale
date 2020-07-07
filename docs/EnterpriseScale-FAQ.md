## FAQ

This page will list frequently asked question for Enterprise-scale design as well as Contoso Implementation.

### Enterprise-scale Design

**What does "Landing Zone" map to in Azure in the context of Enterprise-Scale?**

From Enterprise-Scale point of view, Subscription is the "Landing Zone" in Azure.

### Reference implementation

**Why do Enterprise-Scale ARM templates require permission at Tenant root '/' scope?**

Management Group creation, Subscription creation, and Subscription placement into Management Groups are Tenant level PUT API and hence it is pre-requisite to grant permission at root scope to use example templates, which will handle end-2-end Resource composition and orchestration.

**Why do we need to sync fork with upstream repo?**

This allows you to control how frequently you want to take bug/patches. This is interim solution while we package pipeline codebase as GitHub action so this step will not be required in future.

---

## Navigation Menu

* [Enterprise-Scale Architecture](./EnterpriseScale-Architecture.md)
* [Reference implementations](./reference/Readme.md)
  * [Contoso Reference - Scope and Design](./reference/contoso/Readme.md)
  * [AdventureWorks Reference - Scope and Design](./reference/adventureworks/README.md)
  * [WingTip Reference - Scope and Design](./reference/wingtip/README.md)
* [Getting started](./Deploy/getting-started.md)
  * [Setup GitHub and Azure for Enterprise-Scale](./Deploy/setup-github.md)
  * [Deploy Enterprise-Scale reference implementation](./Deploy/configure-own-environment.md)
  * [Initialize Git With Current Azure configuration](./Deploy/discover-environment.md)
  * [Deploy new Policy assignment](./Deploy/deploy-new-policy-assignment.md)
  * [Deploy Landing Zones](./Deploy/deploy-landing-zones.md)
<!--  * [Deploy new Policy Definition](./Deploy/deploy-new-deploy-new-policy-definition.md) -->
* [Known Issues](./EnterpriseScale-Known-Issues.md)
* [How Do I Contribute?](./EnterpriseScale-Contribution.md)
* [Roadmap](./EnterpriseScale-roadmap.md)
