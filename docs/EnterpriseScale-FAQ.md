## FAQ

This page will list frequently asked question for Enterprise-scale design as well as Contoso Implementation.

### Enterprise-scale Design

**What does "Landing Zone" map to in Azure in the context of Enterprise-Scale?**

From Enterprise-Scale point of view, Subscription is the "Landing Zone" in Azure.

### Reference implementation

**Why do Enterprise-Scale ARM templates require permission at tenant root '/' scope?**

Management Group creation, subscription creation, and subscription placement into management groups are tenant level PUT API and hence it is pre-requisite to grant permission at root scope to use example templates, which will handle end-2-end resource composition and orchestration.

**Why do we need to sync fork with upstream repo?**

This allows you to control how frequently you want to take bug/patches. This is interim solution while we package pipeline codebase as GitHub action so this step will not be required in future.
