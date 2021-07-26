# Deploy Azure Red Hat OpenShift (ARO) into an Enterprise-scale landing zone

This article provides prescriptive guidance for deploying Azure Red Hat OpenShift (ARO) clusters in enterprise-scale landing zones environment.

Additionally ARM templates and sample scripts are provided to support a deployment.

## Pre-requsites

Before getting started with this guidance, ensure that:

- Enterprise-scale landing zones has been deployed, either by using the Hub and Spoke or Virtual-WAN reference implementations, or Enterprise-scale landing zones was deployed as per [architectural guidance](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/) in the Cloud Adoption Framework.
- There is at least one landing zone under the corp management group where ARO cluster will be deployed, which is peered to the hub VNet.
- Within Enterprise-scale landing zone there is a segregation between platform and workload/application specific roles. For this guide the segregation of duties is fully respected and it is mentioned which role is able to perform the actions.
- This guide follows the  least-privilege principle by assign permissions to the user installing ARO or the respective SPN's.

Before ARO gets deployed to a landing zone, ensure the following required infrastructure is additionally configured:

### Identity

The following identities are required when installing an ARO cluster following the least-privilege principle for the ALM template deployment:

| Identity | Required privileges | Scope or resource | Description  |
|:---------|:--------------------|:------------------|:--------|
| ARO cluster SPN | Network contributor | LZ VNet | SPN required during ARO installation |
| ARO first party SPN | Network contributor | LZ VNet and UDR | Azure Red Hat OpenShift RP SPN |
| User for ARO installation | Contributor | Cluster RG | Azure AD user identity performing the installation |
| User for ARO installation | Reader | Landing zone subscription | Azure AD user identity performing the installation |

> Note: SPN has to be dedicated to a single ARO cluster and can't be shared.

Following scripts can be used by the **Platform team** to prepare the landing zone:

``` bash
    # Variable declaration
    RESOURCE_GROUP=<aro-service-rg>
    CLUSTER_RESOURCE_GROUP=<aro-cluster-rg>
    NETWORK_RESOURCE_GROUP=<network-rg>
    VNET_NAME=<vnet-name>
    SUBSCRIPTION_ID=<landing-zone-subscription-id>
    ARO_FP_SP=f1dd0a37-89c6-4e07-bcd1-ffd3d43d8875
    ARO_INSTALL_USER=<aro-installer-upn>
    CLUSTER=<cluster-name>
    CLUSTER_SPN_NAME=${CLUSTER}-spn
    
    # Creates the cluster resource group
    az group create -g "$RESOURCE_GROUP" -l "$LOCATION"

    # Create cluster SPN
    az ad sp create-for-rbac --name $CLUSTER_SPN_NAME --skip-assignment > spn.json

    # Cluster SPN is contributor on vNet
    az role assignment create --assignee $(cat spn.json | jq -r .appId) --role "network contributor" --scope /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${NETWORK_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${VNET_NAME}

    # Azure Red Hat Openshift account is contributor on vNet
    az role assignment create --assignee ${ARO_FP_SP} --role "network contributor" --scope /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${NETWORK_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${VNET_NAME}

    # User who will be installing ARO is contributor on RG and reader on the subscription (Please note that no owner permission is required)
    az role assignment create --assignee ${ARO_INSTALL_USER} --role "Contributor" --scope /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}
    az role assignment create --assignee ${ARO_INSTALL_USER} --role "Reader" --scope /subscriptions/${SUBSCRIPTION_ID}

    # Azure Red Hat Openshift account is contributor on UDR
    az role assignment create --assignee ${ARO_FP_SP} --role "network contributor" --scope /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${NETWORK_RESOURCE_GROUP}/providers/Microsoft.Network/routeTables/aro-udr

    # Cluster SPN is contributor on UDR
    az role assignment create --assignee $(cat spn.json | jq -r .appId) --role "network contributor" --scope /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${NETWORK_RESOURCE_GROUP}/providers/Microsoft.Network/routeTables/aro-udr
```

### Azure Policy consideration

Enterprise-scale landing zones managed compliant resource and landing zone configuration via Azure Policy and Policy driven approach. ARO is deployed as a Managed Application and managed certain configuration which conflict with existing Policy assignments. The following Enterprise-scale landing zone custom policies conflicting with the deployment of ARO:

- Subnets should have a Network Security Group (-> ARO installer deploys and manages own default NSG)
- Public network access should be disabled for PaaS services (-> ARO installer deploys and manages two Storage Accounts)

**Platform team** can create exemptions for these existing Policy assignments.

### Network

The following network configuration need to be applied by the **Platform/NetOps team** at the target landing zone. Please note, in the Enterprise-scale context landing zone VNET has already existing and needs the following configuration.

| Resource      | Description             |
|:--------------|:------------------------|
| Master-subnet | Subnet for master nodes |
| Worker-subnet | Subnet for worked nodes |
| Private link service network policies | Must be disabled on the Master-Subnet |
| Azure Container Registry (ACR) Service Endpoint | Both subnets, Master-Subnet and Worker-Subnet require Service Endpoint for ACR (optional step, can be added at a later stage)|

> Note: Make sure that no NSG exists on the subnets. ARO installer will fail or overwrite any existing NSG. NSG are managed resources in the ARO context.

Commands to create subnets and Azure Private Link policies:

```shell
# Variables for the previous section wil be required
az network vnet subnet create \
    -g "$NETWORK_RESOURCE_GROUP" \
    --vnet-name "$VNET_NAME" \
    -n "$CLUSTER-master" \
    --address-prefixes 10.10.1.0/24 \
    --service-endpoints Microsoft.ContainerRegistry

az network vnet subnet create \
    -g "$NETWORK_RESOURCE_GROUP" \
    --vnet-name "$VNET_NAME" \
    -n "$CLUSTER-worker" \
    --address-prefixes 10.10.2.0/24 \
    --service-endpoints Microsoft.ContainerRegistry

az network vnet subnet update \
  -g "$NETWORK_RESOURCE_GROUP" \
  --vnet-name "$VNET_NAME" \
  -n "$CLUSTER-master" \
  --disable-private-link-service-network-policies true

```

### Firewall rule configuration

Firewall configuration documented [here](https://docs.microsoft.com/en-us/azure/openshift/howto-restrict-egress) need to be applied by the Platform/NetOps team in Azure Firewall in the connectivity subscription.

## Installing Azure Red Hat OpenShift using Azure CLI

The following command will install the a new cluster into an existing landing zone VNET.
```shell
# Variables for the previous section wil be required

# Private cluster 
az aro create --name "$CLUSTER" \
              --resource-group "$RESOURCE_GROUP" \
              --cluster-resource-group "$CLUSTER_RESOURCE_GROUP" \
              --master-subnet "$CLUSTER-master" \
              --worker-subnet "$CLUSTER-worker" \
              --apiserver-visibility Private \
              --client-id $(cat spn.json | jq -r .appId) \
              --client-secret $(cat spn.json | jq -r .password) \
              --ingress-visibility Private \
              --pull-secret <pull-secret> \
              --vnet "$VNET_NAME" \
              --vnet-resource-group "$NETWORK_RESOURCE_GROUP"

```

## Installing Azure Red Hat OpenShift using ARM templates

_coming soon_