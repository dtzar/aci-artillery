# Infrastructure deployment 

This directory files enable us to deploy EventHubs, Stream Analytics, and CosmosDB with configuration. We use Terraform this pupose.

# Pre-requisite 

## Terraform 

Install terraform. You can refer [Install Terraform](https://www.terraform.io/intro/getting-started/install.html). 

Then execute `init` commnd on this directory.

```
cd infrastructure
terraform init
```

This will install Azure Provider for you.

## Azure CLI

I use Azure CLI for the part of installation. Please refer this page. 

[Install Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

# Apply Terraform

## rename terraform.tfvars.example

Before applying Terraform script, rename terraform.tfvars.example to terraform.tfvars. Then edit it to fit your environment. It requires service principal to deploy your resources. 

* [Create an Azure service principal with Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest)

Please change the "YOUR_***" parts at least. 

_terraform.tfvars_ 

```
# Service Principle
subscription_id     = "YOUR_SUBSCRIPTION_ID"
client_id           = "YOUR_CLIENT_ID"
client_secret       = "YOUR_CLIENT_SECRET"
tenant_id           = "YOUR_TENANT_ID"

# Resource Group
resource_group      = "RemoveThisEH"
location            = "JapanEast"
environment         = "test"


# Event Hub
event_hub_namespace = "ArtHub"
event_hub_name      = "target"

# Stream Analytics

stream_analytics_name = "SomeJob"
stream_analytics_sku = "standard"

stream_analytics_cosmosdb_name = "somedb"
stream_analytics_cosmosdb_collection_name_pattern = "collection"
stream_analytics_cosmosdb_partition_key = "/code"

# CosmosDB

cosmosdb_account_name = "sacosmos"
cosmosdb_consistency_level = "BoundedStaleness"
cosmosdb_offer_type = "Standard"
```

# Plan and apply

then you can test your script via this command. 

```
terraform plan
```

Then you can deploy your resources via this command. 

```
terraform apply
```

It will create `terraform.tfstate` file. It includes current state. 
You can destroy all the resource by

```
terraform destroy
```

If not, you can simply remove the ResourceGroup. However don't forget to remove terraform.tfstate file. 

# Resources

* [Azure Provider](https://www.terraform.io/docs/providers/azurerm/index.html)
* [Stream Analytics Input](https://docs.microsoft.com/ja-jp/rest/api/streamanalytics/stream-analytics-input)
* [Stream Analytics/streamingjobs/inputs template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.streamanalytics/streamingjobs/inputs)

