## Do I need to have Azure Landing zones deployed for this to work?

*No but you will need to be using Azure Management groups and for now our focus is on the resources frequently deployed as part of Azure Landing Zone deployments.*

## Do I need to use the thresholds defined as default values in the metric rule alerts?

*It's provided as a starting point, we've based the initial thresholds on what we've seen and what Microsoft's documentation recommends. You will need to adjust the thresholds at some point.*
*You will need to observe and if the alert is too chatty, adjust the threshold up; if it's not alerting when there's a problem, adjust the threshold down a bit, (or vice-versa depending on what metric or log error is being used as a monitoring source). Once you have decided upon an appropriate value, if you feel it's fit for more general consumption we would love to hear about it.*

## Why are the availability alert thresholds lower than 100% in this solution when the product group documention recommends 100%?

*Setting a threshold of 100% can, on occasion, cause erroneous alerts that generate un-necessary noise. Lowering the threshold slightly below 100% addresses this issue while still providing an alert for a service's availability. If the default threshold isn't aggressive enough we encourage you to adjust it upwards and/or provide us feedback by filing an issue in our GitHub repo, guidance can be found on our [Support page](../../SUPPORT.md##support).*

## Do I need to use these metrics or can they be replaced with ones more suited to my environment?

*The metric rules we've created are based on recommendations from Microsoft documentation and field experience. How you're using Azure resources may also be different so tailor the alerts to suit your needs. The main goal of this project is to help you have a way to do Azure Monitor alerts at scale, create new rules with your own thresholds. We'd love to hear about your new rules too so feel free to share back.*

## Can I disable the alerts being deployed for a resource or subscription? 

*Yes, please refer to the disabling monitoring section in the [Introduction to deploying AMBA](./Introduction-to-deploying-AMBA#disabling-monitoring)*

## How much does it cost to run the ALZ Baseline solution?

*This depends on numerous factors including how many of the alert rules you choose to deploy into your environment, this combined with how many subscriptions inherit the baseline policies and resources deployed within each subscription that match the policy rules triggering an alert rule and action group deployment influence the cost.* 

*The solution is comprised of alert rules. Each alert rule costs ~0.1$/month<sup>1</sup>.*

- *Alert rules are charged based on evaluations.*
- *Assuming the alert rule had data to evaluate all throughout the month, it'll cost ~0.1$<sup>1</sup>.*
- *If the rule was only evaluating during parts of the month (e.g. because the monitored resource was down and didn't send telemetry), the customer would pay for the prorated amount of time the rule was performing evaluations.*
- *Dynamic Threshold doubles the cost of the alert rule (~0.2$/month in total<sup>1</sup>)*
- *Our solution configures an email address as part of the Action groups deployment (one per subscription) and these are charged at ~2$/month per 1,000 emails<sup>1</sup>.*

***Whilst it is not anticipated that the solution will incur significant costs, it is recommended that you assess costs as part of a deployment to a non-production environment to make sure you are clear on the costs incurred for your deployment***

*For costings related to your deployment please visit https://azure.microsoft.com/en-us/pricing/details/monitor/ and work with your local Microsoft account team to define a rough order of magnitude (RoM) costings*

*<sup>1</sup> Depending on the region you deploy to their may be a small difference in the associated cost, the costs provided here are based on prices captured as of April 2023*

## Can I access the Visio diagrams displayed in the documentation?

*Yes, the Visio diagrams are available in the [docs\media](../../docs/media) folder*
