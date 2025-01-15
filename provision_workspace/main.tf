# Create the Resource Group
resource "azurerm_resource_group" "gastromisrg" {
  name     = "gastromisrg"
  location = "West Europe"
}

# Create the Virtual Network (VNet)
resource "azurerm_virtual_network" "gastromisvnet" {
  name                = "gastromisvnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.gastromisrg.location
  resource_group_name = azurerm_resource_group.gastromisrg.name
}

# Create Subnets
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.gastromisrg.name
  virtual_network_name = azurerm_virtual_network.gastromisvnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.gastromisrg.name
  virtual_network_name = azurerm_virtual_network.gastromisvnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create the Databricks Workspace
resource "azurerm_databricks_workspace" "gmis_dev" {
  name                = "gmis-dev"
  resource_group_name = azurerm_resource_group.gastromisrg.name
  location            = azurerm_resource_group.gastromisrg.location
  sku                 = "premium"
}

# Configure the ADLS Gen2 Account for Metastore
resource "azurerm_storage_account" "adls_account" {
  name                     = "gastromisadls"
  resource_group_name      = azurerm_resource_group.gastromisrg.name
  location                 = azurerm_resource_group.gastromisrg.location
  account_tier             = "Premium"
  account_kind             = "BlockBlobStorage"
  account_replication_type = "LRS"
  is_hns_enabled = true
}

# Create the Metastore container
resource "azurerm_storage_container" "metastore_container" {
  name                  = "metastore"
  storage_account_id    = azurerm_storage_account.adls_account.id
  container_access_type = "private"
}

# Create the access connector
resource "azurerm_databricks_access_connector" "adb_access_connector" {
  name                = "gastromis-access-connector"
  resource_group_name = azurerm_resource_group.gastromisrg.name
  location            = azurerm_resource_group.gastromisrg.location

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }
}

# Assign "Storage Blob Data Contributor" role to the Databricks Access Connector
resource "azurerm_role_assignment" "blob_data_contributor" {
  scope                = azurerm_storage_account.adls_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.adb_access_connector.identity[0].principal_id
}