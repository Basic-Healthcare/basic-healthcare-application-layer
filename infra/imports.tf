# Terraform Import Configuration
# This file defines how to import existing resources automatically

# Import blocks for existing resources (Terraform 1.5+)
import {
  to = azurerm_resource_group.healthcare_rg
  id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
}

import {
  to = azurerm_storage_account.healthcare_storage
  id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Storage/storageAccounts/healthcarestorefv0vlbg2"
}

import {
  to = azurerm_storage_container.healthcare_container
  id = "https://healthcarestorefv0vlbg2.blob.core.windows.net/healthcare-files"
}

# Data source to get current Azure client configuration
data "azurerm_client_config" "current" {}
