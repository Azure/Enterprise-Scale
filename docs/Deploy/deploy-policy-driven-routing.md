# Policy-driven routing configuration in hub and spoke networks

The policy `Deploy a route table with specific user defined routes` allows applying a customer-defined routing configuration to in-scope VNets. For each in-scope VNet, the policy checks the existence of a route table containing a set of customer-defined UDRs; and deploys it if it does not exist. The route table is deployed to the same resource group as the VNet evaluated against the policy. The route table deployed by the policy must be manually associated to subnets.

The main usage scenario for the policy is automated routing configuration in Enterprise-Scale hub and spoke topologies (the reference architecture for Enterprise Scale with hub and spoke is documented [here](https://github.com/Azure/Enterprise-Scale/tree/main/docs/reference/adventureworks)). By assigning the policy to landing zone subscriptions that contain the spoke VNet(s), it allows enforcing routing rules such as:

- Route all traffic leaving a spoke VNet to a firewall cluster in the hub.

- Allow or prevent direct internet access from spoke VNets.

- Allow direct access from spoke VNets to shared services in the hub.

- Route all traffic from spoke VNet to shared services in the hub via the hub’s firewall cluster.

The policy supports the parameters documented below.

- **effect**: A `String` that defines the effect of the policy. Allowed values are `DeployIfNotExist` (default) and `Disabled`.

- **requiredRoutes**: An `Array` of `String` objects. Each `String` object defines a User-Defined Route (UDR) in the custom route table deployed by the policy. The format is `"address-prefix;next-hop-type;next-hop-ip-address"`. The next-hop IP address must be provided on when the next hop type is "VirtualAppliance". Allowed values for the next hop type field are documented [here](https://learn.microsoft.com/azure/virtual-network/virtual-networks-udr-overview#next-hop-types-across-azure-tools). This is an example of a *requiredRoutes* array that defines four UDRs:  

```json
[
"0.0.0.0/0;VirtualAppliance;192.168.1.100", 
"192.168.1.4/32;VirtualAppliance;192.168.1.4",
"192.168.1.5/32;VirtualAppliance;192.168.1.5",
"192.168.2.0/24;VnetLocal"
]
```

- **vnetRegion**: A `String` that defines the region of the `Microsoft.Network/virtualNetworks` resources that are evaluated against the policy. Only VNets in the specified region are evaluated against the policy. This parameter enables multiple assignments to enforce different routing policies in different regions.
- **routeTableName**: A `String` that defines the name of the custom route table automatically deployed by the policy (when one that contains all the *requiredRoutes* is found).
- **disableBgpPropagation**: A `Boolean` that defines the value of the *disableBgpRoutePropagation* property of the deployed route table. The default value is `false`.
