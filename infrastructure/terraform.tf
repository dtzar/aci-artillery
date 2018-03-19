# Service Principle
variable "subscription_id" {}

variable "client_id" {}

variable "client_secret" {}

variable "tenant_id" {}

# Resource Group

variable "resource_group" {}

variable "location" {}

variable "environment" {}

# EventHub

variable "event_hub_namespace" {}

variable "event_hub_name" {}

# Stream Analytics

variable "stream_analytics_name" {}

variable "stream_analytics_sku" {}

variable "stream_analytics_cosmosdb_name" {}

variable "stream_analytics_cosmosdb_collection_name_pattern" {}

variable "stream_analytics_cosmosdb_partition_key" {}

# CosmosDB 

variable "cosmosdb_account_name" {}

variable "cosmosdb_consistency_level" {}

variable "cosmosdb_offer_type" {}

provider "azurerm" {
  # Service Principle
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

# Create a resource group
resource "azurerm_resource_group" "test" {
  name     = "${var.resource_group}"
  location = "${var.location}"

  tags {
    environment = "${var.environment}"
  }
}

# Event Hub

resource "azurerm_eventhub_namespace" "test" {
  name                = "${var.event_hub_namespace}"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
  capacity            = 1

  tags {
    environment = "${var.environment}"
  }

  depends_on = ["azurerm_resource_group.test"]
}

resource "azurerm_eventhub" "test" {
  name                = "${var.event_hub_name}"
  namespace_name      = "${azurerm_eventhub_namespace.test.name}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  partition_count     = 2
  message_retention   = 1

  depends_on = ["azurerm_eventhub_namespace.test"]
}

# Cosmos DB

resource "azurerm_cosmosdb_account" "test" {
  name                = "${var.cosmosdb_account_name}"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  offer_type          = "${var.cosmosdb_offer_type}"

  consistency_policy {
    consistency_level = "${var.cosmosdb_consistency_level}"
  }

  failover_policy {
    location = "${azurerm_resource_group.test.location}"
    priority = 0
  }

  # Create Cosmos DB and Collection. It requires az command
  # https://docs.microsoft.com/ja-jp/azure/cosmos-db/scripts/create-database-account-collections-cli?toc=%2fcli%2fazure%2ftoc.json

  provisioner "local-exec" {
    command = "az cosmosdb database create --name ${var.cosmosdb_account_name} --db-name ${var.stream_analytics_cosmosdb_name} --resource-group ${azurerm_resource_group.test.name}"
  }
  provisioner "local-exec" {
    command = "az cosmosdb collection create --collection-name ${var.stream_analytics_cosmosdb_collection_name_pattern} --name ${var.cosmosdb_account_name} --db-name ${var.stream_analytics_cosmosdb_name} --resource-group ${azurerm_resource_group.test.name} --partition-key-path ${var.stream_analytics_cosmosdb_partition_key}"
  }
  tags {
    environment = "${var.environment}"
  }
  depends_on = ["azurerm_resource_group.test"]
}

# Stream Analytics

resource "azurerm_template_deployment" "test" {
  name                = "stream-deployment-01"
  resource_group_name = "${azurerm_resource_group.test.name}"
  template_body       = "${file("${path.cwd}/template/template.json")}"

  parameters {
    // Stream Analytics parameter
    name       = "${var.stream_analytics_name}"
    location   = "${azurerm_resource_group.test.location}"
    apiVersion = "2016-03-01"
    sku        = "${var.stream_analytics_sku}"
    jobType    = "Cloud"

    // streamingUnits = "1"
    eventHubNameSpace              = "${azurerm_eventhub_namespace.test.name}"
    eventHubSharedAccessPolicyName = "RootManageSharedAccessKey"                                // need investigate
    eventHubSharedAccessKey        = "${azurerm_eventhub_namespace.test.default_primary_key}"
    eventHubName                   = "${azurerm_eventhub.test.name}"
    cosmosDBAccountName            = "${azurerm_cosmosdb_account.test.name}"
    cosmosDBAccountKey             = "${azurerm_cosmosdb_account.test.primary_master_key}"
    cosmosDBDatabaseName           = "${var.stream_analytics_cosmosdb_name}"
    cosmosDBCollectionNamePattern  = "${var.stream_analytics_cosmosdb_collection_name_pattern}"
    cosmosDBPartitionKey           = "${var.stream_analytics_cosmosdb_partition_key}"
  }

  deployment_mode = "Incremental"
  depends_on      = ["azurerm_resource_group.test", "azurerm_cosmosdb_account.test", "azurerm_eventhub.test"]
}
