# Terraform configuration for Azure Blob Storage for healthcare ecosystem

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "healthcare_rg" {
  name     = "healthcare-content-rg"
  location = "East US"
}

resource "azurerm_storage_account" "healthcare_storage" {
  name                     = "healthcarecontentstore"
  resource_group_name      = azurerm_resource_group.healthcare_rg.name
  location                 = azurerm_resource_group.healthcare_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  allow_blob_public_access = false
}

resource "azurerm_storage_container" "healthcare_container" {
  name                  = "healthcare-files"
  storage_account_name  = azurerm_storage_account.healthcare_storage.name
  container_access_type = "private"
}

output "storage_account_name" {
  value = azurerm_storage_account.healthcare_storage.name
}

output "container_name" {
  value = azurerm_storage_container.healthcare_container.name
}
