# Azure VM

Describes how to setup a VM in Azure using [Azure CLI](https://learn.microsoft.com/en-us/cli/azure). In order to run `qlever-tests` with docker compose on it.

Note: This simple setup is just for playing around a bit. **Not for production!**


## Create a resource group

A resource group is a container for related resources. All resources must be placed in a resource group.

For help, see [`az group create`](https://learn.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest#az-group-create)

```bash
export RESOURCE_GROUP_NAME="qlever-playground"
export REGION="EastUS"
az group create --name $RESOURCE_GROUP_NAME --location $REGION
```


## Create a virtual machine

The VM is created in the resource group, in this example using an Ubuntu image.

The `--public-ip-sku Standard` parameter ensures that the machine is accessible via a public IP address.

The `--custom-data` parameter is used to pass in a cloud-init config file. Here, we use this config file to have Docker installed. Provide the full path to the *cloud-init.txt* config if the file is outside of the present working directory.

For help, see [`az vm create`](https://learn.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-create)

```bash
export VM_NAME="qleverVM"
export VM_IMAGE="Canonical:ubuntu-24_04-lts:server:latest"
export ADMIN_USERNAME="quser"
az vm create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $VM_NAME \
    --image $VM_IMAGE \
    --admin-username $ADMIN_USERNAME \
    --assign-identity \
    --generate-ssh-keys \
    --public-ip-sku Standard \
    --custom-data cloud-init.txt
```

Take note of the `publicIpAddress` shown in the output, this address can be used to access the virtual machine.


## Open ports

Next, we expose the ports of Qlever SPARQL endpoint, UI and petrimaps to the Internet.

For help, see [`az open port`](https://learn.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-open-port)


```bash
az vm open-port \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $VM_NAME \
    --port 7001-7004
```


## SSH into the VM

Run the following command to store the IP address of the VM as an environment variable:

```bash
export IP_ADDRESS=$(az vm show --show-details \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $VM_NAME \
    --query publicIps \
    --output tsv); \
echo "IP: $IP_ADDRESS"
```


You can now SSH into the VM:

```bash
ssh -o StrictHostKeyChecking=no $ADMIN_USERNAME@$IP_ADDRESS
```

## Configure the environment

To make things work, we need to set the IP address in some environment variables.

For using docker compose with the `local` profile we need the following changes:

```diff
diff --git a/docker-compose.yaml b/docker-compose.yaml
index 356e741..a106c85 100644
--- a/docker-compose.yaml
+++ b/docker-compose.yaml
@@ -111,8 +111,8 @@ services:
       dockerfile: ./Dockerfile
     stop_grace_period: 0s
     environment:
-      - PUBLIC_MAPS_URL=http://localhost:7004
-      - PUBLIC_BACKEND_URL=http://localhost:7001
+      - PUBLIC_MAPS_URL=http://52.123.45.678:7004
+      - PUBLIC_BACKEND_URL=http://52.123.45.678:7001
       - PRIVATE_BACKEND_URL=http://server-local:7001
     ports:
       - "7003:7003"
diff --git a/local.env b/local.env
index 0737902..24ed804 100644
--- a/local.env
+++ b/local.env
@@ -4,7 +4,7 @@ QLEVER_DATA_FORMAT=nt
 QLEVER_INDEX_INPUT_FILES=data.nt
 QLEVER_INDEX_CAT_INPUT_FILES=cat ${QLEVER_INDEX_INPUT_FILES}
 QLEVER_INDEX_SETTINGS_JSON={ "ascii-prefixes-only": false, "num-triples-per-batch": 100000 }
-# QLEVER_SERVER_ENDPOINT=http://example.com:7001
+QLEVER_SERVER_ENDPOINT=http://52.123.45.678:7001
 QLEVER_SERVER_HOST_NAME=127.0.0.1
 QLEVER_SERVER_PORT=7001
 QLEVER_SERVER_ACCESS_TOKEN=data_1234567890
@@ -16,4 +16,4 @@ QLEVER_UI_UI_CONFIG=data
 QLEVER_UI_UI_PORT=7002
 
 # Configure the base URL for the map view
-MAP_VIEW_BASE_URL=http://localhost:7003
+MAP_VIEW_BASE_URL=http://52.123.45.678:7003
```