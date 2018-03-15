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

# Stream Analytics

resource "azurerm_template_deployment" "test" {
  name                = "stream-deployment-01"
  resource_group_name = "${azurerm_resource_group.test.name}"
  template_body       = "${file("${path.cwd}/template/template.json")}"

  parameters {
    // Stream Analytics parameter
    name           = "${var.stream_analytics_name}"
    location       = "${azurerm_resource_group.test.location}"
    apiVersion     = "2017-04-01-preview"
    sku            = "${var.stream_analytics_sku}"
    jobType        = "Cloud"
    streamingUnits = 1
  }

  deployment_mode = "Incremental"
  depends_on      = ["azurerm_resource_group.test", "azurerm_cosmosdb_account.test"]
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

  tags {
    environment = "${var.environment}"
  }
}
